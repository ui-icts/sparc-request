class ServiceCalendarsController < ApplicationController
  before_filter :initialize_service_request
  before_filter {|c| params[:portal] == 'true' ? true : c.send(:authorize_identity)}
  layout false
  def table
    #use session so we know what page to show when tabs are switched
    session[:service_calendar_page] = params[:page] if params[:page]

    @tab = params[:tab]
    @portal = params[:portal]
    @page = @service_request.set_visit_page session[:service_calendar_page].to_i
    @candidate_one_time_fees, @candidate_per_patient_per_visit = @sub_service_request.candidate_services.partition {|x| x.is_one_time_fee?} if @sub_service_request
  end

  def update
    @portal = params[:portal]
    visit = Visit.find params[:visit] rescue nil
    @visit_grouping = VisitGrouping.find params[:visit_grouping] rescue nil
    @line_item = LineItem.find params[:line_item] rescue nil
    tab = params[:tab]
    checked = params[:checked]
    qty = params[:qty].to_i
    column = params[:column]

    if tab == 'template' and @visit_grouping
      @visit_grouping.update_attribute(:subject_count, qty)
    elsif tab == 'template' and visit.research_billing_qty.to_i <= 0 and checked == 'true'
      # set quantity and research billing qty to 1
      visit.update_attribute(:quantity, visit.visit_grouping.line_item.service.displayed_pricing_map.unit_minimum)
      visit.update_attribute(:research_billing_qty, visit.visit_grouping.line_item.service.displayed_pricing_map.unit_minimum)
    elsif tab == 'template' and checked == 'false'
      visit.update_attribute(:quantity, 0)
      visit.update_attribute(:research_billing_qty, 0)
      visit.update_attribute(:insurance_billing_qty, 0)
      visit.update_attribute(:effort_billing_qty, 0)
    elsif tab == 'quantity'
      @errors = "Quantity must be greater than zero" if qty < 0
      visit.update_attribute(:quantity, qty) unless qty < 0
    elsif tab == 'billing_strategy'
      @errors = "Quantity must be greater than zero" if qty < 0
      visit.update_attribute(column, qty) unless qty < 0
      #update the total quantity to reflect the 3 billing qty total
      total = visit.research_billing_qty.to_i + visit.insurance_billing_qty.to_i + visit.effort_billing_qty.to_i
      visit.update_attribute(:quantity, total) unless total < 0
    end

    @visit = visit
    @visit_td = visit.nil? ? "" : ".visits_#{visit.id}"
    @visit_grouping = visit.visit_grouping if @visit_grouping.nil?
    @line_item = @visit_grouping.line_item if @line_item.nil?
    @line_item_total_td = ".total_#{@visit_grouping.id}"
    # @displayed_visits = @line_item.visits.paginate(page: params[:page], per_page: 5)
  end

  def rename_visit
    visit_name = params[:name]
    visit_position = params[:visit_position].to_i
    service_request = ServiceRequest.find params[:service_request_id]

    line_items = service_request.per_patient_per_visit_line_items

    line_items.each do |li|
      li.visits[visit_position].update_attribute(:name, visit_name)
    end
  end
end
