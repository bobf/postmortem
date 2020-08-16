# frozen_string_literal: true

ActiveSupport::Notifications.subscribe 'deliver.action_mailer' do |*args|
  Postmortem.record_delivery(Postmortem::Adapters::ActionMailer.new(args.extract_options!))
end
