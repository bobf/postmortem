# frozen_string_literal: true

module Postmortem
  # Wraps provided body in an enclosing layout for presentation purposes.
  class Layout
    def initialize(mail)
      @mail = mail
    end

    def format_email_array(array)
      array&.map { |email| %(<a href="mailto:#{email}">#{email}</a>) }&.join(', ')
    end

    def content
      mail = @mail
      mail.html_body = with_inlined_images(mail.html_body) if defined?(Nokogiri)
      ERB.new(Postmortem.config.layout.read).result(binding)
    end

    def styles
      default_layout_directory.join('layout.css').read
    end

    def javascript
      default_layout_directory.join('layout.js').read
    end

    def headers_template
      default_layout_directory.join('headers_template.html').read
    end

    private

    def default_layout_directory
      Postmortem.root.join('layout')
    end

    def with_inlined_images(body)
      parsed = Nokogiri::HTML.parse(body)
      parsed.css('img').each do |img|
        uri = URI(img['src'])
        next unless local_file?(uri)

        path = located_image(uri)
        img['src'] = encoded_image(path) unless path.nil?
      end
      parsed.to_s
    end

    def local_file?(uri)
      return true if uri.host.nil?
      return true if /^www\.example\.[a-z]+$/.match(uri.host)
      return true if %w[127.0.0.1 localhost].include?(uri.host)

      false
    end

    def located_image(uri)
      path = uri.path.partition('/').last
      common_locations.each do |location|
        full_path = location.join(path)
        next unless full_path.file?

        return full_path
      end

      nil
    end

    def encoded_image(path)
      "data:#{mime_type(path)};base64,#{Base64.encode64(path.read)}"
    end

    def common_locations
      ['public/assets', 'app/assets/images'].map { |path| Pathname.new(path) }
    end

    def mime_type(path)
      extension = path.extname.partition('.').last
      extension == 'jpg' ? 'jpeg' : extension
    end
  end
end
