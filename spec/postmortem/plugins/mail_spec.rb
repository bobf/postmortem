# frozen_string_literal: true

RSpec.describe 'Mail plugin' do
  before { allow(Postmortem).to receive(:record_delivery) }

  let(:send_email) do
    Mail.new(to: 'user@example.com').deliver
  end

  context 'skip delivery is true' do
    before { Postmortem.configure { |config| config.mail_skip_delivery = true } }

    it 'intercepts Mail deliveries' do
      expect(Postmortem).to receive(:record_delivery)
      send_email
    end

    it 'does not deliver emails' do
      expect_any_instance_of(Mail::SMTP).to_not receive(:_original_deliver!)
      send_email
    end

    describe 'Pony mail integration' do
      # Pony mail uses Mail for SMTP so this is just a bonus integration test.
      it 'intercepts Pony deliveries' do
        require 'pony'
        expect(Postmortem).to receive(:record_delivery)
        Pony.mail(to: 'user@example.com', via: :smtp)
      end
    end
  end

  context 'delivery enabled' do
    before { Postmortem.configure { |config| config.mail_skip_delivery = false } }

    it 'intercepts Mail deliveries' do
      allow_any_instance_of(Mail::SMTP).to receive(:_original_deliver!)
      expect(Postmortem).to receive(:record_delivery)
      send_email
    end

    it 'delivers emails' do
      expect_any_instance_of(Mail::SMTP).to receive(:_original_deliver!)
      send_email
    end
  end
end
