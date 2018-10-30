# frozen_string_literal: true

Gem::Specification.new do |spec|
  spec.name          = 'cocoapods-packing-cubes'
  spec.version       = File.read(File.expand_path('VERSION', __dir__))
  spec.authors       = ['Samuel Giddins']
  spec.email         = ['segiddins@segiddins.me']
  spec.summary       = 'A CocoaPods plugin that allows customizing how ' \
                       'individual pods are packaged and linked.'
  spec.homepage      = 'https://github.com/segiddins/cocoapods-packing-cubes'
  spec.license       = 'MIT'

  spec.files         = Dir['lib/**/*']

  spec.add_development_dependency 'bundler', '~> 1.16'
  spec.add_development_dependency 'rake', '~> 12.3'

  spec.required_ruby_version = '~> 2.0'
end
