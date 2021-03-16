.PHONY: test
test:
	bundle exec rspec
	bundle exec rubocop
	bundle exec strong_versions

.PHONY: demo
demo:
	bundle exec ruby doc/demo.rb
