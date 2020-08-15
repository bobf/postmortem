# frozen_string_literal: true

module Postmortem
  # Abstraction of an email delivery. Capable of writing email HTML body to disk.
  class Delivery
    attr_reader :path

    def initialize(adapter)
      @adapter = adapter
      @path = Postmortem.output_directory.join(filename)
    end

    def record
      path.parent.mkpath
      File.write(path, Layout.new(@adapter).content)
    end

    private

    def filename
      "#{timestamp}__#{safe_subject}.html"
    end

    def timestamp
      Time.now.strftime('%Y-%m-%d_%H-%M-%S')
    end

    def safe_subject
      return 'no-subject' if @adapter.subject.empty?

      @adapter.subject.tr(' ', '_').split('').select { |char| safe_chars.include?(char) }.join
    end

    def safe_chars
      ('a'..'z').to_a + ('A'..'Z').to_a + ('0'..'9').to_a + ['-', '_']
    end
  end
end
