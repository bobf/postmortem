# frozen_string_literal: true

ActiveSupport::Notifications.subscribe 'deliver.action_mailer' do |*args|
  delivery_method = Rails.try(:application)
                         &.try(:config)
                         &.try(:action_mailer)
                         &.try(:delivery_method)
  next if delivery_method.nil?
  next if %i[sendmail smtp].include?(delivery_method&.to_sym) # Delegate to Mail plugin.

  Postmortem.record_delivery(Postmortem::Adapters::ActionMailer.new(args.extract_options!))
end
