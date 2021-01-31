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
    end
  end

  describe '#record' do
    subject(:record) { delivery.record }
    let(:expected_content) { '<html><body><div>My HTML content</div></body></html>' }
    let(:index_path) { Pathname.new(preview_directory).join('postmortem_index.html') }
    let(:identity_path) { Pathname.new(preview_directory).join('postmortem_identity.html') }
    let(:path) { Pathname.new(preview_directory).join('index.html') }

    before { Timecop.freeze(Time.new(2001, 2, 3, 4, 5, 6)) }
    after { FileUtils.rm_rf(preview_directory) }

    it 'saves view HTML to disk' do
      record
      expect(path.read.strip).to eql expected_content
    end

    it 'writes id HTML file when not present' do
      record
      expect(identity_path).to be_file
    end

    it 'creates index HTML file when not present' do
      record
      expect(index_path).to be_file
    end

    it 'updates index HTML file when already present' do
      record
      Timecop.freeze(Time.new(2001, 2, 3, 4, 5, 7))
      described_class.new(mail).record
      expect(index_path.read).to include fixture('postmortem_index.html').read
    end
  end
end
