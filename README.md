# Breakfalls

Breakfalls is a tiny Rails helper that lets you register error-handling hooks for your controllers. It installs an around_action wrapper for selected controllers, catches any StandardError, invokes your registered handlers (global and per-controller), and then re-raises the error so your existing error reporting still works.

## Installation

Add to your application's Gemfile and bundle:

```bash
bundle add breakfalls
```

Or install directly:

```bash
gem install breakfalls
```

## Usage

1) Tell Breakfalls which controllers to wrap. In an initializer (e.g. `config/initializers/breakfalls.rb`):

```ruby
# Wrap these controllers with Breakfalls' around_action
Rails.application.config.breakfalls.controllers = [
  'UsersController',
  'Admin::BaseController'
]
```

2) Register one or more handlers. Handlers receive `(exception, request, user, params)` in that order.

```ruby
# Global handler (runs for any wrapped controller)
Breakfalls.on_error do |exception, request, user, params|
  Rails.logger.error("[Global] #{exception.class}: #{exception.message} path=#{request&.path}")
end

# Controller-specific handler (runs before global handlers)
Breakfalls.on_error_for('UsersController') do |exception, request, user, params|
  Rails.logger.warn("[UsersController] #{exception.class} at #{request&.path}")
end
```

Order of execution: controller-specific handlers (in registration order) then global handlers (in registration order). After handlers run, the exception is re-raised so your existing error handling/reporting still applies.

## Handler order

- Controller-specific first: If the current controller matches, its handlers run before any global handlers.
- Registration order: Within each group, handlers run in the order they were registered (FIFO).
- Match scope: Only handlers registered for the exact controller class name run for that controller.
- Handler failure: If a handler itself raises, remaining handlers are skipped and that exception bubbles up.

## Development

After checking out the repo, run `bundle install` to install dependencies. Then run `rake test` to execute the test suite.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `lib/breakfalls/version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push the tag/commits, and push the `.gem` file to rubygems.org.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/atolix/breakfalls. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Breakfalls project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/atolix/breakfalls/blob/main/CODE_OF_CONDUCT.md).
