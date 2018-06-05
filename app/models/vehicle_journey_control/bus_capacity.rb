module VehicleJourneyControl
  class BusCapacity < InternalControl::Base
    def self.default_code; "3-VehicleJourney-9" end

    def self.object_path compliance_check, vehicle_journey
      referential_line_route_vehicle_journeys_collection_path(compliance_check.referential, vehicle_journey.route.line, vehicle_journey.route)
    end

    def self.collection referential
      referential.vehicle_journeys
    end

    def self.compliance_test vehicle_journey
      vehicle_journey.custom_fields[:capacity]&.value.present?
    end

    def self.message_attributes vehicle_journey
      {vehicle_journey_name: vehicle_journey.published_journey_name}
    end

    def self.label_attr
      :published_journey_name
    end
  end
end
