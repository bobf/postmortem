# frozen_string_literal: true

module Postmortem
  module Adapters
    # Rails ActionMailer adapter.
    class ActionMailer < Base
      private

      def adapted(data)
        mail = Mail.new(data[:mail])

        {
          from: data[:from],
          reply_to: mail.reply_to,
          to: data[:to],
          cc: data[:cc],
          bcc: data[:bcc],
          subject: data[:subject],
          html_body: body(mail)
        }
      end

      def body(mail)
        return mail.body.raw_source unless mail.html_part

        mail.html_part.decoded.strip
      end
    end
  end
end
