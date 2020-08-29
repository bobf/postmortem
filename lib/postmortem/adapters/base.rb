# frozen_string_literal: true

module Postmortem
  module Adapters
    # Base interface implementation for all Postmortem adapters.
    class Base
      def initialize(data)
        @data = data
        @adapted = adapted
      end

      def html_body=(val)
        @adapted[:html_body] = val
      end

      %i[from reply_to to cc bcc subject text_body html_body].each do |method_name|
        define_method method_name do
          @adapted[method_name]
        end
      end

      private

      def adapted
        raise NotImplementedError, 'Adapter child class must implement #adapted'
      end
    end
  end
end
