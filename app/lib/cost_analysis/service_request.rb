module CostAnalysis

  class ServiceRequest
    def initialize(service_request, styles=nil)
      @service_request = service_request
      @styles = styles
    end

    def visits
      Enumerator.new do |yielder|
        @service_request.arms.each do |arm|
          visit_labels = arm.visit_groups.map { |vg| "#{vg.name}\nDay#{vg.day}" }
          yielder << [visit_labels, line_items(arm)]
        end
      end
    end

    def line_items(arm)
      Enumerator.new do |yielder|
        @service_request.arms.each do |arm|
          pppv_line_item_visits(arm).each do |ssr, livs|
            program_or_core = display_org_name_text(livs[0].line_item.service.organization_hierarchy, ssr, true)
            #This is each line
            livs.each do |liv|

              vli = VisitLineItem.new
              vli.description = liv.line_item.service.display_service_name
              vli.unit_type = display_unit_type(liv)
              vli.service_rate = display_service_rate(liv.line_item)
              vli.applicable_rate = Service.cents_to_dollars(liv.line_item.applicable_rate)
              vli.subjects = liv.subject_count

              vli.visit_counts = eager_loaded_visits(liv).map do |v|
                v.research_billing_qty + v.insurance_billing_qty
              end

              yielder << [program_or_core, vli]
            end
          end
        end
      end
    end

    private

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