# Crabfarm Toolbelt

This gem facilitates the creation of new crabfarm crawlers.

## Usage

Install it using:

    $ gem install crabfarm

Then generate a new crawler using the gem's generator, you can optionally pass the crawler [crabfarm.io](http://www.crabfarm.io) remote here.

    $ crabfarm g app new_crawler_folder --remote=platanus/demo

The generator also provides tasks to generate navigators and reducers, more on that later:

    $ crabfarm g navigator FrontPage
    $ crabfarm g reducer PriceTable

To run the tests just call:

    $ rspec

To use the crawler in development you can start it in server mode, just call `crabfarm s -p 3000`.


## Building your first crawler

One of our biggest advantages comes from having a structured developing process based on TDD.

### 1. Install crawbfarm and create the crawler application

Install the crabfarm gem:

    $ gem install crabfarm

Install crabtrap (a nodejs based recording proxy server used in tests)

    $ npm install crabtrap -g

Install phantomjs (only if you plan to use it as your browser)

    $ npm install phantomjs -g

Generate the application

    $ crabfarm g app my_crawler

Run bundler and rspec to check everything is in place

    $ cd my_crawler
    $ bundle
    $ rspec


### 2. Record a memento

You start developing a crawler by recording a **memento**. A **memento** is a piece of the web that gets stored in a single file and is used to test the crawlers without loading any remote resources.

```
crabfarm r memento my_memento
```

This will open your web browser, now you should pretend to be the crawler and access the pages and perform the actions you expect your crawler to perform. For this example, enter www.btc-e.com and press the LTC/BTC market button. Wait for page to load completely and the just close the browser, your new memento should be available at `/spec/mementos/my_memento.json.gz`.

### 3. Generate a navigator

Navigators are like your controllers, they receive some input parameters, navigate and interact with one or more web resources and then generate some usefull output.

We are going to build a btc-e.com crawler to extract the last price for a given market:

```
crabfarm g navigator BtcStats -u www.btc-e.com
```

This should generate a navigator source file and a corresponding spec *(this will also generate a reducer, more on that later)*. You can see we passed the target url using the `-u` option in the generator, this is optional.

Its time to take a look at the generated spec at `/specs/navigators/btc_price_spec.rb` and add some tests. Lets add an example to test that the navigator reached the correct page:

```ruby
it "should navigate to correct market page", navigating: 'my_memento' do
  navigate market: 'LTC/BTC'
  expect(browser.li(class: 'pairs-selected').text.lines.first.strip).to eq('LTC/BTC')
end
```

Lets go line by line:

```ruby
it "should navigate to correct market page", navigating: 'my_memento' do
```

By adding the `navigating: 'my_memento'` metadata, we are telling the example to run the crawler over the recorded **memento** from step 2.

```ruby
navigate market: 'LTC/BTC'
```

Calling `navigate` executes the navigator, every keyed argument is passed to the **navigator**.

```ruby
expect(browser.li(class: 'pairs-selected').text.lines.first.strip).to eq('LTC/BTC')
```

The `browser` property exposes the browser session used by the **navigator**, it can be used to check the browser status right after the **navigator** finishes.

We could also add a test to check that the **navigator** ouput has the proper structure.

```ruby
it "should provide the last, high and low prices", navigating: 'my_memento' do
  expect(state.document).to have_key :last
  expect(state.document).to have_key :high
  expect(state.document).to have_key :low
end
```

The main difference here is the use of the `state` method. It contains the crawling session state **AFTER** the **navigator** is called. If `state` is called before any calls to `navigate` then `navigate` is automatically called by `state`.

Lets move to `/app/navigators/btc_price.rb` file now, that's where the navigator code is located. As you can see there is already some code there, just a call to `browser.goto` to load the requested url and another to `reduce_with_defaults` method that will run the default reducer. Lets add some additional navigation logic to select the required market.

```ruby
def run
  browser.goto 'www.btc-e.com'

  browser.ul(class: 'pairs').lis.find do |li|
    li.text.include? params[:market]
  }.click

  reduce_with_defaults
end
```

This is mainly [watir](http://watir.com/) code. You can access the current browser session using the `browser` property. You should be able to call `rspec` now and get the first example right.

**TIP**: There is a very nice tool to help you with the HTML css selectors called [Selector Gadget](http://selectorgadget.com/).

### 4. Code the reducer

During the **navigator** generation a **reducer** with the same name was generated too. The reducer is responsible of extracting data from the document being crawled. The most common use case is having one **reducer** per **navigator**, but in some cases more than one reducer may be needed per navigator, so a reducer generator is included as well.

As with the **navigator**, you start developing the **reducer** by generating a document **snapshot**. For HTML reducers, a **snapshot** is just a portion of HTML. A **snapshot** can be generated manually but we recommend using the snapshot recorder command.

The snapshot recorder uses an already coded **navigator** to capture the html passed by it to the **reducer**. To generate a snapshot call:

```
crabfarm r snapshot btc_price -m my_memento -q market=LTC/BTC
```

The command above tells crabfarm to extract **snapshots** from the *btc_price* navigator using a memento (optional) and using a given set of parameters as a query string. If parameter are not given then crabfarm will ask for them.

Crabfarm will ask you to give the snapshot a name, call it *my_snapshot*, notice it is stored in `/spec/snapshots/my_snapshot.html`.

Now that you have the snapshot, lets write some **reducer** specs, go to `/spec/reducers/btc_price_reducer_spec.rb` and add the following example:

```ruby
it "should extract low, high and last values", reducing: 'my_snapshot' do
  expect(reducer.low).to eq 0.0061
  expect(reducer.high).to eq 0.0064
  expect(reducer.last).to eq 0.0061
end
```

Notice that the structure is very similar to a **navigator** spec, this time use the `reducing: 'my_snapshot'` option to select the snapshot to reduce and the `reducer` property to refer to the **reducer** **AFTER** processing the given snapshot.

The last step is writting the **reducer** code, parsing code goes inside the `run` method. By default the **reducer** uses [nokogiri](https://github.com/sparklemotion/nokogiri) as parser for HTML, take a look at nokogiri docs to see what methods to use inside `run`.

```ruby
class BtcPriceReducer < Crabfarm::BaseReducer

  has_float :last, less_than: 1.0
  has_float :high, less_than: 1.0
  has_float :low, less_than: 1.0

  def run
    self.last = at_css('.orderStats:nth-child(1) strong').text
    self.low = at_css '.orderStats:nth-child(2) strong'
    self.high = at_css '.orderStats:nth-child(3) strong'
  end

end
```

Chunk by chunk:

```
has_float :last, less_than: 1.0
has_float :high, less_than: 1.0
has_float :low, less_than: 1.0
```

The **reducer** allows you to define fields that take care of the parsing and validation of text values for you. Also, declared fields help keep things dry since are included in `reducer.to_json`.

```
self.last = at_css('.orderStats:nth-child(1) strong').text
```

If you dig a little deeper, you will see that `last` is beign assigned something like "0.0061 BTC". The assertion framework is smart enough to extract just the floating  point number (since we declared `last` as float) and fail if no number can be extracted from string. `at_css` is just a nokogiri method, the reducer exposes every parser method.

```
self.low = at_css '.orderStats:nth-child(2) strong'
```

The only difference of the above line with the previous is that it shows that is not necessary to call `text` every time. The field setter detects if the passed value provides a `text` method and calls it.

And thats all!, run your specs, everything should check ok.

## Trying the crawler in the console

Run the crabfarm console when inside the crawler's root

```
crabfarm c
```

Call a **navigator** with some parameters, lets get the LTC/USD value using the BtcPrice **navigator** we built in the example above.

```
nav :btc_price, coin: 'LTC/USD'
```

You can make changes the crawler classes and reload the code in the console by calling `reload!`.

You can also extract **snapshots** in the console:

```
snap :btc_price, coin: 'LTC/USD'
```

## Integrating the crawler to your application

Depending on your app's languaje, the following client libraries are available:

 * [Ruby/Rails - cangrejo gem](https://github.com/platanus/cangrejo-gem): The cangrejo gem has support for spawning your crawlers locally or in a crabfarm grid (crabfarm.io).

If the languaje you are using is not listed here, you can submit an issue or better yet an implementation.

For more information on how to create a new client library refer to the [Crabfarm client developer guide](https://github.com/platanus/crabfarm-gem/wiki/client-developer-guide) and the cangrejo source.

## About the Crabfarm.io service

The best way to run your crawlers is on the crabfarm.io grid, it also provides monitoring and alert notifications for your crawlers. For more information visit [www.crabfarm.io](www.crabfarm.io).

