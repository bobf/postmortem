# frozen_string_literal: true

module Postmortem
  module Adapters
    # Rails ActionMailer adapter.
    class ActionMailer < Base
      private

      def adapted
        %i[from reply_to to cc subject message_id]
          .to_h { |field| [field, mail.public_send(field)] }
          .merge({ text_body: text_part, html_body: html_part, bcc: normalized_bcc })
      end

      def normalized_bcc
        ::Mail.new(to: @data[:bcc]).to
      end

      def mail
        @mail ||= ::Mail.new(@data[:mail])
      end
    end
  end
end
