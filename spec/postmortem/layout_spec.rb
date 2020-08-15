# frozen_string_literal: true

RSpec.describe Postmortem::Layout do
  subject(:layout) { described_class.new(body) }

  let(:body) { '<div>My HTML content</div>' }

  it { is_expected.to be_a described_class }
  its(:content) { is_expected.to eql "<html><body><div>My HTML content</div></body></html>\n" }
end
