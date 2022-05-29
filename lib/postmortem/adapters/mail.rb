# frozen_string_literal: true

module Postmortem
  module Adapters
    # Mail adapter.
    class Mail < Base
      private

      def adapted
        %i[from reply_to to cc bcc subject message_id]
          .to_h { |field| [field, mail.public_send(field)] }
          .merge({ text_body: text_part, html_body: html_part })
      end

      def mail
        @mail ||= @data
      end
    end
  end
end
