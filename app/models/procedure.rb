class Procedure < ActiveRecord::Base
  audited

  belongs_to :appointment
  belongs_to :visit
  belongs_to :line_item
  belongs_to :service
  attr_accessible :appointment_id
  attr_accessible :visit_id
  attr_accessible :line_item_id
  attr_accessible :completed
  attr_accessible :service_id
  attr_accessible :r_quantity
  attr_accessible :t_quantity
  attr_accessible :unit_factor_cost
  attr_accessible :toasts_generated

  def required?
    self.visit.to_be_performed?
  end

  def display_service_name
    self.service ? self.try(:service).try(:name) : self.try(:line_item).try(:service).try(:name)
  end

  def core
    self.service ? self.try(:service).try(:organization) : self.try(:line_item).try(:service).try(:organization)
  end

  # This method is primarily for setting the initial r_quantity values on the visit calendar in 
  # clinical work fulfillment.
  def default_r_quantity
    service_quantity = self.r_quantity
    unless self.appointment.visit_group_id.nil?
      if self.service
        service_quantity ||= 0
      else
        service_quantity ||= self.visit.research_billing_qty
      end
    end

    service_quantity
  end

  # This method is primarily for setting the initial t_quantity values on the visit calendar in 
  # clinical work fulfillment.
  def default_t_quantity
    service_quantity = self.t_quantity
    unless self.appointment.visit_group_id.nil?
      if self.service
        service_quantity ||= 0
      else
        service_quantity ||= self.visit.insurance_billing_qty
      end
    end

    service_quantity
  end

  def cost
    if self.service
      funding_source = self.appointment.calendar.subject.arm.protocol.funding_source_based_on_status #OHGOD
      organization = service.organization
      pricing_map = service.current_pricing_map
      pricing_setup = organization.current_pricing_setup
      rate_type = pricing_setup.rate_type(funding_source)
      if pricing_map.unit_factor > 1
        if self.unit_factor_cost
          return Service.cents_to_dollars(self.unit_factor_cost / self.default_r_quantity)
        else
          return (pricing_map.full_rate * (pricing_setup.applied_percentage(rate_type) / 100)).to_f
        end
      else
        return (pricing_map.full_rate * (pricing_setup.applied_percentage(rate_type) / 100)).to_f
      end
    elsif self.default_r_quantity == 0
      return (self.line_item.per_unit_cost(1) / 100).to_f
    else
      if self.line_item.service.displayed_pricing_map.unit_factor > 1
        subtotals = self.visit.line_items_visit.per_subject_subtotals
        return Service.cents_to_dollars(subtotals[self.visit_id.to_s] / self.default_r_quantity)
      else
        return (self.line_item.per_unit_cost(self.default_r_quantity) / 100).to_f
      end
    end
  end

  # Totals up a given row on the visit schedule
  def total
    if self.completed? and self.r_quantity
      return self.r_quantity * self.cost
    else
      return 0.00
    end
  end

  def should_be_displayed
    if self.service
      return true
    elsif self.appointment.visit_group_id.nil?
      return true if self.completed
    else
      if (self.visit.research_billing_qty && self.visit.research_billing_qty > 0) or (self.visit.insurance_billing_qty && self.visit.insurance_billing_qty > 0)
        return true
      else
        return false
      end
    end
  end

  ### audit reporting methods ###
    
  def audit_label audit
    subject = appointment.calendar.subject
    subject_label = subject.respond_to?(:audit_label) ? subject.audit_label(audit) : "Subject #{subject.id}"
    return "Procedure (#{display_service_name}) for #{subject_label} on #{appointment.visit_group.name}"
  end
 
  def audit_excluded_fields
    {'create' => ['visit_id', 'service_id', 'appointment_id', 'line_item_id', 'unit_factor_cost'], 'update' => ['toasts_generated']}
  end

  ### end audit reporting methods ###
end
