# frozen_string_literal: true

RSpec.describe Postmortem::Delivery do
  subject(:delivery) { described_class.new(mail) }

  let(:mail) do
    instance_double(
      Postmortem::Adapters::Base,
      subject: email_subject,
      html_body: '<div>My HTML content</div>',
      serializable: {}
    )
  end

  let(:email_subject) { 'Email subject' }
  let(:timestamp) { true }
  let(:token) { true }

  it { is_expected.to be_a described_class }
  its(:path) { is_expected.to be_a Pathname }
  its(:index_path) { is_expected.to be_a Pathname }

  let(:preview_directory) { File.join(Dir.tmpdir, 'postmortem-test') }

  before do
    Postmortem.configure do |config|
      config.layout = File.expand_path(
        File.join(__dir__, '..', 'support', 'test_layout.html.erb')
      )
      config.preview_directory = preview_directory
      config.timestamp = timestamp
      config.token = token
    end
  end

  describe '#record' do
    subject(:record) { delivery.record }
    let(:expected_content) { '<html><body><div>My HTML content</div></body></html>' }
    let(:index_path) { Pathname.new(preview_directory).join('index.html') }
    let(:path) { Pathname.new(preview_directory).join(expected_filename) }
    let(:expected_filename) { '2001-02-03_04-05-06__random-token__Email_Subject.html' }

    before { Timecop.freeze(Time.new(2001, 2, 3, 4, 5, 6)) }
    before { allow(SecureRandom).to receive(:hex) { 'random-token' } }
    after { FileUtils.rm_rf(preview_directory) }

    it 'saves HTML to disk' do
      record
      expect(path.read.strip).to eql expected_content
    end

    it 'creates index HTML file when not present' do
      record
      expect(index_path).to be_file
    end

    it 'updates index HTML file when already present' do
      record
      Timecop.freeze(Time.new(2001, 2, 3, 4, 5, 7))
      described_class.new(mail).record
      puts index_path.read
      expect(index_path.read).to include fixture('index.html').read
    end

    context 'no timestamps' do
      let(:timestamp) { false }
      let(:expected_filename) { 'random-token__Email_Subject.html' }
      it 'creates preview without timestamp' do
        record
        expect(path).to be_file
      end
    end

    context 'no random token' do
      let(:token) { false }
      let(:expected_filename) { '2001-02-03_04-05-06__Email_Subject.html' }
      it 'creates preview without timestamp' do
        record
        expect(path).to be_file
      end
    end

    context 'no subject' do
      let(:email_subject) { nil }
      let(:expected_filename) { '2001-02-03_04-05-06__random-token__no-subject.html' }
      it 'uses a default subject' do
        record
        expect(path.read.strip).to eql expected_content
      end
    end
  end
end
