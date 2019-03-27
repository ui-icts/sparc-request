require 'rails_helper'

RSpec.describe CostAnalysis::VisitTable do

  def visit_line_item(service, visit_count)

    li = CostAnalysis::VisitLineItem.new
    li.description = service
    li.unit_type = "Sample"
    li.service_rate = 50.0
    li.applicable_rate = 3.0
    li.subjects = 5
    li.visit_counts = Array.new(visit_count) { rand(0...3) }
    li
  end

  context "visits columns per page is 14 and rows per page is 10" do
    let(:visit_columns_per_page) { 14 }
    let(:rows_per_page) { 10 }

    describe "a request with 15 visits" do

      let(:number_of_visits) { 15 }
      let(:visit_table) do
        vt = CostAnalysis::VisitTable.new
        vt.line_items.clear
        vt.visit_labels.clear
        (1..number_of_visits).each do |which|
          vt.visit_labels << "visit-#{which}"
        end
        vt.line_items["core-1"] = []
        vt.line_items["core-1"] << visit_line_item("service-1", number_of_visits)
        vt
      end

      subject { visit_table.paged(visit_columns_per_page: visit_columns_per_page, rows_per_page: rows_per_page).to_a }
      it "should put visit 15 on the 2nd page" do
        expect(subject.size).to eq(2)
        page1 = subject[0]
        page2 = subject[1]

        expect(page1.data.size).to eq(4) #column labels ; core; service; summary
        expect(page2.data.size).to eq(4)

        expect(page1.data[0].last).to eq("visit-14") # correct visit label
        expect(page2.data[0].last).to eq("visit-15")

        puts page1
        puts page2
      end
    end
  end
end
