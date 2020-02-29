source "https://rubygems.org"

group :test do
  gem "rake", '12.3.3'
  gem "puppet", ENV['PUPPET_GEM_VERSION'] || '~> 3.8.0'
  gem "rspec", '< 3.2.0'
  gem "rspec-puppet", '2.7.2'
  gem "puppetlabs_spec_helper", '2.2.0'
  gem "metadata-json-lint"
  gem "rspec-puppet-facts"
  gem 'rubocop', '0.49.0'
  gem 'simplecov', '>= 0.11.0'
  gem 'simplecov-console'
  gem 'rb-inotify', '0.9.10'

  gem "puppet-lint-absolute_classname-check"
  gem "puppet-lint-leading_zero-check"
  gem "puppet-lint-trailing_comma-check"
  gem "puppet-lint-version_comparison-check"
  gem "puppet-lint-classes_and_types_beginning_with_digits-check"
  gem "puppet-lint-unquoted_string-check"
end

group :development do
  gem "travis"
  gem "travis-lint"
  gem "puppet-blacksmith"
  gem "guard-rake"
end

group :system_tests do
  gem "beaker"
  gem "beaker-rspec"
  gem "beaker-puppet_install_helper"
end
