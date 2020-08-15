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

  let(:output_directory) { File.join(Dir.tmpdir, 'postmortem-test') }

  before do
    Postmortem.layout = File.expand_path(
      File.join(__dir__, '..', 'support', 'test_layout.html.erb')
    )
  end

  describe '#record' do
    subject(:record) { delivery.record }
    before { Postmortem.output_directory = output_directory }
    before { Timecop.freeze(Time.new(2001, 2, 3, 4, 5, 6)) }
    after { FileUtils.rm_rf(output_directory) }

    it 'saves HTML to disk' do
      record
      path = Pathname.new(output_directory).join('2001-02-03_04-05-06__Email_Subject.html')
      expect(path.read.strip).to eql '<html><body><div>My HTML content</div></body></html>'
    end
  end
end
