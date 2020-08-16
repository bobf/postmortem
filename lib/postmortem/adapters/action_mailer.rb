# frozen_string_literal: true

module Postmortem
  module Adapters
    # Rails ActionMailer adapter.
    class ActionMailer < Base
      private

      def adapted
        {
          from: mail.from,
          reply_to: mail.reply_to,
          to: mail.to,
          cc: mail.cc,
          bcc: normalized_bcc,
          subject: mail.subject,
          text_body: text_part,
          html_body: html_part
        }
      end

      def text_part
        return nil unless text?
        return mail.body.decoded unless mail.text_part

        mail.text_part.decoded
      end

      def html_part
        return nil unless html?
        return mail.body.decoded unless mail.html_part

        mail.html_part.decoded
      end

      def mail
        @mail ||= Mail.new(@data[:mail])
      end

      def normalized_bcc
        Mail.new(to: @data[:bcc]).to
      end

      def text?
        return true unless mail.has_content_type?
        return true if mail.content_type.include?('text/plain')
        return true if mail.multipart? && mail.text_part

        false
      end

      def html?
        return true if mail.has_content_type? && mail.content_type.include?('text/html')
        return true if mail.multipart? && mail.html_part

        false
      end
    end
  end
end
