module CostAnalysis
  class Generator
    attr_writer :protocol
    def to_workbook(workbook)

      output = VisitCharges.new(workbook)
      styles = WorkbookStyles.new(workbook)

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

    def to_pdf(doc)
      pdf = CostAnalysis::Generators::PDF.new(doc)
      pdf.study_information = CostAnalysis::StudyInformation.new(@protocol)


      @protocol.service_requests.each do |sr|
        service_request = CostAnalysis::ServiceRequest.new(sr)

        service_request.visits.each do |visit_labels, line_items|
          table = CostAnalysis::VisitTable.new
          table.visit_labels = visit_labels
          line_items.each do |core, line_item|
            table.add_line_item core, line_item
          end
          pdf.visit_tables << table
        end

      end
      pdf.update
    end

    def preview(thing)
      case thing
      when :pdf
        pdf = Prawn::Document.new(:page_layout => :landscape)
        to_pdf(pdf)
        pdf.render_file("preview.pdf")
        `open preview.pdf`
      end
    end
  end
end
