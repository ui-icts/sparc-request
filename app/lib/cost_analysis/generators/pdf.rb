module CostAnalysis
  module Generators
    class PDF

      attr_accessor :study_information

      def initialize(doc)
        @doc = doc
      end

      def update

        data = self
        study_information = @study_information
        primary_investigators = study_information.primary_investigators.map{ |p| ["Primary Investigator", p.name, p.email] }
        additional_contacts = study_information.additional_contacts.map{ |p| [p.role.titleize, p.name, p.email] }

        @doc.instance_eval do
          bounding_box([0,y], :width => 700, :height => 50) do
            text "CRU Protocol#: #{study_information.protocol_number}", :align => :left, :valign => :center, :size => 16
            text study_information.enrollment_period, :align => :right, :valign => :top
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

          
          table(
            primary_investigators + additional_contacts,
            :width => 700,
            :cell_style => {:border_width => 1, :border_color => 'E8E8E8'})
        end
      end
    end
  end
end
