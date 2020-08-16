# frozen_string_literal: true

RSpec.describe 'ActionMailer plugin' do
  before { allow_any_instance_of(Mail::SMTP).to receive(:deliver!) }

  it 'intercepts ActionMailer immediate deliveries' do
    expect(Postmortem).to receive(:record_delivery)
    TestMailer.multipart_email.deliver_now
  end

  it 'intercepts ActionMailer delegated deliveries' do
    expect(Postmortem).to receive(:record_delivery)
    TestMailer.multipart_email.deliver_later
  end
end
