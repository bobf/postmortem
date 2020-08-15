# frozen_string_literal: true

module Postmortem
  module Adapters
    # Base interface implementation for all Postmortem adapters.
    class Base
      def initialize(data)
        @mail = adapted(data)
      end

      def empty?
        @mail.nil?
      end

      %i[from reply_to to cc bcc subject html_body].each do |method_name|
        define_method method_name do
          @mail[method_name]
        end
      end

      private

      def adapted(_data)
        raise NotImplementedError,
              'Adapter must be a child class of Base which implements #adapted'
      end
    end
  end
end
