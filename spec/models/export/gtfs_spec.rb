RSpec.describe Export::Gtfs, type: :model do
  let(:stop_area_referential){ create :stop_area_referential }
  let(:line_referential){ create :line_referential }
  let(:company){ create :company, line_referential: line_referential }
  let(:workbench){ create :workbench, line_referential: line_referential, stop_area_referential: stop_area_referential }
  let(:referential_metadata){ create(:referential_metadata, lines: line_referential.lines.limit(3)) }
  let(:referential){
    create :referential,
    workbench: workbench,
    organisation: workbench.organisation,
    metadatas: [referential_metadata]
  }

  before(:each) do
    2.times { create :line, line_referential: line_referential, company: company, network: nil }
    10.times { create :stop_area, stop_area_referential: stop_area_referential }
  end

  let(:gtfs_export) { create :gtfs_export, referential: referential, workbench: workbench, duration: 5}

  it "should correctly export data as valid GTFS output" do
    # Create context for the tests
    factor = 2
    selected_vehicle_journeys = []
    selected_stop_areas_hash = {}
    date_range = []

    # Create two levels parents stop_areas
    6.times do |index|
      sa = referential.stop_areas.sample
      new_parent = FactoryGirl.create :stop_area, stop_area_referential: stop_area_referential
      sa.parent = new_parent
      sa.save
      if index.even?
        new_parent.parent = FactoryGirl.create :stop_area, stop_area_referential: stop_area_referential
        new_parent.save
      end
    end

    referential.switch do
      line_referential.lines.each do |line|
        # 2*2 routes with 5 stop_areas each
        factor.times do
          stop_areas = stop_area_referential.stop_areas.order("random()").limit(5)
          FactoryGirl.create :route, line: line, stop_areas: stop_areas, stop_points_count: 0
        end
      end

      referential.routes.each_with_index do |route, index|
        route.stop_points.each do |sp|
          sp.set_list_position 0
        end

        if index.even?
          route.wayback = :outbound
        else
          route.update_column :wayback, :inbound
          route.opposite_route = route.opposite_route_candidates.sample
        end

        route.save!

        # 4*2 journey_pattern with 3 stop_points each
        factor.times do
          FactoryGirl.create :journey_pattern, route: route, stop_points: route.stop_points.sample(3)
        end
      end

      # 8*2 vehicle_journey
      referential.journey_patterns.each do |journey_pattern|
        factor.times do
          FactoryGirl.create :vehicle_journey, journey_pattern: journey_pattern, company: company
        end
      end

      # 16+1 different time_tables
      shared_time_table = FactoryGirl.create :time_table

      referential.vehicle_journeys.each do |vehicle_journey|
        vehicle_journey.time_tables << shared_time_table
        specific_time_table = FactoryGirl.create :time_table
        vehicle_journey.time_tables << specific_time_table
      end

      #selected_vehicle_journeys = referential.vehicle_journeys.where(route_id: referential.routes.first)
      date_range = gtfs_export.date_range
      #selected_vehicle_journeys = Chouette::VehicleJourney.with_matching_timetable (gtfs_export.instance_variable_get('@date_range'))
      selected_vehicle_journeys = Chouette::VehicleJourney.with_matching_timetable date_range
      gtfs_export.instance_variable_set('@journeys', selected_vehicle_journeys)
    end

    tmp_dir = Dir.mktmpdir

    ################################
    # Test (1) agencies.txt export
    ################################

    agencies_zip_path = File.join(tmp_dir, '/test_agencies.zip')

    referential.switch do
      GTFS::Target.open(agencies_zip_path) do |target|
        gtfs_export.export_companies_to target
      end

      # The processed export files are re-imported through the GTFS gem
      source = GTFS::Source.build agencies_zip_path, strict: false
      expect(source.agencies.length).to eq(1)
      agency = source.agencies.first
      expect(agency.id).to eq(company.registration_number)
      expect(agency.name).to eq(company.name)
    end

    ################################
    # Test (2) stops.txt export
    ################################

    stops_zip_path = File.join(tmp_dir, '/test_stops.zip')

    # Fetch the expected exported stop_areas
    referential.switch do
      selected_vehicle_journeys.each do |vehicle_journey|
          vehicle_journey.route.stop_points.each do |stop_point|
            (selected_stop_areas_hash[stop_point.stop_area.id] = stop_point.stop_area) if (stop_point.stop_area && !selected_stop_areas_hash[stop_point.stop_area.id])
          end
      end
      selected_stop_areas = []
      selected_stop_areas = gtfs_export.export_stop_areas_recursively(selected_stop_areas_hash.values)

      GTFS::Target.open(stops_zip_path) do |target|
        # reset export sort variable
        gtfs_export.instance_variable_set('@stop_area_stop_hash', {})
        gtfs_export.export_stop_areas_to target
      end

      # The processed export files are re-imported through the GTFS gem
      source = GTFS::Source.build stops_zip_path, strict: false

      # Same size
      expect(source.stops.length).to eq(selected_stop_areas.length)
      # Randomly pick a stop_area and find the correspondant stop exported in GTFS
      random_stop_area = selected_stop_areas.sample

      # Find matching random stop in exported stops.txt file
      random_gtfs_stop = source.stops.detect {|e| e.id == (random_stop_area.registration_number.presence || random_stop_area.id.to_s)}
      expect(random_gtfs_stop).not_to be_nil
      expect(random_gtfs_stop.name).to eq(random_stop_area.name)
      expect(random_gtfs_stop.location_type).to eq(random_stop_area.area_type == 'zdlp' ? '1' : '0')
      # Checks if the parents are similar
      expect(random_gtfs_stop.parent_station).to eq(((random_stop_area.parent.registration_number.presence || random_stop_area.parent.id) if random_stop_area.parent))
    end

    ################################
    # Test (3) lines.txt export
    ################################

    lines_zip_path = File.join(tmp_dir, '/test_lines.zip')
    referential.switch do
      GTFS::Target.open(lines_zip_path) do |target|
        gtfs_export.export_lines_to target
      end

      # The processed export files are re-imported through the GTFS gem, and the computed
      source = GTFS::Source.build lines_zip_path, strict: false
      selected_routes = {}
      selected_vehicle_journeys.each do |vehicle_journey|
        selected_routes[vehicle_journey.route.line.id] = vehicle_journey.route.line
      end

      expect(source.routes.length).to eq(selected_routes.length)
      route = source.routes.first
      line = referential.lines.first

      expect(route.id).to eq(line.registration_number)
      expect(route.agency_id).to eq(line.company.registration_number)
      expect(route.long_name).to eq(line.published_name)
      expect(route.short_name).to eq(line.number)
      expect(route.type).to eq(gtfs_export.gtfs_line_type line)
      expect(route.desc).to eq(line.comment)
      expect(route.url).to eq(line.url)
    end

    ####################################################
    # Test (4) calendars.txt and calendar_dates.txt export #
    ####################################################

    calendars_zip_path = File.join(tmp_dir, '/test_calendars.zip')

    referential.switch do
      GTFS::Target.open(calendars_zip_path) do |target|
        gtfs_export.export_time_tables_to target
      end

      # The processed export files are re-imported through the GTFS gem
      source = GTFS::Source.build calendars_zip_path, strict: false

      # Get VJ merged periods
      periods = []
      selected_vehicle_journeys.each do |vehicle_journey|
        periods << vehicle_journey.flattened_circulation_periods.select{|period| period.range & date_range}
      end

      periods = periods.flatten.uniq

      # Same size
      expect(source.calendars.length).to eq(periods.length)
      # Randomly pick a time_table_period and find the correspondant calendar exported in GTFS
      random_period = periods.sample
      # Find matching random stop in exported stops.txt file
      random_gtfs_calendar = source.calendars.detect do |e|
        e.service_id == random_period.object_id
        e.start_date == (random_period.period_start.strftime('%Y%m%d'))
        e.end_date == (random_period.period_end.strftime('%Y%m%d'))

        e.monday == (random_period.monday ? "1" : "0")
        e.tuesday == (random_period.tuesday ? "1" : "0")
        e.wednesday == (random_period.wednesday ? "1" : "0")
        e.thursday == (random_period.thursday ? "1" : "0")
        e.friday == (random_period.friday ? "1" : "0")
        e.saturday == (random_period.saturday ? "1" : "0")
        e.sunday == (random_period.sunday ? "1" : "0")
      end

      expect(random_gtfs_calendar).not_to be_nil
      expect((random_period.period_start..random_period.period_end).overlaps?(date_range.begin..date_range.end)).to be_truthy

      # TO MODIFY IF NEEDED : the method vehicle_journeys#flattened_circulation_periods casts any time_table_dates into a single day period/calendar.
      # Thus, for the moment, no time_table_dates / calendar_dates.txt 'll be exported
      # Test time_table_dates
      # vj_dates = selected_vehicle_journeys.map{|vj| vj.time_tables.map {|time_table|time_table.dates}}.flatten.uniq.select {|date| (date_range.begin..date_range.end) === date.date}
      #
      # vj_dates.length.should eq(source.calendar_dates.length)
      # vj_dates.each do |date|
      #   period = nil
      #   if date.in_out
      #     period = date.time_table.periods.first
      #   else
      #     period = date.time_table.periods.detect {|period| (period.period_start..period.period_end) === date.date}
      #   end
      #   period.should_not be_nil
      #
      #   calendar_date = source.calendar_dates.detect {|c| c.service_id == (period.id.to_s) && c.date == date.date.strftime('%Y%m%d')}
      #   calendar_date.should_not be_nil
      #   calendar_date.exception_type.should eq(date.in_out ? '1' : '2')
      # end

    ################################
    # Test (5) trips.txt export
    ################################

    targets_zip_path = File.join(tmp_dir, '/test_trips.zip')

      GTFS::Target.open(targets_zip_path) do |target|
        gtfs_export.export_vehicle_journeys_to target
      end

      # The processed export files are re-imported through the GTFS gem, and the computed
      source = GTFS::Source.build targets_zip_path, strict: false

      # Get VJ merged periods
      vj_periods = []
      selected_vehicle_journeys.each do |vehicle_journey|
        vehicle_journey.flattened_circulation_periods.select{|period| period.range & date_range}.each do |period|
          vj_periods << [period,vehicle_journey]
        end
      end

      # Same size
      expect(source.trips.length).to eq(vj_periods.length)

      # Randomly pick a vehicule_journey / period couple and find the correspondant trip exported in GTFS
      random_vj_period = vj_periods.sample

      # Find matching random stop in exported trips.txt file
      random_gtfs_trip = source.trips.detect {|t| t.service_id == random_vj_period.first.object_id.to_s && t.route_id == random_vj_period.last.route.line.registration_number.to_s}
      expect(random_gtfs_trip).not_to be_nil

    ################################
    # Test (6) stop_times.txt export
    ################################

    stop_times_zip_path = File.join(tmp_dir, '/stop_times.zip')
      GTFS::Target.open(stop_times_zip_path) do |target|
        gtfs_export.export_vehicle_journey_at_stops_to target
      end

      # The processed export files are re-imported through the GTFS gem, and the computed
      source = GTFS::Source.build stop_times_zip_path, strict: false

      expected_stop_times_length = vj_periods.map{|vj| vj.last.vehicle_journey_at_stops}.flatten.length

      # Same size
      expect(source.stop_times.length).to eq(expected_stop_times_length)

      # Count the number of stop_times generated by a random VJ and period couple (sop_times depends on a vj, a period and a stop_area)
      vehicle_journey_at_stops = random_vj_period.last.vehicle_journey_at_stops

      # Fetch all the stop_times entries exported in GTFS related to the trip (matching the previous VJ / period couple)
      stop_times = source.stop_times.select{|stop_time| stop_time.trip_id == random_gtfs_trip.id }

      # Same size 2
      expect(stop_times.length).to eq(vehicle_journey_at_stops.length)

      # A random stop_time is picked
      random_vehicle_journey_at_stop = vehicle_journey_at_stops.sample
      stop_time = stop_times.detect{|stop_time| stop_time.arrival_time == GTFS::Time.format_datetime(random_vehicle_journey_at_stop.arrival_time, random_vehicle_journey_at_stop.arrival_day_offset) }
      expect(stop_time).not_to be_nil
      expect(stop_time.departure_time).to eq(GTFS::Time.format_datetime(random_vehicle_journey_at_stop.departure_time, random_vehicle_journey_at_stop.departure_day_offset))
    end
  end
end
