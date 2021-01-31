# frozen_string_literal: true

RSpec.describe Postmortem::Identity do
  subject(:identity) { described_class.new }

  it { is_expected.to be_a described_class }

  its(:content) { is_expected.to include 'window.location.reload()' }
  its(:content) { is_expected.to include 'data-uuid=' }
end
