module VehicleJourneyControl
  class PurchaseWindow < InternalBase
    def self.default_code; "3-VehicleJourney-6" end

    def self.compliance_test compliance_check, vehicle_journey
      vehicle_journey.purchase_windows.exists?
    end
  end
end
