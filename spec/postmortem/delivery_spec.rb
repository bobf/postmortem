# frozen_string_literal: true

RSpec.describe Postmortem::Delivery do
  subject(:delivery) { described_class.new(mail) }

  let(:mail) do
    instance_double(
      Postmortem::Adapters::Base,
      subject: email_subject,
      html_body: '<div>My HTML content</div>'
    )
  end

  let(:email_subject) { 'Email subject' }

  it { is_expected.to be_a described_class }
  its(:path) { is_expected.to be_a Pathname }

  let(:preview_directory) { File.join(Dir.tmpdir, 'postmortem-test') }

  before do
    Postmortem.configure do |config|
      config.layout = File.expand_path(
        File.join(__dir__, '..', 'support', 'test_layout.html.erb')
      )
      config.preview_directory = preview_directory
    end
  end

  describe '#record' do
    subject(:record) { delivery.record }
    let(:expected_content) { '<html><body><div>My HTML content</div></body></html>' }
    let(:path) { Pathname.new(preview_directory).join(expected_filename) }
    let(:expected_filename) { '2001-02-03_04-05-06__Email_Subject.html' }

    before { Timecop.freeze(Time.new(2001, 2, 3, 4, 5, 6)) }
    after { FileUtils.rm_rf(preview_directory) }

    it 'saves HTML to disk' do
      record
      expect(path.read.strip).to eql expected_content
    end

    context 'no subject' do
      let(:email_subject) { nil }
      let(:expected_filename) { '2001-02-03_04-05-06__no-subject.html' }
      it 'uses a default subject' do
        record
        expect(path.read.strip).to eql expected_content
      end
    end
  end
end
