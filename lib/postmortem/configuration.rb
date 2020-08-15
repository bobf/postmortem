# frozen_string_literal: true

module Postmortem
  # Provides interface for configuring Postmortem and implements sensible defaults.
  class Configuration
    attr_writer :colorize, :timestamp
    attr_accessor :log_path

    def timestamp
      defined?(@timestamp) ? @timestamp : true
    end

    def colorize
      defined?(@colorize) ? @colorize : true
    end

    def preview_directory=(val)
      @preview_directory = Pathname.new(val)
    end

    def layout=(val)
      @layout = Pathname.new(val)
    end

    def layout
      default = File.expand_path(File.join(__dir__, '..', '..', 'layout', 'default'))
      path = Pathname.new(@layout || default)
      path.extname.empty? ? path.sub_ext('.html.erb') : path
    end

    def preview_directory
      @preview_directory ||= Pathname.new(File.join(Dir.tmpdir, 'postmortem'))
    end
  end
end
