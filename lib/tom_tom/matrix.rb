module TomTom
  class Matrix
    def initialize(connection)
      @connection = connection
    end

    def matrix(way_costs)
      points_with_ids = points_from_way_costs(way_costs)
      points = points_as_params(points_with_ids)

      response = @connection.post do |req|
        req.url '/routing/1/matrix/json'
        req.headers['Content-Type'] = 'application/json'

        req.params[:routeType] = 'shortest'
        req.params[:travelMode] = 'bus'

        req.body = {
          origins: points,
          destinations: points
        }.to_json
      end

      extract_costs_to_way_costs!(
        way_costs,
        points_with_ids,
        JSON.parse(response.body)
      )
    end

    def points_from_way_costs(way_costs)
      points = []

      way_costs.each do |way_cost|
        departure_id, arrival_id = way_cost.id.split('-')

        departure = TomTom::Matrix::Point.new(
          way_cost.departure,
          departure_id
        )
        arrival = TomTom::Matrix::Point.new(
          way_cost.arrival,
          arrival_id
        )

        # Don't add duplicate coordinates. This assumes that
        # `way_costs` consists of an ordered route of points where
        # each departure coordinate is the same as the preceding
        # arrival coordinate.
        if points.empty? ||
            points.last.coordinates != departure.coordinates
          points << departure
        end

        points << arrival
      end

      points
    end

    def points_as_params(points)
      points.map do |point|
        {
          point: {
            latitude: point.coordinates.lat,
            longitude: point.coordinates.lng
          }
        }
      end
    end

    def extract_costs_to_way_costs!(way_costs, points, matrix_json)
      way_costs = []

      # `row` and `column` order is the same as `points`
      matrix_json['matrix'].each_with_index do |row, row_i|
        row.each_with_index do |column, column_i|
          next if column['statusCode'] != 200

          distance = column['response']['routeSummary']['lengthInMeters']

          # Ignore costs between a point and itself (e.g. from A to A)
          next if distance == 0

          departure = points[row_i]
          arrival = points[column_i]

          way_costs << WayCost.new(
            departure: Geokit::LatLng.new(
              departure.coordinates.lat,
              departure.coordinates.lng
            ),
            arrival: Geokit::LatLng.new(
              arrival.coordinates.lat,
              arrival.coordinates.lng
            ),
            distance: distance,
            time: column['response']['routeSummary']['travelTimeInSeconds'],
            id: "#{departure.id}-#{arrival.id}"
          )
        end
      end

      way_costs
    end
  end
end
