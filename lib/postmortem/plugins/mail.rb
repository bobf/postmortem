# frozen_string_literal: true

Mail::SMTP.class_eval do
  alias_method :_original_deliver!, :deliver!

  def deliver!(mail)
    result = _original_deliver!(mail) unless Postmortem.config.mail_skip_delivery
    Postmortem.record_delivery(Postmortem::Adapters::Mail.new(mail))
    result
  end
end
