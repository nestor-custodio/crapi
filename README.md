# Crapi  [![Gem Version](https://badge.fury.io/rb/crapi.svg)](https://badge.fury.io/rb/crapi)

Crapi is yet another API wrapper. Yes, there is no shortage of these out there, but no other API wrapper gem (that I could find) provided the kind of functionality you get from the Crapi::Proxy class, which is really the biggest benefit here.

**Crapi::Client** will connect to the target system and handily provides a base path for you (becaue some APIs and services have a path that is always part of every request), **Crapi::Proxy** lets you add to the root client's base path or default set of headers without having to create any new connections.

Why "crapi"? Because it's a <u>CR</u>UD <u>API</u> client, and (honestly) "... It could be better."™️


## Installation

Add this line to your application's Gemfile:

```ruby
gem 'crapi'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install crapi


## Using The Crapi Tools

### Client Usage

```ruby
## Connect to an API.

api = Crapi::Client.new('https://jsonplaceholder.typicode.com/')


## Issue requests against the API.

api.get('users/1')  ## GETs /users/1; returns a Hash.

api.get('posts', query: { userId: 2 })  ## GETs /posts?userId=2; returns an Array.

mew_comment = { user: 'megapwner', text: 'FRIST!!1!' }
api.post('comments', payload: new_comment)  ## POSTs to /comments; returns a Hash.
```

---

### Proxy Usage

```ruby
## Connect to an API.

api = Crapi::Client.new('https://versioned.fake-api.com/api/')


## Back in the v1 days, versioning of this API was via the URL ...

v1 = api.new_proxy('/v1')

v1.get('data')  ## GETs /api/v1/data; pretty straight-forward.
v1.post('data', payload: values)  ## POSTs *values* to /api/v1/data.


## For API v2, they switched to an Accept header approach ...

v2 = api.new_proxy('/', headers: { Accept: 'application/vnd.fake-api.v2+json' })

v2.get('data')  ## GETs /api/data with the v2 header.


## API v3 keeps the Accept header approach ...

v3 = api.new_proxy('/', headers: { Accept: 'application/vnd.fake-api.v3+json' })

v3.get('data')  ## GETs /api/data with the v3 header.


## Note that only one connection to the client is made and you can easily make
## v1, v2, and v3 API calls ad hoc without having to juggle paths/headers yourself.
```

---

[Consult the repo docs for the full Crapi documentation.](http://nestor-custodio.github.io/crapi/Crapi.html)


## Feature Roadmap / Future Development

Additional features/options coming in the future:

- Cleaner handling of non-body-returning calls.
- More resilient serializing of non-String paylods when using custom Content-Type headers.


## Contribution / Development

Bug reports and pull requests are welcome on GitHub at https://github.com/nestor-custodio/crapi.

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

Linting is courtesy of [Rubocop](https://github.com/bbatsov/rubocop) and documentation is built using [Yard](https://yardoc.org/). Neither is included in the Gemspec; you'll need to install these locally (`gem install rubocop yard`) to take advantage.


## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
