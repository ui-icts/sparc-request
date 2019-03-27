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

      si = StudyInformation.new(protocol)

      sheet.add_row(
        [si.header_for(:protocol_number), si.protocol_number],
        :style => [@styles.row_header_style, @styles.default],
      )
      sheet.add_row(
        [si.header_for(:enrollment_period), si.enrollment_period],
        :style => [@styles.row_header_style, @styles.default],
      )
      sheet.add_row(
        [si.header_for(:short_title), si.short_title],
        :style => [@styles.row_header_style, @styles.default],
      )
      sheet.add_row(
        [si.header_for(:study_title), si.study_title],
        :style => [@styles.row_header_style, @styles.default],
      )
      sheet.add_row(
        [si.header_for(:funding_source), si.funding_source],
        :style => [@styles.row_header_style, @styles.default],
      )
    end

    def project_roles(protocol, sheet)

      si = StudyInformation.new(protocol)
      si.primary_investigators.each do |c|
        sheet.add_row(
          ["Primary Investigator", c.name,nil,nil,c.email],
          :style => [@styles.row_header_style] + Array.new(4, @styles.default)
        )
      end
      si.additional_contacts.each do |c|
        sheet.add_row(
          [c.role.titleize, c.name,nil,nil,c.email],
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
