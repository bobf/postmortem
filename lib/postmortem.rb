# frozen_string_literal: true

require 'tempfile'
require 'pathname'
require 'time'
require 'fileutils'
require 'mail'
require 'erb'

require 'postmortem/version'
require 'postmortem/adapters'
require 'postmortem/delivery'
require 'postmortem/layout'

# HTML email inspection tool.
module Postmortem
  class Error < StandardError; end

  class << self
    attr_reader :output_directory, :layout
    attr_accessor :output_file

    def output_directory=(val)
      @output_directory = Pathname.new(val)
    end

    def layout=(val)
      @layout = Pathname.new(val)
    end

    def record_delivery(mail)
      Delivery.new(mail)
              .tap(&:record)
              .tap { |delivery| log_delivery(delivery) }
    end

    def try_load(*args)
      args.each { |arg| require arg }
    rescue LoadError
      false
    else
      yield
      true
    end

    private

    def log_delivery(delivery)
      output_file.write("#{delivery.path}\n")
      output_file.flush
    end
  end
end

Postmortem.output_directory = File.join(Dir.tmpdir, 'postmortem')
Postmortem.output_file = STDOUT
Postmortem.layout = File.expand_path(File.join(__dir__, '..', 'layout', 'default.html.erb'))
Postmortem.try_load('action_mailer', 'active_support') { require 'postmortem/action_mailer' }
