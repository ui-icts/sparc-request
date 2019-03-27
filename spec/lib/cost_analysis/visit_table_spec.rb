require 'rails_helper'
require 'byebug'
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

  let(:number_of_visits) { 15 }
  let(:visit_table) do
    vt = CostAnalysis::VisitTable.new
    vt.line_items.clear
    vt.visit_labels.clear
    (1..number_of_visits).each do |which|
      vt.visit_labels << "visit-#{which}"
    end
    vt
  end
  let(:visit_columns_per_page) { 1 }
  let(:rows_per_page) { 1 }

  subject { visit_table.paged(visit_columns_per_page: visit_columns_per_page, rows_per_page: rows_per_page).to_a }

  let(:page1) { subject[0] }
  let(:page2) { subject[1] }

  describe "a request with 1 core and 1 line item" do

    setup do
      visit_table.add_line_item "core-1", visit_line_item("service-1", number_of_visits)
    end

    context "there are 15 visits" do

      let(:number_of_visits) { 15 }

      context "visit columns per page is 14 and rows per page is 10" do
        let(:visit_columns_per_page) { 14 }
        let(:rows_per_page) { 4 }

        it { is_expected.to have_exactly(2).items }
        it "should have column labels; core1; service; and summary on each page" do
          expect(page1.data).to have_exactly(4).items
          expect(page2.data).to have_exactly(4).items
        end

        it "should put visit 15 on the 2nd page" do
          expect(page1.data[0]).to end_with("visit-14") # correct visit label
          expect(page2.data[0]).to end_with("visit-15")
        end

      end

      context "visit columns per page is 14 but rows per page is very large" do
        let(:visit_columns_per_page) { 14 }
        let(:rows_per_page) { 400 }

        it "should put everything on the same page" do
          expect(subject).to have_exactly(1).items
        end
      end
    end

  end

  describe "a request with 2 cores 1 line item each" do
    setup do
      visit_table.add_line_item "core-1", visit_line_item("c1-s1", number_of_visits)
      visit_table.add_line_item "core-2", visit_line_item("c2-s1", number_of_visits)
    end
    context "there are 15 visits" do

      let(:number_of_visits) { 15 }

      context "visits columns per page is 14 and rows per page is 10" do

        let(:visit_columns_per_page) { 14 }
        let(:rows_per_page) { 10 }

        it { is_expected.to have_exactly(2).items }

        it "should not have a summary on the first page" do
          expect(page1.data).to have_exactly(6).items #column labels; core1; service1;core2;service2;summary
          expect(page2.data).to have_exactly(6).items
        end

      end

      context "visit columns per page is 50 and rows per page is 100" do
        let(:visit_columns_per_page) { 50 }
        let(:rows_per_page) { 100 }

        it { is_expected.to have_exactly(1).items }

        it "should have column labels;core1;service1;core2;service2;summary" do
          expect(page1.data).to have_exactly(6).items
        end

        it "should have visit 15 as the last column" do
          expect(page1.data[0]).to end_with("visit-15")
        end
      end
    end

  end
end
