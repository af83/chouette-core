class ComplianceControlBlock < ActiveRecord::Base
  include StifTransportModeEnumerations
  include StifTransportSubmodeEnumerations

  belongs_to :compliance_control_set
  has_many :compliance_controls, dependent: :destroy

  store_accessor :condition_attributes,
    :transport_mode,
    :transport_submode

  validates :transport_mode, presence: true
  validates :compliance_control_set, presence: true

  def name
    ApplicationController.helpers.transport_mode_text(self)
  end

end
