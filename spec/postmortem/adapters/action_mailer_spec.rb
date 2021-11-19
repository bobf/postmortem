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
      mail: mail
    }
  end
  let(:mail) { fixture('multipart.eml').read }

  it { is_expected.to be_a described_class }
  its(:from) { is_expected.to eql ['from@example.com'] }
  its(:to) { is_expected.to eql ['to@example.com'] }
  its(:cc) { is_expected.to eql ['cc1@example.com', 'cc2@example.com'] }
  its(:bcc) { is_expected.to eql ['bcc@example.com'] }
  its(:html_body) { is_expected.to eql "<div>My HTML content</div>\n\n" }
  its(:text_body) { is_expected.to eql "My text content\n" }

  describe '#attachments' do
    subject { adapter.attachments.first }

    context 'with attachments' do
      let(:mail) { fixture('attachments.eml').read }

      its(:filename) { is_expected.to eql 'attachment.txt' }
      its(:decoded) { is_expected.to eql "decoded-content\n" }
    end
  end
end
