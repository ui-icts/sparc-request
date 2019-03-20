module CostAnalysis
  class Generator
    attr_writer :protocol
    def to_workbook(workbook)

      output = ::CostAnalysis::VisitCharges.new(workbook)
      styles = ::CostAnalysis::WorkbookStyles.new(workbook)

      row_header_style = styles.row_header_style
      default = styles.default

      workbook.add_worksheet(name: "Report") do |sheet|

        output.study_information(@protocol, sheet)

        sheet.add_row
        sheet.add_row

        output.project_roles(@protocol, sheet)

        sheet.add_row
        sheet.add_row

        output.visit_counts_by_service(@protocol,sheet)

        sheet.column_widths nil, 5
      end
    end
  end
end
