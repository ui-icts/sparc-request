class VisitGrouping < ActiveRecord::Base
  belongs_to :arm
  belongs_to :line_item

  has_many :visits, :dependent => :destroy, :order => 'position'

  attr_accessible :arm_id
  attr_accessible :line_item_id
  attr_accessible :subject_count

  # Returns the cost per unit based on a quantity (usually just the quantity on the line_item)
  def per_unit_cost quantity_total=self.quantity
    if quantity_total == 0 || quantity_total.nil?
      0
    else
      units_per_package = self.units_per_package
      packages_we_have_to_get = (quantity_total.to_f / units_per_package.to_f).ceil
      total_cost = packages_we_have_to_get.to_f * self.line_item.applicable_rate.to_f
      ret_cost = total_cost / quantity_total.to_f
      unless self.line_item.units_per_quantity.blank?
        ret_cost = ret_cost * self.line_item.units_per_quantity
      end
      return ret_cost
    end
  end

  def units_per_package
    unit_factor = self.line_item.service.displayed_pricing_map.unit_factor
    units_per_package = unit_factor || 1
    return units_per_package
  end

  def quantity_total
    # quantity_total = self.visits.map {|x| x.research_billing_qty}.inject(:+) * self.subject_count
    quantity_total = self.visits.sum('research_billing_qty')
    return quantity_total * self.subject_count
  end

  # Returns a hash of subtotals for the visits in the line item.
  # Visit totals depend on the quantities in the other visits, so it would be clunky
  # to compute one visit at a time
  def per_subject_subtotals(visits=self.visits)
    totals = { }
    quantity_total = quantity_total()
    per_unit_cost = per_unit_cost(quantity_total)

    visits.each do |visit|
      totals[visit.id.to_s] = visit.cost(per_unit_cost)
    end

    return totals
  end

  # Determine the direct costs for a visit-based service for one subject
  def direct_costs_for_visit_based_service_single_subject
    # TODO: use sum() here
    # totals_array = self.per_subject_subtotals(visits).values.select {|x| x.class == Float}
    # subject_total = totals_array.empty? ? 0 : totals_array.inject(:+)
    result = self.connection.execute("SELECT SUM(research_billing_qty) FROM visits WHERE visit_grouping_id=#{self.id} AND research_billing_qty >= 1")
    research_billing_qty_total = result.to_a[0][0] || 0
    subject_total = research_billing_qty_total * per_unit_cost(quantity_total())

    subject_total
  end

  # Determine the direct costs for a visit-based service
  def direct_costs_for_visit_based_service
    self.subject_count * self.direct_costs_for_visit_based_service_single_subject
  end

  # Determine the direct costs for a one-time-fee service
  def direct_costs_for_one_time_fee
    num = self.quantity || 0.0
    num * self.per_unit_cost
  end

  # Determine the indirect cost rate related to a particular line item
  def indirect_cost_rate
    if USE_INDIRECT_COST
      self.service_request.protocol.indirect_cost_rate.to_f / 100
    else
      return 0
    end
  end

  # Determine the indirect cost rate for a visit-based service for one subject
  def indirect_costs_for_visit_based_service_single_subject
    if USE_INDIRECT_COST
      self.direct_costs_for_visit_based_service_single_subject * self.indirect_cost_rate
    else
      return 0
    end
  end

  # Determine the indirect costs for a visit-based service
  def indirect_costs_for_visit_based_service
    if USE_INDIRECT_COST
      self.direct_costs_for_visit_based_service * self.indirect_cost_rate
    else
      return 0
    end
  end

  # Determine the indirect costs for a one-time-fee service
  def indirect_costs_for_one_time_fee
    if self.service.displayed_pricing_map.exclude_from_indirect_cost || !USE_INDIRECT_COST
      return 0
    else
      self.direct_costs_for_one_time_fee * self.indirect_cost_rate
    end
  end

  # Add a new visit.  Returns the new Visit upon success or false upon
  # error.
  def add_visit position=nil
    self.visits.create(position: position)
  end

  def remove_visit position
    visit = self.visits.find_by_position(position)
    # Move visit to the end by position, re-number other visits
    visit.move_to_bottom
    # Must reload to refresh other visit positions, otherwise two 
    # records with same postion will exist
    self.reload
    visit.delete
  end

  # In fulfillment, when you change the service on an existing line item
  def switch_to_one_time_fee
    result = self.transaction do
      self.quantity = 1 unless self.quantity  
      self.units_per_quantity unless self.units_per_quantity
      self.visits.each {|x| x.destroy}
      self.save or raise ActiveRecord::Rollback
    end

    if result
      return true
    else
      self.reload
      return false
    end
  end

  # In fulfillment, when you change the service on an existing line item
  def switch_to_per_patient_per_visit
    result = self.transaction do
      self.service_request.insure_visit_count()
      (self.service_request.visit_count - visits.size).times do #somehow service request visit count is higher so create
        visits.create!
      end
      (visits.size - self.service_request.visit_count).times do #somehow service request visit count is lower so delete
        visits.last.destroy
      end
      self.service_request.insure_subject_count()
      self.save or raise ActiveRecord::Rollback
    end

    if result
      return true
    else
      self.reload
      return false
    end
  end
end

