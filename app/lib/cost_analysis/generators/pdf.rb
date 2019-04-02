module CostAnalysis
  module Generators
    class PDF

      attr_accessor :study_information, :visit_tables

      def initialize(doc)
        @doc = doc
        @visit_tables = []
      end

      def update

        data = self
        study_information = @study_information
        primary_investigators = study_information.primary_investigators.map{ |p| ["Primary Investigator", p.name, p.email] }
        additional_contacts = study_information.additional_contacts.map{ |p| [p.role.titleize, p.name, p.email] }
        visit_tables = @visit_tables

        @doc.instance_eval do
          bounding_box([0,y], :width => 700, :height => 50) do
            text "CRU Protocol#: #{study_information.protocol_number}", :align => :left, :valign => :center, :size => 16
            text study_information.enrollment_period, :align => :right, :valign => :top
            study_information.primary_investigators.each do |pi|
              text pi.name, :align => :right, :valign => :bottom
            end
          end
          stroke_horizontal_rule

          move_down 30

          text study_information.short_title
          move_down 10
          indent(10) {
            text study_information.study_title, :style => :italic, :size => 10
          }
          move_down 10
          text "Funded by #{study_information.funding_source}"

          move_down 20

          visit_tables.each do |visit_table|


          end
          visit_tables.each do |visit_table|
            visit_table.paged(visit_columns_per_page: 14, rows_per_page: 20).each do |page|

              table(
                page.data,
                :cell_style => {
                  :size => 8,
                  :padding => 3,
                  :align => :center,
                  :overflow => :shrink_to_fit,
                  :valign => :middle,
                  :single_line => true,
                  :border_width => 1,
                  :border_color => '4c4c4c'
                }, :header => true) do
                  # service & core rows
                  cells.columns(0).align = :left

                  # blue header cells
                  cells.columns(2..-1).rows(0).style({
                    :background_color => "C5D9F1",
                    :align => :center
                  })

                  # core header rows
                  page.header_rows.each do |hr|
                    cells.columns(0).rows(hr).style({
                      :align => :left,
                      :valign => :middle,
                      :background_color => "E8E8E8"
                    })
                    cells.rows(hr).style(:font_style => :bold)

                  end
                  page.summary_rows.each do |sr|
                    # cells.columns(0).rows(sr).align = :right
                    cells.columns(0).rows(sr).style(:align => :right)
                    cells.rows(sr).style(:font_style => :bold)
                  end
                  cells.columns(0..1).rows(0).borders = [:bottom]
                end
                move_down 5
                # start_new_page
            end
          end

          move_down 20

          table(
            primary_investigators + additional_contacts,
            :width => 700,
            :cell_style => {:border_width => 1, :border_color => 'E8E8E8'})


        end
      end
    end
  end
end
