require 'rails_helper'

RSpec.describe CostAnalysis::TableWithGroupHeaders do

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

  context "when column labels are present" do
    
    before do
      subject.add_column_labels []
    end

    it "knows they are the first row" do
      subject.add_header []
      subject.add_data []
      subject.add_data []
      subject.add_summary []
      subject.add_header []
      subject.add_data []
      subject.add_summary []

      expect(subject.header_rows).to contain_exactly(1,5)
      expect(subject.summary_rows).to contain_exactly(4,7)
    end
  end

  describe "#table_rows" do
    it "has all rows" do
      subject.add_header ["A"]
      subject.concat([ ["C"], ["D"], ["E"] ])
      subject.add_summary ["Z"]

      expect(subject.table_rows).to contain_exactly(["A"],
                                                    ["C"],
                                                    ["D"],
                                                    ["E"],
                                                    ["Z"])
    end
  end
end
