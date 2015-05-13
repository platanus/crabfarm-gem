Crabfarm Cheat Sheet
===========

##### Record a memento

```
$ crabfarm r memento MEMENTO_NAME
```

##### Create a Navigator (and its Reducer)

```
$ crabfarm g navigator NAVIGATOR_NAME -u URL
```

##### Take an HTML snapshot from real website

```
$ crabfarm r snapshot NAVIGATOR_NAME
```

##### Take an HTML snapshot from a memento

```
$  crabfarm r snapshot NAVIGATOR_NAME -m MEMENTO_NAME
```

##### Using RSPEC

```
it "description of what the class does" do
  expect(a_result).to eq("this value")
  expect(a_result).not_to eq("that value")
  expect(a_result).to be >= 10
  expect(a_result).to match /a regex/
  expect(a_result).to be_a <class>
  expect(a_result).to include "str"
end
```

###### Tell RSPEC to use a memento

```
it "a navigator test", navigating: MEMENTO_NAME do
end
```

###### Tell RSPEC to use a snapshot
```
it "a reducer test", reducing: SNAPSHOT_NAME do
end

```

##### Implementing a Navigator

```
def run
  browser.goto('http://www.somesite.com/')
  t = browser.text_field(:name, "email")
  t.set("someone@huevapi.org")
  b = browser.button(:value, "Click Here")
  b.click
  d = browser.select_list(:name, "month")
  d.select "january"
  c = browser.checkbox(:name, "enabled")
  c.set
  r = browser.radio(:name, "payment type")
  r.set
  f = browser.form(:name, "contact")
  f.submit
  f = browser.form(:action, "submit")
  f.submit
  td = browser.table(:name, 'recent_records')[2][1]
  element.html # Returns the html from browser or any element
  element.text # Returns the text from browser or any element
  browser.title # Returns the title of the web page
  browser.text.include? 'llama'
end
```

##### Implementing a Reducer

```
has_float :price, greater_than: 0.0
has_array :prices
has_string :email

def run
  self.price = at_css('.orderStats').gsub(/[^\d]/,'')
  self.prices = css('.orderStats').map{|p| p.gsub(/[^\d]/,'')}
end
```