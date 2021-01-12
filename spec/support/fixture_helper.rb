# frozen_string_literal: true

module FixtureHelper
  def fixture(name)
    Pathname.new(File.expand_path(File.join(__dir__, '..', 'fixtures', name.to_s)))
  end
end
