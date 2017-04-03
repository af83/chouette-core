class AddDepartureArrivalDayOffsetsToVjas < ActiveRecord::Migration
  def change
    add_column :vehicle_journey_at_stops, :departure_day_offset, :integer
    add_column :vehicle_journey_at_stops, :arrival_day_offset, :integer
  end
end
