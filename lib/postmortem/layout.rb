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

    def css_dependencies
      default_layout_directory.join('dependencies.css').read
    end

    def javascript_dependencies
      default_layout_directory.join('dependencies.js').read
    end

    def headers_template
      default_layout_directory.join('headers_template.html').read
    end

    def favicon_b64
      default_layout_directory.join('favicon.b64').read
    end

    def upload_url
      ENV.fetch('POSTMORTEM_DELIVERY_URL', 'https://postmortem.delivery/emails')
    end

    private

    def default_layout_directory
      Postmortem.root.join('layout')
    end

    def with_inlined_images(body)
      parsed = Nokogiri::HTML.parse(body)
      parsed.css('img').each do |img|
        uri = extract_image_uri(img)
        next unless local_file?(uri)

        path = located_image(uri)
        img['src'] = encoded_image(path) unless path.nil?
      end
      parsed.to_s
    end

    def extract_image_uri(img)
      src_uri = try_uri(img['src'])
      return src_uri if src_uri&.path.present?

      original_src_uri = try_uri(img['data-originalsrc'])
      return original_src_uri if original_src_uri&.path.present?

      nil
    end

    def local_file?(uri)
      return false if uri.nil?
      return true if uri.host.nil?
      return true if /^www\.example\.[a-z]+$/.match(uri.host)
      return true if %w[127.0.0.1 localhost].include?(uri.host)

      false
    end

    def try_uri(uri)
      URI(uri)
    rescue URI::InvalidURIError
      nil
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
