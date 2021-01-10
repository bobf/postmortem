# frozen_string_literal: true

module Postmortem
  module Adapters
    FIELDS = %i[from reply_to to cc bcc subject text_body html_body].freeze

    # Base interface implementation for all Postmortem adapters.
    class Base
      def initialize(data)
        @data = data
        @adapted = adapted
      end

      def html_body=(val)
        @adapted[:html_body] = val
      end

      def serializable
        FIELDS.map { |field| [camelize(field.to_s), public_send(field)] }.to_h
      end

      FIELDS.each do |method_name|
        define_method method_name do
          @adapted[method_name]
        end
      end

      private

      def adapted
        raise NotImplementedError, 'Adapter child class must implement #adapted'
      end

      def camelize(string)
        string
          .split('_')
          .each_with_index
          .map { |substring, index| index.zero? ? substring : substring.capitalize }
          .join
      end
    end
  end
end
