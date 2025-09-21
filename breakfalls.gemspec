# frozen_string_literal: true

require_relative 'lib/breakfalls/version'

Gem::Specification.new do |spec|
  spec.name = 'breakfalls'
  spec.version = Breakfalls::VERSION
  spec.authors = ['atolix']
  spec.email = ['82761106+atolix@users.noreply.github.com']

  spec.summary = 'Rails controller error-handling hooks (global and per-controller).'
  spec.description = 'Breakfalls provides a small Railtie that wraps selected controllers with an around_action. When a StandardError is raised, it invokes your registered handlers (global and per-controller) with (exception, request, user, params), then re-raises so existing error handling continues.'
  spec.homepage = "https://github.com/atolix/breakfalls"
  spec.license = 'MIT'
  spec.required_ruby_version = '>= 3.1.0'

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = "https://github.com/atolix/breakfalls"
  spec.metadata['changelog_uri'] = "https://github.com/atolix/breakfalls/blob/main/CHANGELOG.md"
  spec.metadata['bug_tracker_uri'] = "https://github.com/atolix/breakfalls/issues"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  gemspec = File.basename(__FILE__)
  spec.files = IO.popen(%w[git ls-files -z], chdir: __dir__, err: IO::NULL) do |ls|
    ls.readlines("\x0", chomp: true).reject do |f|
      (f == gemspec) ||
        f.start_with?(*%w[bin/ test/ spec/ features/ .git .github appveyor Gemfile])
    end
  end
  spec.bindir = 'exe'
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'actionpack', '>= 6.0'
  spec.add_dependency 'railties', '>= 6.0'
  spec.add_development_dependency 'rails', '>= 6.0'

  # Uncomment to register a new dependency of your gem
  # spec.add_dependency "example-gem", "~> 1.0"

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
end
