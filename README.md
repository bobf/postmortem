# Postmortem

_Postmortem_ provides a simple and clean preview of all outgoing mails sent by your _Ruby_ application to make email development a little less painful.

Every time your application sends an email a clearly-visible log entry will be written which provides a path to a temporary file containing your preview.

Take a look at a [live example](https://postmortem.surge.sh/) to see _Postmortem_ in action.

_Postmortem_ should only be enabled in test or development environments.

## Features

* Seamless integration with [_ActionMailer_](https://guides.rubyonrails.org/action_mailer_basics.html), [_Pony_](https://github.com/benprew/pony), [_Mail_](https://github.com/mikel/mail), etc.
* Email deliveries are always intercepted (can be configured to pass through).
* Preview email content as well as typical email headers (recipients, subject, etc.).
* View rendered _HTML_, plaintext, or _HTML_ source with syntax highlighting (courtesy of [highlight.js](https://highlightjs.org/)).
* Dual or single column view to suit your requirements.
* Content is loaded inside an `<iframe>` to ensure document isolation and validity.

## Installation

Add the gem to your application's Gemfile:

```ruby
group :development, :test do
  gem 'postmortem', '~> 0.1.2'
end
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install postmortem

## Usage

_Postmortem_ automatically integrates with _Rails ActionMailer_ and  _Pony_. When an email is sent an entry will be visible in your application's log output.

The path to the preview file is based on the current time and the subject of the email. If you would prefer to use the same path for each email you can disable timestamps (see [configuration](#configuration)) and simply reload your browser every time an email is sent.

If you are using assets (images etc.) with _ActionMailer_ make sure to configure the asset host, e.g.:

```ruby
# config/environments/development.rb
Rails.application.configure do
  config.action_mailer.asset_host = 'http://localhost:3000'
end
```

Load the provided file in your browser to preview your email.

![Screenshot](doc/screenshot.png)


## Configuration
<a name="configuration"></a>

Configure _Postmortem_ by calling `Postmortem.configure`, e.g. in a _Rails_ initializer.

```ruby
# config/initializers/postmortem.rb
Postmortem.configure do |config|
  # Colorize output in logs (path to preview HTML file) to improve visibility (default: true).
  config.colorize = true

  # Prefix all preview filenames with a timestamp (default: true).
  # Setting to false allows refreshing the same path in your browser to view the latest version.
  config.timestmap = true

  # Path to the Postmortem log file, where preview paths are written (default: STDOUT).
  config.log_path = '/path/to/postmortem.log'

  # Path to save preview .html files (default: OS-provided temp directory).
  # The directory will be created if it does not exist.
  config.preview_directory = '/path/to/postmortem/directory'

  # Provide a custom layout path if the default interface does not suit you.
  # See `layout/default.html.erb` for implementation reference.
  config.layout = '/path/to/layout'

  # Skip delivery of emails when using Pony, Mail, etc. (default: true).
  config.mail_skip_delivery = true
end
```

## Contributing

Feel free to make a pull request.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
