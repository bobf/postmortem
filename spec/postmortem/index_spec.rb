# frozen_string_literal: true

RSpec.describe Postmortem::Index do
  subject(:index) { described_class.new(index_path, mail_path, timestamp, email_subject) }

  before { Timecop.freeze(Time.new(2001, 2, 3, 4, 5, 6)) }
  let(:timestamp) { Time.now }
  let(:email_subject) { 'My email subject' }

  let(:index_path) { instance_double(Pathname) }
  let(:mail_path) { instance_double(Pathname, to_s: '/example/mail/path.html') }

  it { is_expected.to be_a described_class }

  context 'index exists' do
    before { allow(index_path).to receive(:file?) { true } }
    before { allow(index_path).to receive(:read) { index_content } }
    let(:index_content) do
      [
        '### INDEX START',
        encoded_path('/example/mail/1'),
        encoded_path('/example/mail/2'),
        '### INDEX END'
      ].join("\n")
    end
    its(:content) { is_expected.to include encoded_path('/example/mail/path.html') }
    its(:content) { is_expected.to include encoded_path('/example/mail/1') }
    its(:content) { is_expected.to include encoded_path('/example/mail/2') }
    its(:content) { is_expected.to include "### INDEX START\n" }
    its(:content) { is_expected.to include "### INDEX END\n" }
  end

  context 'index does not exist' do
    before { allow(index_path).to receive(:file?) { false } }
    its(:content) { is_expected.to include encoded_path('/example/mail/path.html') }
    its(:content) { is_expected.to include "### INDEX START\n" }
    its(:content) { is_expected.to include "### INDEX END\n" }
  end

  def encoded_path(path)
    Base64.urlsafe_encode64([email_subject, timestamp.iso8601, path].to_json)
  end
end
