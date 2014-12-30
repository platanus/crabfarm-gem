# Crabfarm Toolbelt

This gem facilitates the creation of new crabfarm crawlers.

## Usage

Install it using:

    $ gem install crabfarm

Then generate a new crawler using the gem's generator:

    $ crabfarm g app YourCrawler

The generator als provides tasks to generate parsers and states:

    $ crabfarm g parser TheParser
    $ crabfarm g state FrontPage

Crabfarm generated projects come bundled with rspec, take a look at the demo project to see how **parsers are tested using snapshots**. To run the tests just call:

    $ rspec

To use the crawler in development you can start it in server mode, just call `crabfarm s -p 3000`. Take a look at the API spec for the server.

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

