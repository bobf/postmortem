# frozen_string_literal: true

require 'tempfile'
require 'pathname'
require 'time'
require 'fileutils'
require 'mail'
require 'erb'
require 'json'

require 'postmortem/version'
require 'postmortem/adapters'
require 'postmortem/delivery'
require 'postmortem/layout'
require 'postmortem/configuration'

# HTML email inspection tool.
module Postmortem
  class Error < StandardError; end

  class << self
    attr_reader :config

    def record_delivery(mail)
      return if mail.empty?

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

    def configure
      @config = Configuration.new
      yield @config if block_given?
    end

    private

    def log_delivery(delivery)
      output_file.write(colorized(delivery.path.to_s) + "\n")
      output_file.flush
    end

    def colorized(val)
      return val unless output_file.tty? || !config.colorize

      "\e[34m[postmortem]\e[36m #{val}\e[0m"
    end

    def output_file
      return STDOUT if config.log_path.nil?

      @output_file ||= File.open(config.log_path, mode: 'a')
    end
  end
end

Postmortem.configure
Postmortem.try_load('action_mailer', 'active_support') { require 'postmortem/action_mailer' }
