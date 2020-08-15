# frozen_string_literal: true

module FixtureHelper
  def fixture(name)
    File.read(File.expand_path(File.join(__dir__, '..', 'fixtures', name.to_s)))
  end
end
