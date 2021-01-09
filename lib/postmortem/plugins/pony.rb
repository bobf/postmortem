# frozen_string_literal: true

# Pony monkey-patch.
module Pony
  class << self
    alias _original_mail mail

    def mail(options)
      # SMTP delivery is handled by Mail plugin further down the stack
      return _original_mail(options) if options[:via].to_s == 'smtp'

      result = _original_mail(options) unless Postmortem.config.mail_skip_delivery
      Postmortem.record_delivery(Postmortem::Adapters::Pony.new(options))
      result
    end
  end
end
