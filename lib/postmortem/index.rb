# frozen_string_literal: true

module Postmortem
  # Generates and parses an index of previously-sent emails.
  class Index
    def initialize(index_path, mail_path, timestamp, mail)
      @index_path = index_path
      @mail_path = mail_path
      @timestamp = timestamp.iso8601
      @mail = mail
    end

    def content
      mail_path = @mail_path
      ERB.new(File.read(template_path), nil, '-').result(binding)
    end

    def size
      encoded_index.size
    end

    private

    def encoded_index
      return [encoded_mail] unless @index_path.file?

      @encoded_index ||= [encoded_mail] + lines[index(:start)..index(:end)]
    end

    def encoded_mail
      Base64.encode64(mail_data.to_json).split("\n").join
    end

    def mail_data
      {
        subject: @mail.subject || '(no subject)',
        timestamp: @timestamp,
        path: @mail_path,
        content: @mail.serializable
      }
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
