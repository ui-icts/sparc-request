module CostAnalysis

  class WorkbookStyles
    attr_reader :row_header_style, :table_header_style, :default, :money,:visit_header
    def initialize(wb)

      @row_header_style = wb.styles.add_style b: true, wrap_text: true, sz: 12
      @table_header_style = wb.styles.add_style sz: 12, b: true,   alignment: { horizontal: :center, wrap_text: true}
      @default = wb.styles.add_style alignment: { horizontal: :left }

      @money = wb.styles.add_style(
        b: true,
        sz: 10,
        format_code: '$#,###,##0',
        border: Axlsx::STYLE_THIN_BORDER
      )

      @visit_header = wb.styles.add_style(
        sz: 10,
        b: true,
        alignment: {horizontal: :center, wrap_text: true},
        border: Axlsx::STYLE_THIN_BORDER,
        bg_color: "C5D9F1")
    end
  end

  class ServiceRequest
    def initialize(service_request, styles)
      @service_request = service_request
      @styles = styles
    end

    def update(sheet) #workbook

      row_header_style = @styles.row_header_style
      table_header_style = @styles.table_header_style
      default = @styles.default

      @service_request.arms.each do |arm|
        headers = [
          "Service Name", #service
          "Service\nRate",
          "Your\nCost",
          "Clinical Qty Type",
          "Subjects"
        ] + arm.visit_groups.map { |vg| "#{vg.name}\nDay#{vg.day}" } + [
          "Per Patient",
          "Per Study"
        ]

        sheet.add_row headers, :style => Array.new(5,table_header_style) + Array.new(headers.size-5, @styles.visit_header)

        visit_per_patient_totals = []
        visit_all_patients_totals = []

        pppv_line_item_visits(arm).each do |ssr, livs|

          #Header row that lists the program > core > service tree
          sheet.add_row [display_org_name_text(livs[0].line_item.service.organization_hierarchy, ssr, true)], :style => row_header_style

          #This is each line
          livs.each do |liv|

            first_in_row = liv.line_item.service.display_service_name
            unless liv.line_item.service.is_available
              first_in_row += inactive_tag
            end

            row = [
              first_in_row,
              display_service_rate(liv.line_item),
              Service.cents_to_dollars(liv.line_item.applicable_rate),
              display_unit_type(liv),
              liv.subject_count
            ]

            # visits is visit 1, visit 2, visit N...
            visits = eager_loaded_visits(liv)

            line_per_patient_total = 0
            line_per_study_total = 0
            # building the columns for each visit on the line
            row += visits.to_enum.with_index(0).map do |v, visit_index|

              qty = v.research_billing_qty + v.insurance_billing_qty
              
              per_patient = qty * liv.line_item.applicable_rate

              #add to the per patient total for this line
              #TODO: Which cost to use here? I think applicable rate?
              line_per_patient_total += per_patient
              #add to the per study total for this line
              line_per_study_total += liv.subject_count * liv.line_item.applicable_rate

              #add to per patient total for whole visit (all services)
              visit_per_patient_totals[visit_index] ||= 0
              visit_per_patient_totals[visit_index] += per_patient
              
              #add to all patients total for whole visit (all services)
              qty > 0 ? qty : ""

            end
            row << line_per_patient_total
            row << line_per_study_total

            row_styles = Array.new(row.size,nil)
            row_styles[-2] = @styles.money
            row_styles[-1] = @styles.money
            sheet.add_row row, :style => row_styles
          end
        end # end of visit line items

        # Summarizing the visit
        sheet.add_row(
          Array.new(5,nil) + headers[5..-3],
          :style => Array.new(5,nil) + Array.new(visit_per_patient_totals.size,@styles.visit_header),
          :widths => Array.new(5,:ignore) + Array.new(visit_per_patient_totals.size,:auto)
        )

        visit_summary_style = Array.new(5,nil) + Array.new(visit_per_patient_totals.size,@styles.money)
        #print row of per patien totals by visit
        sheet.add_row(
          Array.new(5,"") + visit_per_patient_totals, 
          :style => visit_summary_style,
          :widths => Array.new(5,:ignore) + Array.new(visit_per_patient_totals.size,:auto)
        )

        #print row of all patients totals by visit
        sheet.add_row( Array.new(5,"") + visit_per_patient_totals.map{|v| v * arm.subject_count }, :style => visit_summary_style)
      end
    end

    def pppv_line_item_visits(arm)

      Dashboard::ServiceCalendars.pppv_line_items_visits_to_display(
        arm, 
        @service_request,
        nil,
        merged: true,
        statuses_hidden: nil,
        display_all_services: true)
    end

    def eager_loaded_visits(liv)

      liv.ordered_visits.eager_load(
        line_items_visit: {
          line_item: [
            :admin_rates,
            service_request: :protocol,
            service: [
              :pricing_maps,
              organization: [
                :pricing_setups,
                parent: [
                  :pricing_setups,
                  parent: [
                    :pricing_setups,
                    :parent
                  ]
                ]
              ]
            ]
          ]
        }
      )
    end

    def display_org_name_text(org_name, ssr, locked)
      header  = org_name + (ssr.ssr_id ? " (#{ssr.ssr_id})" : "")
      header
    end

    def display_service_rate line_item
      full_rate = line_item.service.displayed_pricing_map.full_rate

      Service.cents_to_dollars(full_rate)
    end
    def display_unit_type(liv)
      liv.line_item.service.displayed_pricing_map.unit_type.gsub("/", "/ ")
    end
  end
end
