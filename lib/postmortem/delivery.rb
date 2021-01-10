# frozen_string_literal: true

module Postmortem
  # Abstraction of an email delivery. Capable of writing email HTML body to disk.
  class Delivery
    attr_reader :path, :index_path

    def initialize(mail)
      @mail = mail
      @path = Postmortem.config.preview_directory.join('emails.html')
      @index_path = Postmortem.config.preview_directory.join('index.html')
    end

    def record
      path.parent.mkpath
      content = Layout.new(@mail).content
      path.write(content)
      index_path.write(Index.new(index_path, path, timestamp, @mail).content)
    end

    private

    def timestamp
      @timestamp ||= Time.now
    end

    def token
      SecureRandom.hex(4)
    end

    def subject
      return 'no-subject' if @mail.subject.nil? || @mail.subject.empty?

      @mail.subject
    end

    def safe_subject
      subject.tr(' ', '_').split('').select { |char| safe_chars.include?(char) }.join
    end

    def safe_chars
      ('a'..'z').to_a + ('A'..'Z').to_a + ('0'..'9').to_a + ['-', '_']
    end
  end
end
