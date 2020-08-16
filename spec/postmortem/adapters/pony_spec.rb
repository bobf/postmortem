# frozen_string_literal: true

RSpec.describe Postmortem::Adapters::Pony do
  subject(:adapter) { described_class.new(data) }

  let(:data) do
    {
      from: 'from@example.com',
      reply_to: 'reply-to@example.com',
      to: 'to@example.com',
      cc: 'cc@example.com',
      bcc: 'bcc@example.com',
      subject: 'Email Subject',
      body: 'My text content',
      html_body: '<div>My HTML content</div>'
    }
  end

  it { is_expected.to be_a described_class }
  its(:from) { is_expected.to eql ['from@example.com'] }
  its(:to) { is_expected.to eql ['to@example.com'] }
  its(:cc) { is_expected.to eql ['cc@example.com'] }
  its(:bcc) { is_expected.to eql ['bcc@example.com'] }
  its(:text_body) { is_expected.to eql 'My text content' }
  its(:html_body) { is_expected.to eql '<div>My HTML content</div>' }
end
