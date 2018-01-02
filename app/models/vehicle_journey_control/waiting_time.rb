module VehicleJourneyControl
  class WaitingTime < ComplianceControl
    store_accessor :control_attributes, :maximum

    validates_numericality_of :maximum, allow_nil: true, greater_than_or_equal_to: 0

    def self.default_code; "3-VehicleJourney-1" end
  end
end
