module CostAnalysis
  class Generator
    attr_writer :protocol

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