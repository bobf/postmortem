# frozen_string_literal: true

module Postmortem
  module Adapters
    # Mail adapter.
    class Mail < Base
      private

      def adapted
        %i[from reply_to to cc bcc subject message_id attachments]
          .map { |field| [field, mail.public_send(field)] }
          .to_h
          .merge({ text_body: text_part, html_body: html_part })
      end

      def mail
        @mail ||= @data
      end
    end
  end
end
