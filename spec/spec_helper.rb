# frozen_string_literal: true

require 'bundler/setup'

require 'action_mailer'
require 'action_view'
require 'active_job'

require 'rspec/its'
require 'timecop'
require 'devpack'

require 'postmortem'

ActiveJob::Base.queue_adapter = :inline
ActiveSupport::Deprecation.silenced = true
ActiveJob::Base.logger = Logger.new(nil)

Dir[File.join(__dir__, 'support', '**', '*.rb')].sort.each { |path| require path }
RSpec.configure do |config|
  config.include FixtureHelper
  config.before(:each) { Postmortem.configure }
  config.example_status_persistence_file_path = '.rspec_status'
  config.disable_monkey_patching!
  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end
