module Types
	class LineType < Types::BaseObject
		description "A Chouette Line"

		field :id, Integer, null: false
		field :objectid, String, null: false

		field :routes, [Types::RouteType], null: false,
			description: "The Line's Routes"

		field :stop_areas, [Types::StopAreaType], null: false,
			description: "The Line's StopAreas"
	end
end