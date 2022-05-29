# frozen_string_literal: true

module Postmortem
  # Provides an HTML document that announces a unique ID to a parent page via JS message events.
  class Identity
    def content
      ERB.new(File.read(path), trim_mode: '-').result(binding)
    end

    private

    def uuid
      @uuid ||= SecureRandom.uuid
    end

    def path
      File.expand_path(File.join(__dir__, '..', '..', 'layout', 'postmortem_identity.html.erb'))
    end
  end
end
