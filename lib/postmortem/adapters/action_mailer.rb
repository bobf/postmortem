# frozen_string_literal: true

module Postmortem
  module Adapters
    # Rails ActionMailer adapter.
    class ActionMailer < Base
      private

      def adapted(data)
        {
          from: data[:from],
          to: data[:to],
          cc: data[:cc],
          bcc: data[:bcc],
          subject: data[:subject],
          html_body: Mail.new(data[:mail]).html_part.decoded.strip
        }
      end
    end
  end
end
