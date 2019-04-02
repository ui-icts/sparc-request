require 'rails_helper'

RSpec.describe CostAnalysis::VisitPageData do

  describe "maintaining row counts" do
    it "should report indices for header rows" do

      subject.add_header []
      subject.add_data []
      subject.add_data []
      subject.add_summary []
      subject.add_header []
      subject.add_data []
      subject.add_summary []

      expect(subject.header_rows).to contain_exactly(0,4)
      expect(subject.summary_rows).to contain_exactly(3,6)
    end
  end
end
