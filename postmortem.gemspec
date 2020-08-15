# frozen_string_literal: true

require_relative 'lib/postmortem/version'

Gem::Specification.new do |spec|
  spec.name          = 'postmortem'
  spec.version       = Postmortem::VERSION
  spec.authors       = ['Bob Farrell']
  spec.email         = ['git@bob.frl']

  spec.summary       = 'Development HTML Email Inspection Tool'
  spec.description   = 'Preview HTML emails in your browser during development'
  spec.homepage      = 'https://github.com/bobf/postmortem'
  spec.license       = 'MIT'
  spec.required_ruby_version = Gem::Requirement.new('>= 2.3.0')

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = spec.homepage
  spec.metadata['changelog_uri'] = 'https://github.com/bobf/postmortem/blob/master/README.md'

  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = 'bin'
  spec.executables   = []
  spec.require_paths = ['lib']

  spec.add_development_dependency 'rspec', '~> 3.9'
  spec.add_development_dependency 'rubocop', '~> 0.88.0'
  spec.add_development_dependency 'strong_versions', '~> 0.4.5'
end
