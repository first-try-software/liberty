<img src="assets/liberty.png"/>

# Liberty

[![Gem Version](https://badge.fury.io/rb/liberty.svg)](https://badge.fury.io/rb/liberty)
[![CI](https://github.com/first-try-software/liberty/actions/workflows/main.yml/badge.svg?branch=main)](https://github.com/first-try-software/liberty/actions/workflows/main.yml)

Liberty is the state of being free from oppressive restrictions imposed by authority.

Liberty is also a minimalist web-framework for Ruby that seeks to get out of your way so that you can focus on your most valuable asset — the part of your application that is uniquely yours — your business logic.

Liberty is structured in a way that encourages you to separate your business logic from the underlying framework code. It provides a web adapter for a Hexagonal Architecture, and it works very well with Domain Driven Design.

Though Liberty does not shackle you to convention, we (the authors) do consider there to be some best practices:

First, we believe THE most important aspect of your software is your domain logic. As such, we believe you should start there, and spend the vast majority of your time working on that code. Tests can act as the front-end to drive your domain logic, and mock repositories can act as your data store. This allows you to develop your business logic in isolation.

Second, we believe your application should look uniquely yours inside an editor. Accounting programs should not look like social networks. And, neither should look like a game. As such, we encourage you to put your business logic in an obvious place that is separate and apart from the framework concepts. (We typically use a `domain` folder in which we have folders for each Bounded Context.)

Third, we believe the code that ties your application to physical infrastructure, like the web or a database or a messaging system, should be stored somewhere else. (We typically use an `app` folder for this code, with folders for `endpoints`, concrete `repositories`, and other bits of glue code.)

A small application for managing to-do lists might look like this:

```
todo/
  app/
    endpoints/
    repositories/
  domain/
    todos/
    users/
```

The `/app` folder contains the code that glues the domain logic to the outside world. While the `domain` folder contains the DDD Bounded Contexts within the application.

That said, Liberty does not use convention. It relies on classes declaratively registering themselves at load time to handle a specific use case or web request. The router dispatches requests to the appropriate endpoint (in lightning speed, we might add). And, a dispatcher calls the appropriate use case when needed.

## Usage

Liberty consists of these top level classes:
* Endpoint
* Authenticator
* Authenticators::Public
* CORS
* Application (private)
* EndpointBuilder (private)
* Router (private)

Inherit from the `Endpoint` class to create class that responds to a single type of request.
Here's an example for an HTTP get to the `/hello` route, which returns a hello world JSON payload.

```ruby
class MyEndpoint < Liberty::Endpoint
  responds_to :get, '/hello', authenticated_by: Liberty::Authenticators::Public

  def status
    200
  end

  def json
    { hello: :world }
  end
end
```

Using `responds_to` as in the example above registers a class to receive traffic on that route
with our incredibly fast `Router`. You shouldn't ever need to use the `Router` directly. Just
use `responds_to` to register your route. Every route names its authenticator; `Public` is the
one Liberty ships for routes open to anyone. See [Authentication](#authentication) below.

The `Application` class is another private class that turns each `Endpoint` class into a
Rack application. This is also a class you won't use directly.

Finally, the `CORS` class allows you to configure CORS headers for your application, like this:

```ruby
Liberty::CORS.config do |config|
  config.headers = {
    'Access-Control-Allow-Origin' => '*',
    'Access-Control-Allow-Methods' => 'POST, GET, PUT, PATCH, DELETE, OPTIONS',
    'Access-Control-Allow-Headers' => 'Origin, Content-Type, Accept, Authorization, X-Your-Own-Custom-Headers',
    'Access-Control-Max-Age' => '1728000'
  }
end
```

If you configure your CORS headers before you launch your application, `Endpoints` will
automatically respond with the right headers.

### Authentication

Every route names its authenticator:

```ruby
class Journal < Liberty::Endpoint
  responds_to :get, "/journal", authenticated_by: Authenticators::Session
end
```

`authenticated_by:` is required. A route that does not name one fails when the class loads, so
nothing is exposed by omission. To open a route to anyone, name `Liberty::Authenticators::Public`.

An authenticator is a subclass of `Liberty::Authenticator` that answers two
questions:

- `principal`: who the request is from, or `nil`. The principal is whoever the request has been
  authenticated as, whether a user, a service account, or an API client. It is any object your
  application chooses.
- `challenge_endpoint_class`: the endpoint class that answers when there is no principal, or
  `nil` to admit the request anyway.

The base class raises on both until you override them, so an authenticator cannot admit anyone
by omission either.

Liberty builds a new authenticator for every request and injects the request, available as
`request`, the same way it builds your endpoint. Every name ending in `_class` follows one rule
throughout Liberty: it names a class that Liberty instantiates for you. With a principal, Liberty
builds your endpoint. Without one, it builds the challenge instead. Either way, the endpoint
receives the request and the principal, available as `principal`, and its answers go through the
same response pipeline, so `HEAD` requests, `content-length`, and `content-type` are handled once.

Liberty ships no authenticator but `Public`, and no 401 or 403 of its own. What a request without
a principal sees is the application's to decide: a login page for a form, a `WWW-Authenticate`
challenge for a token.

Here's a form login backed by a session. The request is injected after construction, so the
authenticator takes its repository through its own initializer with a production default, and a
test can hand it a fake:

```ruby
module Authenticators
  class Session < Liberty::Authenticator
    def initialize(users: UsersRepository.new)
      @users = users
    end

    def principal
      @users.find(request.env["rack.session"][:user_id])
    end

    def challenge_endpoint_class = RedirectToLogin
  end
end

class RedirectToLogin < Liberty::Endpoint
  def status = 302

  def headers = {"location" => "/login"}
end

class Journal < Liberty::Endpoint
  responds_to :get, "/journal", authenticated_by: Authenticators::Session

  def html = "<h1>Welcome, #{principal.name}</h1>"
end
```

Here's a bearer token. The credential arrives in the `Authorization` header, which every request
exposes as `request.headers[:authorization]`. Despite its name, that header carries a credential
that has not been checked yet. Checking it is the authenticator's job:

```ruby
module Authenticators
  class Token < Liberty::Authenticator
    def initialize(sessions: ApiSessionsRepository.new)
      @sessions = sessions
    end

    def principal
      @sessions.find_by_token(bearer_token)
    end

    def challenge_endpoint_class = TokenChallenge

    private

    def bearer_token
      request.headers[:authorization].to_s.delete_prefix("Bearer ")
    end
  end
end

class TokenChallenge < Liberty::Endpoint
  def status = 401

  def headers = {"www-authenticate" => 'Bearer realm="api"'}

  def text = "Authentication required"
end
```

A page that anyone may see, but that still wants to know a signed-in user, is a session
authenticator that never challenges:

```ruby
module Authenticators
  class Optional < Session
    def challenge_endpoint_class = nil
  end
end
```

Authorization is the endpoint's own answer. When the principal may not do what the request asks,
the endpoint responds with the status and content it chooses, such as a 403.

## Installation

Install the gem and add to the application's Gemfile by executing:

    $ bundle add liberty

If bundler is not being used to manage dependencies, install the gem by executing:

    $ gem install liberty

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/first-try-software/liberty. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/first-try-software/liberty/blob/main/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Liberty project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/first-try-software/liberty/blob/main/CODE_OF_CONDUCT.md).
