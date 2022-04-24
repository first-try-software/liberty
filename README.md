<img src="assets/liberty.png"/>

# Liberty

Liberty is the state of being free from oppressive restrictions imposed by authority.

Liberty is also a minimalist web-framework for Ruby that seeks to get out of your way
so that you can focus on your most valuable asset: your business logic. It is structured
in a way that encourages you to separate your business logic from the framework code.
It provides the web adapter for a Hexagonal Architecture and it works well with Domain
Driven Design.

## Installation

Install the gem and add to the application's Gemfile by executing:

    $ bundle add liberty

If bundler is not being used to manage dependencies, install the gem by executing:

    $ gem install liberty

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

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/first-try-software/liberty. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/first-try-software/liberty/blob/main/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Liberty project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/first-try-software/liberty/blob/main/CODE_OF_CONDUCT.md).
