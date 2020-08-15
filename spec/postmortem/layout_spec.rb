# frozen_string_literal: true

RSpec.describe Postmortem::Layout do
  subject(:layout) { described_class.new(adapter) }

  before do
    Postmortem.configure do |config|
      config.layout = File.expand_path(
        File.join(__dir__, '..', 'support', 'test_layout.html.erb')
      )
    end
  end

  let(:adapter) do
    instance_double(
      Postmortem::Adapters::Base,
      html_body: '<div>My HTML content</div>'
    )
  end

  it { is_expected.to be_a described_class }
  its(:content) { is_expected.to eql "<html><body><div>My HTML content</div></body></html>\n" }
end
