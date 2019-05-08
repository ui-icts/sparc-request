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
          move_down 5
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
            pdf_table = visit_table.summarized_by_service

            prawn_table = make_table(
              pdf_table.table_rows,
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
                  cells.columns(0).align = :left

                  cells.columns(2..6).align = :right
                  # blue header cells
                  cells.columns(2..-1).rows(0).style({
                    :background_color => "C5D9F1",
                    :align => :center
                  })

                  # core header rows
                  pdf_table.header_rows.each do |hr|
                    cells.columns(0).rows(hr).style({
                      :align => :left,
                      :valign => :middle,
                      :background_color => "E8E8E8"
                    })
                    cells.rows(hr).style(:font_style => :bold)

                  end
                  pdf_table.summary_rows.each do |sr|
                    # cells.columns(0).rows(sr).align = :right
                    cells.columns(0).rows(sr).style(:align => :right)
                    cells.rows(sr).style(:font_style => :bold)
                  end
                  cells.columns(0..1).rows(0).borders = [:bottom]
              end

              unless prawn_table.cells.fits_on_current_page?(cursor, bounds)
                start_new_page
              end
              prawn_table.draw
              move_down 5

          end

          move_down 20

          visit_tables.each do |visit_table|
            visit_table.line_item_detail.split(keep: 5,cols: 14).each do |page|

              prawn_table = make_table(
                page.table_rows,
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
                end #end make_table

                unless prawn_table.cells.fits_on_current_page?(cursor, bounds)
                  start_new_page
                end
                prawn_table.draw
                move_down 5
            end
            # start_new_page
          end

          move_down 20

          investigator_table = make_table(
            primary_investigators + additional_contacts,
            :width => 700,
            :cell_style => {:border_width => 1, :border_color => 'E8E8E8'})

          move_down 20

          unless investigator_table.cells.fits_on_current_page?(cursor, bounds)
            start_new_page
          end

          investigator_table.draw

          move_down 20

          default_leading 3

          bounding_box([100, cursor], :width => 500, :height => 115, :fill => 'E8E8E8') do
            transparent(1.0) {
              stroke_bounds
              fill_color 'd5edda'
              fill_rectangle [0,115], 500, 115
            }
            move_down 5
            text "*These charges are for CRU services only.", :size => 11, :align => :center
            text "If the lab manual is not available during protocol review, lab processing fees will be included as an estimate based on the cost of similar studies.", :size => 11, :align => :center
            text "Prices are valid as of the approval date and effective for up to 12 months after signing.", :size => 11, :align => :center
            text "Any changes to the original I-CART request may result in a new cost analysis.", :size => 11, :align => :center
            text "Modifications and extensions may be subject to price changes reflective of current CRU rates.", :size => 11, :align => :center
            text "Adverse reactions requiring additional time or personnel will be an additional $100/hour.", :size => 11, :align => :center
          end

          number_pages "<page>", {
            :at => [bounds.right - 150, bounds.bottom - 5],
            :width => 150,
            :align => :right,
            :start_count_at => 1,
          }
        end
      end
    end
  end
end
