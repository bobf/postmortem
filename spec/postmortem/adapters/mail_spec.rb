# frozen_string_literal: true

RSpec.describe Postmortem::Adapters::Mail do
  subject(:adapter) { described_class.new(mail) }

  let(:mail) do
    instance_double(
      ::Mail::Message,
      {
        from: 'from@example.com',
        reply_to: 'reply-to@example.com',
        to: 'to@example.com',
        cc: 'cc@example.com',
        bcc: 'bcc@example.com',
        subject: 'Email Subject',
        text_part: double(decoded: 'My text content'),
        html_part: double(decoded: '<div>My HTML content</div>'),
        message_id: 'abc-123',
        has_content_type?: false,
        multipart?: true,
        attachments: [attachment]
      }
    )
  end
  let(:attachment) do
    instance_double(::Mail::Part, filename: 'example.png', decoded: 'decoded-image')
  end

  it { is_expected.to be_a described_class }
  its(:from) { is_expected.to eql 'from@example.com' }
  its(:to) { is_expected.to eql 'to@example.com' }
  its(:cc) { is_expected.to eql 'cc@example.com' }
  its(:bcc) { is_expected.to eql 'bcc@example.com' }
  its(:text_body) { is_expected.to eql 'My text content' }
  its(:html_body) { is_expected.to eql '<div>My HTML content</div>' }

  describe '#attachments' do
    subject { adapter.attachments.first }

    its(:filename) { is_expected.to eql 'example.png' }
    its(:decoded) { is_expected.to eql 'decoded-image' }
  end
end
