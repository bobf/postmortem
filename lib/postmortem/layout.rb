# frozen_string_literal: true

module Postmortem
  # Wraps provided body in an enclosing layout for presentation purposes.
  class Layout
    def initialize(adapter)
      @adapter = adapter
    end

    def format_email_array(array)
      array&.map { |email| %(<a href="mailto:#{email}">#{email}</a>) }&.join(', ')
    end

    def content
      mail = @adapter
      ERB.new(Postmortem.config.layout.read).result(binding)
    end
  end
end
