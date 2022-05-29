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
  spec.required_ruby_version = Gem::Requirement.new('>= 2.6.0')

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = spec.homepage
  spec.metadata['changelog_uri'] = 'https://github.com/bobf/postmortem/blob/master/README.md'

  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features|doc)/}) }
  end
  spec.bindir        = 'bin'
  spec.executables   = []
  spec.require_paths = ['lib']

  spec.add_runtime_dependency 'mail', '~> 2.7'

  spec.add_development_dependency 'actionmailer', '~> 6.1'
  spec.add_development_dependency 'devpack', '~> 0.4.0'
  spec.add_development_dependency 'faker', '~> 2.21'
  spec.add_development_dependency 'pony', '~> 1.13'
  spec.add_development_dependency 'rspec', '~> 3.11'
  spec.add_development_dependency 'rspec-its', '~> 1.3'
  spec.add_development_dependency 'rubocop', '~> 1.30'
  spec.add_development_dependency 'rubocop-rspec', '~> 2.11'
  spec.add_development_dependency 'strong_versions', '~> 0.4.5'
  spec.add_development_dependency 'timecop', '~> 0.9.5'
  spec.metadata['rubygems_mfa_required'] = 'true'
end
