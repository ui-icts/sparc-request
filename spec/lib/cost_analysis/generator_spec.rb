require 'rails_helper'

RSpec.describe CostAnalysis::Generator do

  let(:protocol) { build(:protocol) }

  it 'should render into a workbook' do
    wb = spy('Axlsx::Workbook')
    subject.protocol = protocol
    subject.to_workbook(wb)
    
    expect(wb).to have_received(:add_worksheet).with(name: 'Report')
  end
end
