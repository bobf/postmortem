# frozen_string_literal: true

RSpec.describe Postmortem::Delivery do
  subject(:delivery) { described_class.new(mail) }

  let(:mail) do
    instance_double(
      Postmortem::Adapters::Base,
      subject: 'Email Subject',
      html_body: '<div>My HTML content</div>'
    )
  end

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
    before { Timecop.freeze(Time.new(2001, 2, 3, 4, 5, 6)) }
    after { FileUtils.rm_rf(preview_directory) }

    it 'saves HTML to disk' do
      record
      path = Pathname.new(preview_directory).join('2001-02-03_04-05-06__Email_Subject.html')
      expect(path.read.strip).to eql '<html><body><div>My HTML content</div></body></html>'
    end
  end
end
