[![Gem Version](https://img.shields.io/github/v/release/nestor-custodio/crapi?color=green&label=gem%20version)](https://rubygems.org/gems/crapi)
[![MIT License](https://img.shields.io/github/license/nestor-custodio/crapi)](https://tldrlegal.com/license/mit-license)


# CrAPI

CrAPI is yet another **Cr**ud **API** client wrapper. Yes, there is no shortage of these out there, but no other API wrapper gem (that I could find) provided the kind of functionality you get from the CrAPI::Proxy class, which is really the biggest benefit here.

**CrAPI::Client** will connect to the target system and handily provides a base path for you (because some APIs and services have a path that is always part of every request), **CrAPI::Proxy** lets you add to the root client's base path or default set of headers without having to create any new connections.


## Installation

Add this line to your application's Gemfile:

```ruby
gem 'crapi'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install crapi


## Using The CrAPI Tools

### Client Usage

```ruby
# Connect to an API.

api = CrAPI::Client.new('https://jsonplaceholder.typicode.com/')


# Issue requests against the API.

api.get('users/1')  # GETs /users/1; returns a Hash.

api.get('posts', query: { userId: 2 })  # GETs /posts?userId=2; returns an Array.

mew_comment = { user: 'megapwner', text: 'FRIST!!1!' }
api.post('comments', payload: new_comment)  # POSTs to /comments; returns a Hash.
```

---

### Proxy Usage

```ruby
# Connect to an API.

api = CrAPI::Client.new('https://versioned.fake-api.com/api/')


# Back in the v1 days, versioning of this API was via the URL ...

v1 = api.new_proxy('/v1')

v1.get('data')  # GETs /api/v1/data; pretty straight-forward.
v1.post('data', payload: values)  # POSTs *values* to /api/v1/data.


# For API v2, they switched to an Accept header approach ...

v2 = api.new_proxy('/', headers: { Accept: 'application/vnd.fake-api.v2+json' })

v2.get('data')  # GETs /api/data with the v2 header.


# API v3 keeps the Accept header approach ...

v3 = api.new_proxy('/', headers: { Accept: 'application/vnd.fake-api.v3+json' })

v3.get('data')  # GETs /api/data with the v3 header.


# Note that only one connection to the client is made and you can easily make
# v1, v2, and v3 API calls ad hoc without having to juggle paths/headers yourself.
```

---

[Consult the repo docs for the full CrAPI documentation.](http://nestor-custodio.github.io/crapi/CrAPI.html)


## Feature Roadmap / Future Development

Additional features/options coming in the future:

- Cleaner handling of non-body-returning calls.
- More resilient serializing of non-String paylods when using custom Content-Type headers.


## Contribution / Development

Bug reports and pull requests are welcome at: [https://github.com/nestor-custodio/crapi](https://github.com/nestor-custodio/crapi)

After checking out the repo, run `bin/setup` to install dependencies. Then, run `bundle exec rspec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

Linting is courtesy of [Rubocop](https://docs.rubocop.org/) (`bundle exec rubocop`) and documentation is built using [Yard](https://yardoc.org/) (`bundle exec yard`). Please ensure you have a clean bill of health from Rubocop and that any new features and/or changes to behaviour are reflected in the documentation before submitting a pull request.


## License

CrAPI is available as open source under the terms of the [MIT License](https://tldrlegal.com/license/mit-license).
