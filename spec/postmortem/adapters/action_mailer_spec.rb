# frozen_string_literal: true

RSpec.describe Postmortem::Adapters::ActionMailer do
  subject(:adapter) { described_class.new(data) }

  let(:data) do
    {
      from: 'from@example.com',
      to: 'to@example.com',
      cc: 'cc@example.com',
      bcc: 'bcc@example.com',
      subject: 'Email Subject',
      mail: fixture('multipart.eml')
    }
  end

  it { is_expected.to be_a described_class }
  its(:from) { is_expected.to eql 'from@example.com' }
  its(:to) { is_expected.to eql 'to@example.com' }
  its(:cc) { is_expected.to eql 'cc@example.com' }
  its(:bcc) { is_expected.to eql 'bcc@example.com' }
  its(:html_body) { is_expected.to eql '<div>My HTML content</div>' }
end
