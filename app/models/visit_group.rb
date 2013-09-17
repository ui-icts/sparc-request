class VisitGroup < ActiveRecord::Base
  include Comparable
  audited

  belongs_to :arm
  has_many :visits, :dependent => :destroy
  has_many :appointments, :dependent => :destroy
  attr_accessible :name
  attr_accessible :position
  attr_accessible :arm_id
  attr_accessible :day
  attr_accessible :window
  acts_as_list :scope => :arm

  after_create :set_default_name

  def set_default_name
    if name.nil? || name == ""
      self.update_attributes(:name => "Visit #{self.position}")
    end
  end

  def <=> (other_vg)
    return self.day <=> other_vg.day
  end

end
