class StopAreaProvider < ActiveRecord::Base
  include ObjectidSupport

  belongs_to :stop_area_referential
  has_and_belongs_to_many :stop_areas, class_name: "Chouette::StopArea"

  alias_method :referential, :stop_area_referential
end
