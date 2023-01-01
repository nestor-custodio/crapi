lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'crapi/version'

Gem::Specification.new do |spec|
  spec.required_ruby_version = ['>= 3.0', '< 3.2']

  spec.name          = 'crapi'
  spec.version       = CrAPI::VERSION
  spec.authors       = ['Nestor Custodio']
  spec.email         = ['sakimorix@gmail.com']

  spec.summary       = 'A simple API client with built-in segment/header proxy support. "... It could be better." ™️'
  spec.homepage      = 'https://github.com/nestor-custodio/crapi'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0").reject { |filename| filename.start_with? 'test/' }
  spec.executables   = []
  spec.require_paths = ['lib']

  spec.metadata['rubygems_mfa_required'] = 'true'

  spec.add_dependency 'activesupport', ['>= 6.0', '< 7.1']

  spec.add_development_dependency 'bundler', '~> 2'
  spec.add_development_dependency 'rspec', '~> 3'
  spec.add_development_dependency 'rspec_junit_formatter'
  spec.add_development_dependency 'rubocop'
  spec.add_development_dependency 'yard'
end
