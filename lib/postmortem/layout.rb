# frozen_string_literal: true

module Postmortem
  # Wraps provided body in an enclosing layout for presentation purposes.
  class Layout
    def initialize(adapter)
      @adapter = adapter
    end

    def content
      mail = @adapter
      ERB.new(Postmortem.layout.read).result(binding)
    end
  end
end
