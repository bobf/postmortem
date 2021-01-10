# frozen_string_literal: true

module Postmortem
  # Generates and parses an index of previously-sent emails.
  class Index
    def initialize(index_path, mail_path, timestamp, subject)
      @index_path = index_path
      @mail_path = mail_path
      @timestamp = timestamp.iso8601
      @subject = subject
    end

    def content
      mail_path = @mail_path
      ERB.new(File.read(template_path), nil, '-').result(binding)
    end

    private

    def encoded_index
      return [encoded_mail] unless @index_path.file?

      [encoded_mail] + lines[index(:start)..index(:end)]
    end

    def encoded_mail
      Base64.urlsafe_encode64(mail_data.to_json)
    end

    def mail_data
      [@subject || '(no subject)', @timestamp, @mail_path]
    end

    def lines
      @lines ||= @index_path.read.split("\n")
    end

    def index(position)
      offset = { start: 1, end: -1 }.fetch(position)
      lines.index(marker(position)) + offset
    end

    def marker(position)
      "### INDEX #{position.to_s.upcase}"
    end

    def template_path
      File.expand_path(File.join(__dir__, '..', '..', 'layout', 'index.html.erb'))
    end
  end
end
