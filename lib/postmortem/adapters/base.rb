# frozen_string_literal: true

module Postmortem
  module Adapters
    FIELDS = %i[from reply_to to cc bcc subject text_body html_body message_id].freeze

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
        (%i[id] + FIELDS).map { |field| [camelize(field.to_s), public_send(field)] }.to_h
      end

      def id
        @id ||= SecureRandom.uuid
      end

      FIELDS.each do |method_name|
        define_method method_name do
          @adapted[method_name]
        end
      end

      def html_body
        @adapted[:html_body].to_s
      end

      def text_body
        @adapted[:text_body].to_s
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
