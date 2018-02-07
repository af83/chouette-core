class StopAreaPolicy < ApplicationPolicy
  class Scope < Scope
    def search_scope scope_name
      scope = resolve
      if scope_name&.to_s == "route_editor"
        scope = scope.where("kind = ? OR area_type = ?", :non_commercial, 'zdep') unless user.organisation.has_feature?("route_stop_areas_all_types")
      end
      scope
    end

    def resolve
      scope
    end
  end

  def create?
    user.has_permission?('stop_areas.create')
  end

  def destroy?
    user.has_permission?('stop_areas.destroy')
  end

  def update?
    user.has_permission?('stop_areas.update')
  end

  def deactivate?
    !record.deactivated? && user.has_permission?('stop_areas.change_status')
  end

  def activate?
    record.deactivated? && user.has_permission?('stop_areas.change_status')
  end
end
