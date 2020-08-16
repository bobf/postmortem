# frozen_string_literal: true

RSpec.describe 'Pony plugin' do
  before { allow_any_instance_of(Mail::SMTP).to receive(:deliver!) }
  before { allow(Postmortem).to receive(:record_delivery) }

  let(:send_email) do
    Pony.mail(
      to: 'user@example.com',
      via: :smtp,
      via_options: { address: 'smtp.example.com' }
    )
  end

  context 'skip delivery is true' do
    before { Postmortem.configure { |config| config.pony_skip_delivery = true } }

    it 'intercepts Pony deliveries' do
      expect(Postmortem).to receive(:record_delivery)
      send_email
    end

    it 'intercepts Pony deliveries' do
      expect_any_instance_of(Mail::SMTP).to_not receive(:deliver!)
      send_email
    end
  end

  context 'delivery enabled' do
    before { Postmortem.configure { |config| config.pony_skip_delivery = false } }

    it 'intercepts Pony deliveries' do
      expect(Postmortem).to receive(:record_delivery)
      send_email
    end

    it 'does not deliver emails' do
      expect_any_instance_of(Mail::SMTP).to receive(:deliver!)
      send_email
    end
  end
end
