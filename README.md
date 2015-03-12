# Crabfarm Toolbelt

This gem facilitates the creation of new crabfarm crawlers.

## Usage

Install it using:

    $ gem install crabfarm

Then generate a new crawler using the gem's generator:

    $ crabfarm g app YourCrawler

The generator also provides tasks to generate parsers and states:

    $ crabfarm g parser PriceTable
    $ crabfarm g state FrontPage

To run the tests just call:

    $ rspec

To use the crawler in development you can start it in server mode, just call `crabfarm s -p 3000`. Take a look at the API spec for the server.

## States

States are responsible of navigation, calling parsers to extract data and building the API output.

States represent steps in the crawling process, session information and browser connections and persisted between state transitions.

States have access to one or more webdriver sessions using the `browser` property. The `browser` property exposes the webdriver session wrapped in the selected *browser_dsl*. By default the **surfer** dsl is used, you can also use the **watir** dsl if you want.

States can also specify the crawler output document by interacting with the `output` property. By default the `output` property is just a hash. You can also use a **OpenStruct** or a **Jbuilder object**.

Every time a state is transitioned to, the crawler `state_name`, `state_params` and `doc` properties (exposed via the crawler api) are updated.

## Parsers

Parsers are resposible of extracting data from documents and exposing that data to states.

The most common parser is the one used to extract data from the HTML being crawled. You could use the `browser` property in the state to extract data, but is not recommended since webdriver is much slower than a HTML parser like Nokogiri and is also harder to test.

## Testing

Crabfarm provides a couple of tools to help you build the crawlers using TDD.

Every time a parser or a state is generated, a new empty spec is loaded into the specs directory.

Take a look at the demo folder to see the tests in action!

### Testing the states

To test a state you first need to generate a new **memento**. Mementos are a collection of cached HTTP requests that are recorded to a file and can be replayed to the crawler to test it.

To generate a new memento just call

    $ crabfarm r <name>

This will launch the firefox browser, you should emulate the crawler navigation and then close the browser, the new memento should be available in the `/spec/mementos` directory.

Next, you should write some test code using the generated memento, use the `crawling` attribute to select the memento to be loaded into each example.

```ruby
it "crawl using the given memento", crawling: 'my_memento' do
  # Pending
end
```

You can access current state using the `state` property. The first time you call `state` it will run the crawler.

You can also run the crawler manually using `crawl`, this can be usefull if you need to pass arguments to the crawler. After calling `crawl` the `state` property will return the same state returned by `crawl`. Calling `crawl` multiple times will run the crawler multiple times.

```ruby
describe MyState do

  it "should extract all prices", crawling: 'my_happy_path_memento' do
    expect(state.output.total_price).to eq(200)
  end

  it "should extract all prices", crawling: 'my_happy_path_memento' do
    expect(crawl(page: 2).output.total_price).to eq(200)
  end

  it "should fail if lands on an error page", crawling: 'my_error_memento' do
    expect { state }.to raise_error
  end

end
```

You can load other states by passing the state name to `crawl`, this will not update the `state` property though.

```ruby
describe MyState do

  before do
    crawl :login, user: 'teapot'
  end

  it "should extract all prices", crawling: 'my_happy_path_memento' do
    expect(state.output.total_price).to eq(200)
  end

end
```

Now you are ready to write the state code and stay very TDDstic at the same time!

### Testing the parsers

Parsers can be tested using static HTML snapshots.

We recommend using chrome or firefox inspect tool to extract the html to be parsed (for html parsers of course). These html snapshots should be stored in the `spec/snapshots` directory.

With the snapshot in place, use the `parsing` attribute to load the proper snapshot and then use the `parser` property to access the parser instance inside the example:

```ruby
describe MyParser do

  it "should extract total price", parsing: 'my_snapshot' do
    expect(parser.total_price).to eq(200)
  end

end
```

### Integration tests (multiple state)

**IMPORTANT** No generator is available yet for integration tests, just add new tests to the `spec/integration` directory, also remember to require the `spec_helper.rb` file.

Testing multiple states is very similar to testing just one.

Just generate a **memento** and use the `crawl` and `last_state` methods (instead of `state`) to interact with the crawler.

**IMPORTANT** You cannot call `crawl` with no state name in an integration test.

```ruby
describe "Some stuff" do

  before do
    crawl :login, user: 'blabla'
  end

  it "should extract all prices", crawling: 'my_happy_path_memento' do
    crawl :open_orders
    expect(last_state.output.orders.first.id).to eq(200)
    crawl :cancel_order, order_id: last_state.output.orders.first.id
    crawl :open_orders
    expect(last_state.output.orders.first.id).to eq(201)
  end

end
```


## Server mode API

The following API is exposed by the crawler server.

##### Get current state

    GET /api/state

Response

    {
      "name": "state_name",
      "params": { /* optional state params */ },
      "doc": { /* document structure */ }
    }

##### Change current state

    PUT /api/state
    {
      "name": "state_name",
      "params": { /* optional state params */ }
    }

Response

    {
      "name": "state_name",
      "params": { /* optional state params */ },
      "doc": { /* document structure */ }
    }

##### Error codes

Every error has an specific response structure.

* 400: Bad request, response contain invalid attributes.
* 408: Timeout, request still processing, response is empty.
* 409: Conflict, attempted to update while crawler is busy.
* 500: Crawler error, response contains error message and stacktrace.

