<img src="assets/liberty.png"/>

# Liberty

[![Gem Version](https://badge.fury.io/rb/liberty.svg)](https://badge.fury.io/rb/liberty)
[![Ruby](https://github.com/first-try-software/liberty/actions/workflows/main.yml/badge.svg?branch=main)](https://github.com/first-try-software/liberty/actions/workflows/main.yml)

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

Liberty consists of four top level classes:
* Endpoint
* CORS
* Application (private)
* Router (private)

Inherit from the `Endpoint` class to create class that responds to a single type of request.
Here's an example for an HTTP get to the `/hello` route, which returns a hello world JSON payload.

```ruby
class MyEndpoint < Liberty::Endpoint
  responds_to :get, '/hello'

  def authenticated?
    true
  end

  def authorized?
    true
  end

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
use `responds_to` to register your route.

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

### Authentication & Authorization

Every `Endpoint` has two hooks: `#authenticated?` and `#authorized?`. Both default to `false`,
so an endpoint that does not implement them responds with `401 Authentication required`. Override
them to plug in your own auth. Liberty checks `#authenticated?` first and responds with a 401 when
it returns `false`. It then checks `#authorized?` and responds with `403 Forbidden` when that
returns `false`. Your endpoint's status, headers, and content are only consulted when both return
`true`. The raw `Authorization` header is available as `request.headers[:authorization]`.

A 401 response should tell the client how to authenticate. Override `#www_authenticate_header`
to return the challenge, such as `Bearer realm="api"`, and Liberty adds it as the
`WWW-Authenticate` header on 401 responses. When it returns `nil` the header is omitted.

Here's an example of how to use `#authenticated?` and `#authorized?`:

```ruby
class YourEndpoint < Liberty::Endpoint
  responds_to :get, "/your_endpoint"

  def authenticated?
    !current_user.nil?
  end

  def www_authenticate_header
    'Bearer realm="api"'
  end

  def authorized?
    current_user.admin?
  end

  def current_user
    @current_user ||= Sessions.find_by_token(bearer_token)
  end

  private

  def bearer_token
    request.headers[:authorization].to_s.delete_prefix("Bearer ")
  end
end
```

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
