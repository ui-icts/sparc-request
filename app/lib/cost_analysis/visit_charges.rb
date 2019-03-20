module CostAnalysis
  class StudyInformation
  
    ## display_funding_source
    include Dashboard::ProjectsHelper

    HEADERS = {
      :protocol_number => "CRU Protocol #",
      :enrollment_period => "Enrollment Period",
      :short_title => "Short Title",
      :study_title => "Study Title",
      :funding_source => "Funding Source",
      :target_entrollment => "Target Enrollment"
    }

    attr_accessor :protocol_number, :enrollment_period, :short_title, :study_title, :funding_source, :target_enrollment, :contacts

    def initialize(protocol)
      @protocol_number = protocol.id
      @enrollment_period = "#{protocol.start_date.strftime("%m/%d/%Y")}-#{protocol.end_date.strftime("%m/%d/%Y")}"
      @short_title = protocol.short_title
      @study_title = protocol.title
      @funding_source = "#{protocol.sponsor_name} (#{display_funding_source(protocol)})"
      @target_enrollment = ""
      
      @contacts = protocol.project_roles.map do |au|
        ProjectContact.new(au.role, au.identity.full_name, au.identity.email)
      end
    end

    def header_for(field)
      HEADERS[field]
    end

    def primary_investigators
      @contacts.select{ |c| c.pi?}
    end

    def additional_contacts
      @contacts - primary_investigators
    end
  end

  class ProjectContact
    attr_accessor :role, :name, :email

    def initialize(role, name, email)
      @role = role
      @name = name
      @email = email
    end

    def pi?
      @role == "primary-pi"
    end
  end

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
