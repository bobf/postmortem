# frozen_string_literal: true

RSpec.describe 'ActionMailer plugin' do
  # This is a hack which ensures that all dependencies are loaded before we try to stub them.
  before(:all) { TestMailer.multipart_email.deliver_now }

  before { allow_any_instance_of(Mail::SMTP).to receive(:deliver!) }

  context 'actionmailer adapter is :test' do
    let(:application) { double(config: double(action_mailer: double(delivery_method: :test))) }
    before { allow(Rails).to receive(:application) { application } }

    it 'intercepts ActionMailer immediate deliveries' do
      expect(Postmortem).to receive(:record_delivery)
      TestMailer.multipart_email.deliver_now
    end

    it 'intercepts ActionMailer delegated deliveries' do
      expect(Postmortem).to receive(:record_delivery)
      TestMailer.multipart_email.deliver_later
    end
  end

  context 'actionmailer adapter is not :test' do
    it 'delegates to Mail plugin' do
      expect(Postmortem).to_not receive(:record_delivery)
      TestMailer.multipart_email.deliver_later
    end
  end
end
