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

          visit_table_style = {
            :size => 8,
            :padding => 3,
            :align => :center,
            :overflow => :shrink_to_fit,
            :valign => :middle,
            :single_line => true,
            :border_width => 1,
            :border_color => '4c4c4c'
          }

          arm_colors = %w( 91c6d8 febc7a 8bcba5 e8aaaf )
          arm_mod = -1

          visit_tables.each do |visit_table|
            arm_mod += 1

            summary_table_data = visit_table.summarized_by_service

            summary_table = make_table(
              summary_table_data.table_rows,
              :cell_style => visit_table_style, :header => true) do
                cells.columns(0).align = :left
                cells.columns(0..-1).rows(0).style({
                  :background_color => arm_colors[arm_mod % arm_colors.size]
                })
                cells.columns(2..6).align = :right
                # blue header cells
                cells.columns(2..-1).rows(0).style({
                  # :background_color => "C5D9F1",
                  :align => :center
                })

                # core header rows
                summary_table_data.header_rows.each do |hr|
                  cells.columns(0).rows(hr).style({
                    :align => :left,
                    :valign => :middle,
                    :background_color => "E8E8E8"
                  })
                  cells.rows(hr).style(:font_style => :bold)

                end
                summary_table_data.summary_rows.each do |sr|
                  # cells.columns(0).rows(sr).align = :right
                  cells.columns(0).rows(sr).style(:align => :right)
                  cells.rows(sr).style(:font_style => :bold)
                end
            end

            unless summary_table.cells.fits_on_current_page?(cursor, bounds)
              start_new_page
            end

            summary_table.draw

            move_down 5

            visit_table.line_item_detail.split(keep: 5,cols: 14).each do |page|

              detail_table = make_table(
                page.table_rows,
                :cell_style => visit_table_style, :header => true) do

                  # service & core rows
                  cells.columns(0).align = :left
                  cells.columns(0..-1).rows(0).style({
                    :background_color => arm_colors[arm_mod % arm_colors.size]
                  })

                  # blue header cells
                  cells.columns(2..-1).rows(0).style({
                    # :background_color => "C5D9F1",
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

                end #end make_table

                unless detail_table.cells.fits_on_current_page?(cursor, bounds)
                  start_new_page
                end
                detail_table.draw
                move_down 5
            end
            move_down 5
          end

          move_down 20

          investigator_table = make_table(
            primary_investigators + additional_contacts,
            :width => 700,
            :cell_style => {:border_width => 1, :border_color => 'E8E8E8'})

          move_down 20

          disclaimer_lines = I18n.t(:disclaimer,scope: [:reporting,:cost_analysis])
          disclaimer_height = disclaimer_lines.map{ |l| 20 }.sum
          fit_table_and_disclaimer = investigator_table.cells.height_with_span + disclaimer_height < (investigator_table.cells[0,0].y + cursor) - bounds.absolute_bottom

          unless fit_table_and_disclaimer
            start_new_page
          end

          investigator_table.draw

          move_down 20

          default_leading 3

          bounding_box([100, cursor], :width => 500, :height => disclaimer_height, :fill => 'E8E8E8') do
            transparent(1.0) {
              stroke_bounds
              fill_color 'd5edda'
              fill_rectangle [0,disclaimer_height], 500, disclaimer_height
            }
            move_down 5
            I18n.t(:disclaimer,scope: [:reporting,:cost_analysis]).each do |line|
              text line, :size => 11, :align => :center
            end
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
