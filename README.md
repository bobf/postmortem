# Postmortem

_Postmortem_ provides a simple and clean preview of all outgoing mails sent by your application.

For every email your application sends a clearly-visible log entry is written with a temporary file that you can load in your browser to preview your email.

## Features

* Seamless integration with  _ActionMailer_.
* Preview email content as well as typical email headers (recipients, subject, etc.).
* Email is loaded inside an `<iframe>` to ensure that no styles are inherited from the parent document and that the document is valid (i.e. no need to worry about nested `<html>` tags etc.

## Installation

Add the gem to your application's Gemfile:

```ruby
group :development, :test do
  gem 'postmortem', '~> 0.1.1'
end
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install postmortem

## Usage

_Postmortem_ automatically integrates with _Rails ActionMailer_. When an email is sent an entry will be visible in your application's log output.

Load the provided file in your browser to preview your email:

![Example](doc/example.png)

## Configuration

Configure _Postmortem_ by calling `Postmortem.configure`, e.g. in a _Rails_ initializer.

```ruby
# config/initializers/postmortem.rb
Postmortem.configure do |config|
  # Colorize log output to improve visibility (default: true).
  config.colorize = true

  # Prefix all preview filenames with timestamp (default: true).
  # Setting to false allows refreshing the same path to view the latest version.
  config.timestmap = true

  # Path to the Postmortem log file, where preview paths are written (default: STDOUT).
  config.log_path = '/path/to/postmortem.log'

  # Path to save preview .html files (default: OS-provided temp directory).
  # The directory will be created if it does not exist.
  config.preview_directory = '/path/to/postmortem/directory'

  # Provide a custom layout path (i.e. the page that wraps the email preview).
  # If no extension provided `.html.erb` will be appended. See default layout for more info.
  config.layout = '/path/to/layout'
end
```

## Contributing

Feel free to make a pull request.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
