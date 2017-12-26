class ComplianceCheckBlock < ActiveRecord::Base
  include StifTransportModeEnumerations
  include StifTransportSubmodeEnumerations

  belongs_to :compliance_check_set

  has_many :compliance_checks

  store_accessor :condition_attributes,
    :transport_mode,
    :transport_submode

end
