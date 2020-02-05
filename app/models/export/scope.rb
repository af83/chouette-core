# Selects which models need to be included into an Export
module Export::Scope

  class Base

    attr_reader :referential

    def initialize(referential)
      @referential = referential
    end

    delegate :workbench, :line_referential, :stop_area_referential, to: :referential

    delegate :vehicle_journeys, :vehicle_journey_at_stops, :journey_patterns, :routes, :stop_points, :time_tables, to: :referential

    delegate :companies, to: :line_referential

    def stop_areas
      (workbench || stop_area_referential).stop_areas
    end

    def lines
      (workbench || line_referential).lines
    end

  end

  class All < Base

  end

  # Selects VehicleJourneys in a Date range, and all other models if they are required
  # to describe these VehicleJourneys
  class DateRange < Base

    attr_reader :date_range

    def initialize(referential, date_range)
      super referential
      @date_range = date_range
    end

    def vehicle_journeys
      @vehicle_journeys ||= super.with_matching_timetable(date_range)
    end

    def lines
      super.distinct.joins(routes: :vehicle_journeys)
        .where("vehicle_journeys.id" => vehicle_journeys)
    end

    def vehicle_journey_at_stops
      super.where(vehicle_journey: vehicle_journeys)
    end

    def routes
      super.joins(:vehicle_journeys).distinct
        .where("vehicle_journeys.id" => vehicle_journeys)
    end

    def stop_points
      super.distinct.joins(route: :vehicle_journeys)
        .where("vehicle_journeys.id" => vehicle_journeys)
    end

    def stop_areas
      @stop_areas ||=
        begin
          stop_areas_in_routes =
            super.joins(routes: :vehicle_journeys).distinct
              .where("vehicle_journeys.id" => vehicle_journeys)

          stop_areas_in_specific_vehicle_journey_at_stops =
            super.joins(:specific_vehicle_journey_at_stops).distinct
              .where("vehicle_journey_at_stops.vehicle_journey_id" => vehicle_journeys)

          Chouette::StopArea.union(stop_areas_in_routes, stop_areas_in_specific_vehicle_journey_at_stops)
        end
    end

  end

end