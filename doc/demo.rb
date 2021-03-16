# frozen_string_literal: true

require 'action_mailer'
require 'postmortem'
require 'faker'

# Example mailer for use in demo.
class Mailer < ActionMailer::Base
  def example_mail
    mail(to: Faker::Internet.email, subject: Faker::Lorem.sentence) do |format|
      format.text { 5.times.map { Faker::Lorem.paragraph }.join("\n\n") }
      format.html do
        "<h1>#{Faker::Lorem.sentence}</h1>" + 5.times.map do
                                                "<p>#{Faker::Lorem.paragraph}</p>"
                                              end.join("\n")
      end
    end
  end
end

Mailer.example_mail.deliver_now
Mailer.example_mail.deliver_now
Mailer.example_mail.deliver_now
Mailer.example_mail.deliver_now
