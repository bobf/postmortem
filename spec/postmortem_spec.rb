# frozen_string_literal: true

RSpec.describe Postmortem do
  it 'has a version number' do
    expect(Postmortem::VERSION).not_to be nil
  end
end
