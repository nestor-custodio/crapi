
lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'crud_client/version'

Gem::Specification.new do |spec|
  spec.name          = 'crud_client'
  spec.version       = CrudClient::VERSION
  spec.authors       = ['Nestor Custodio']
  spec.email         = ['sakimorix@gmail.com']

  spec.summary       = 'A simple API client with built-in segment/header proxy support.'
  spec.homepage      = 'https://www.github.com/nestor-custodio/crud_client'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 1.16'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
end
