module CostAnalysis
  class VisitCharges

    include Dashboard::ProjectsHelper

    def initialize(workbook)
      @workbook = workbook
      @styles = WorkbookStyles.new(workbook)
    end

    def study_information(protocol, sheet)
      
      sheet.add_row(
        ["Study Information"],
        :style => @styles.study_information_header
      )

      headers = [
        "CRU Protocol #",
        "Enrollment Period",
        "Short Title",
        "Study Title",
        "Funding Source",
        "Target Enrollment"
      ]
      
      values = [
        protocol.id,
        "#{protocol.start_date.strftime("%m/%d/%Y")}-#{protocol.end_date.strftime("%m/%d/%Y")}",
        protocol.short_title,
        protocol.title,
        "#{protocol.sponsor_name} (#{display_funding_source(protocol)})",
        ""
      ]
      headers.zip(values).each do |row|
        sheet.add_row(
          row,
          :style => [@styles.row_header_style, @styles.default],
        )
      end
    end

    def project_roles(protocol, sheet)

      protocol.project_roles.each do |au|
        sheet.add_row(
          [au.role.titleize, au.identity.full_name,nil,nil,au.identity.email],
          :style => [@styles.row_header_style] + Array.new(4, @styles.default)
        )
      end
    end

    def visit_counts_by_service(protocol, sheet)

      protocol.service_requests.each do |service_request|
        sheet.add_row #table

        bldr = ::CostAnalysis::ServiceRequest.new(service_request, @styles)
        bldr.update(sheet)
        #header row

      end
    end
  end
end
