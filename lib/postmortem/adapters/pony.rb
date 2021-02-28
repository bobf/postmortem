# frozen_string_literal: true

module Postmortem
  module Adapters
    # Pony adapter.
    class Pony < Base
      private

      def adapted
        {
          from: mail.from, reply_to: mail.reply_to, to: mail.to, cc: mail.cc, bcc: mail.bcc,
          subject: mail.subject,
          text_body: @data[:body],
          html_body: @data[:html_body],
          message_id: mail.message_id # We use a synthetic Mail instance so this is a bit useless.
        }
      end

      def mail
        @mail ||= ::Mail.new(@data.select { |key| keys.include?(key) })
      end

      def keys
        %i[from reply_to to cc bcc subject text_body html_body]
      end
    end
  end
end
