# frozen_string_literal: true

# Pony monkey-patch.
module Pony
  class << self
    alias _pony_mail mail

    def mail(options)
      result = _pony_mail(options) unless Postmortem.config.pony_skip_delivery
      Postmortem.record_delivery(Postmortem::Adapters::Pony.new(options))
      result
    end
  end
end
