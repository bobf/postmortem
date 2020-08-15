# frozen_string_literal: true

RSpec.describe Postmortem do
  subject { described_class }

  let(:preview_directory) { File.join(Dir.tmpdir, 'postmortem-test') }
  let(:path) { Pathname.new(preview_directory).join('2001-02-03_04-05-06__Multipart_email.html') }

  before do
    Postmortem.configure do |config|
      config.preview_directory = preview_directory
      config.layout = File.join(__dir__, 'support', 'test_layout.html.erb')
    end
    allow_any_instance_of(Mail::SMTP).to receive(:deliver!)
    Timecop.freeze(Time.new(2001, 2, 3, 4, 5, 6))
    allow(STDOUT).to receive(:write)
  end

  after { FileUtils.rm_rf(preview_directory.to_s) }

  it 'has a version number' do
    expect(Postmortem::VERSION).not_to be nil
  end

  it 'intercepts ActionMailer immediate deliveries and saves to disk' do
    TestMailer.multipart_email.deliver_now
    expect(path.read.strip).to eql '<html><body><div>My HTML content</div></body></html>'
  end

  it 'intercepts ActionMailer delegated deliveries and saves to disk' do
    TestMailer.multipart_email.deliver_later
    expect(path.read.strip).to eql '<html><body><div>My HTML content</div></body></html>'
  end

  context 'output is a tty' do
    before { allow(STDOUT).to receive(:tty?) { true } }

    it 'intercepts ActionMailer deliveries and outputs a URL' do
      expect(STDOUT).to receive(:write).with("\e[34m[postmortem]\e[36m #{path}\e[0m\n")
      TestMailer.multipart_email.deliver_now
    end
  end

  context 'output is a non-tty file' do
    before { allow(STDOUT).to receive(:tty?) { false } }

    it 'intercepts ActionMailer deliveries and outputs a URL' do
      expect(STDOUT).to receive(:write).with("#{path}\n")
      TestMailer.multipart_email.deliver_now
    end
  end
end
