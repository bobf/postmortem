# frozen_string_literal: true

# Pony monkey-patch.
module Pony
  class << self
    alias _original_mail mail

    def mail(options)
      strategy = options[:via].to_s
      # Pony uses the Mail gem for smtp delivery so we catch these further down the stack to
      # avoid duplicating deliveries.
      return _original_mail(options) if strategy == 'smtp'

      # When delivery method is "test" we do not want to interfere as ActionMailer.deliveries
      # (which delegates to Mail::TestMailer) is typically used in tests.
      result = _original_mail(options) if strategy == 'test' || !Postmortem.config.mail_skip_delivery
      Postmortem.record_delivery(Postmortem::Adapters::Pony.new(options))
      result
    end
  end
end
