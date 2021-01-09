# frozen_string_literal: true

RSpec.describe 'Pony plugin' do
  before { allow(Postmortem).to receive(:record_delivery) }

  let(:send_email) do
    Pony.mail(to: 'user@example.com')
  end

  context 'skip delivery is true' do
    before { Postmortem.configure { |config| config.mail_skip_delivery = true } }

    it 'intercepts Pony deliveries' do
      expect(Postmortem).to receive(:record_delivery)
      send_email
    end

    it 'does not deliver emails' do
      expect(Pony).to_not receive(:_original_mail)
      send_email
    end
  end

  context 'delivery enabled' do
    before { Postmortem.configure { |config| config.mail_skip_delivery = false } }

    it 'intercepts Pony deliveries' do
      allow(Pony).to receive(:_original_mail)
      expect(Postmortem).to receive(:record_delivery)
      send_email
    end

    it 'delivers emails' do
      expect(Pony).to receive(:_original_mail)
      send_email
    end
  end
end
