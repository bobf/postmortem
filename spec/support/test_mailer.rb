# frozen_string_literal: true

class TestMailer < ActionMailer::Base
  layout 'mailer'
  append_view_path File.join(__dir__, 'views')

  def multipart_email
    mail(to: 'user@example.com', cc: ['cc@example.com'], bcc: ['bcc@example.com'])
  end

  def html_only_email
    mail(to: 'user@example.com')
  end

  def text_only_email
    mail(to: 'user@example.com')
  end
end
