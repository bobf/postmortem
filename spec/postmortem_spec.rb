# frozen_string_literal: true

RSpec.describe Postmortem do
  subject { described_class }

  it 'has a version number' do
    expect(Postmortem::VERSION).not_to be nil
  end

  its(:root) { is_expected.to be_a Pathname }

  describe '.record_delivery' do
    let(:preview_directory) { File.join(Dir.tmpdir, 'postmortem-test') }
    let(:filename) { 'index.html' }
    let(:path) { Pathname.new(preview_directory).join(filename) }
    let(:hash) { delivery.id }

    before do
      Postmortem.configure do |config|
        config.preview_directory = preview_directory
        config.layout = File.join(__dir__, 'support', 'test_layout.html.erb')
      end
      allow_any_instance_of(Mail::SMTP).to receive(:deliver!)
      Timecop.freeze(Time.new(2001, 2, 3, 4, 5, 6))
      allow($stdout).to receive(:write)
      allow(delivery).to receive(:html_body=)
    end

    after { FileUtils.rm_rf(preview_directory.to_s) }

    let(:delivery) do
      instance_double(
        Postmortem::Adapters::Base,
        subject: 'My subject',
        html_body: '<div>My HTML content</div>',
        serializable: {},
        id: 'abc-def-123-456'
      )
    end

    it 'intercepts saves deliveries and saves to disk' do
      Postmortem.record_delivery(delivery)
      expect(path.read.strip).to eql '<html><body><div>My HTML content</div></body></html>'
    end

    context 'output is a tty' do
      before { allow($stdout).to receive(:tty?) { true } }

      it 'outputs a colorized URL' do
        expect($stdout).to receive(:write).with("\e[34m[postmortem]\e[36m file://#{path}##{hash}\e[0m\n")
        Postmortem.record_delivery(delivery)
      end
    end

    context 'output is a non-tty file' do
      before { allow($stdout).to receive(:tty?) { false } }

      it 'outputs a URL' do
        expect($stdout).to receive(:write).with("file://#{path}##{hash}\n")
        Postmortem.record_delivery(delivery)
      end
    end
  end
end
