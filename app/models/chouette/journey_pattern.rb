class Chouette::JourneyPattern < Chouette::TridentActiveRecord
  include JourneyPatternRestrictions
  # FIXME http://jira.codehaus.org/browse/JRUBY-6358
  self.primary_key = "id"

  belongs_to :route
  has_many :vehicle_journeys, :dependent => :destroy
  has_many :vehicle_journey_at_stops, :through => :vehicle_journeys
  has_and_belongs_to_many :stop_points, -> { order("stop_points.position") }, :before_add => :vjas_add, :before_remove => :vjas_remove, :after_add => :shortcuts_update_for_add, :after_remove => :shortcuts_update_for_remove
  has_many :stop_areas, through: :stop_points
  has_many :journey_pattern_sections
  has_many :route_sections, through: :journey_pattern_sections, dependent: :destroy

  validates_presence_of :route
  validates_presence_of :name

  enum section_status: { todo: 0, completed: 1, control: 2 }

  attr_accessor  :control_checked
  after_update :control_route_sections, :unless => "control_checked"


  def self.state_update route, state
    transaction do
      state.each do |item|
        item.delete('errors')
        jp = find_by(objectid: item['object_id']) || state_create_instance(route, item)
        next if item['deletable'] && jp.persisted? && jp.destroy

        # Update attributes and stop_points associations
        jp.update_attributes(state_permited_attributes(item))
        jp.state_stop_points_update(item) if !jp.errors.any? && jp.persisted?
        item['errors'] = jp.errors if jp.errors.any?
      end

      if state.any? {|item| item['errors']}
        state.map {|item| item.delete('object_id') if item['new_record']}
        raise ActiveRecord::Rollback
      end
    end

    state.map {|item| item.delete('new_record')}
    state.delete_if {|item| item['deletable']}
  end

  def self.state_permited_attributes item
    {
      name: item['name'],
      published_name: item['published_name'],
      registration_number: item['registration_number']
    }
  end

  def self.state_create_instance route, item
    # Flag new record, so we can unset object_id if transaction rollback
    jp = route.journey_patterns.create(state_permited_attributes(item))
    item['object_id']  = jp.objectid
    item['new_record'] = true
    jp
  end

  def state_stop_points_update item
    item['stop_points'].each do |sp|
      exist = stop_area_ids.include?(sp['id'])
      next if exist && sp['checked']

      stop_point = route.stop_points.find_by(stop_area_id: sp['id'])
      if !exist && sp['checked']
        stop_points << stop_point
      end
      if exist && !sp['checked']
        stop_points.delete(stop_point)
      end
    end
  end

  # TODO: this a workarround
  # otherwise, we loose the first stop_point
  # when creating a new journey_pattern
  def special_update
    bck_sp = self.stop_points.map {|s| s}
    self.update_attributes :stop_points => []
    self.update_attributes :stop_points => bck_sp
  end

  def departure_stop_point
    return unless departure_stop_point_id
    Chouette::StopPoint.find( departure_stop_point_id)
  end

  def arrival_stop_point
    return unless arrival_stop_point_id
    Chouette::StopPoint.find( arrival_stop_point_id)
  end

  def shortcuts_update_for_add( stop_point)
    stop_points << stop_point unless stop_points.include?( stop_point)

    ordered_stop_points = stop_points
    ordered_stop_points = ordered_stop_points.sort { |a,b| a.position <=> b.position} unless ordered_stop_points.empty?

    self.update_attributes( :departure_stop_point_id => (ordered_stop_points.first && ordered_stop_points.first.id),
                             :arrival_stop_point_id => (ordered_stop_points.last && ordered_stop_points.last.id))
  end

  def shortcuts_update_for_remove( stop_point)
    stop_points.delete( stop_point) if stop_points.include?( stop_point)

    ordered_stop_points = stop_points
    ordered_stop_points = ordered_stop_points.sort { |a,b| a.position <=> b.position} unless ordered_stop_points.empty?

    self.update_attributes( :departure_stop_point_id => (ordered_stop_points.first && ordered_stop_points.first.id),
                             :arrival_stop_point_id => (ordered_stop_points.last && ordered_stop_points.last.id))
  end

  def vjas_add( stop_point)
    return if new_record?

    vehicle_journeys.each do |vj|
      vjas = vj.vehicle_journey_at_stops.create :stop_point_id => stop_point.id
    end
  end

  def vjas_remove( stop_point)
    return if new_record?

    vehicle_journey_at_stops.where( :stop_point_id => stop_point.id).each do |vjas|
      vjas.destroy
    end
  end

  def control_route_sections
    stop_area_ids = self.stop_points.map(&:stop_area_id)
    control_route_sections_by_stop_areas(stop_area_ids)
  end

  def control_route_sections_by_stop_areas(stop_area_ids)
    journey_pattern_section_all
    i = 0
    to_control = false
    stop_area_ids.each_cons(2) do |a|
      jps = @route_sections_orders[i]
      i += 1
      unless jps
        to_control = true
        next
      end
      unless [jps.route_section.departure.id, jps.route_section.arrival.id] == a
        jps.destroy
        to_control = true
      end
    end
    self.control_checked = true
    to_control ? self.control! : self.completed!
  end

  protected

  def journey_pattern_section_all
    @route_sections_orders = {}
    self.journey_pattern_sections.all.map do |journey_pattern_section|
      @route_sections_orders[journey_pattern_section.rank] = journey_pattern_section
    end
  end

end

