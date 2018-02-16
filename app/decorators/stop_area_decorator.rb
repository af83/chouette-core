class StopAreaDecorator < AF83::Decorator
  decorates Chouette::StopArea

  create_action_link do |l|
    l.content t('stop_areas.actions.new')
    l.href { h.new_stop_area_referential_stop_area_path }
  end

  with_instance_decorator do |instance_decorator|
    set_scope { object.stop_area_referential }
    instance_decorator.show_action_link

    instance_decorator.edit_action_link do |l|
      l.content h.t('stop_areas.actions.edit')
    end

    instance_decorator.action_link policy: :deactivate, secondary: true do |l|
      l.content h.deactivate_link_content('stop_areas.actions.deactivate')
      l.href do
        h.deactivate_stop_area_referential_stop_area_path(
          object.stop_area_referential,
          object
        )
      end
      l.method :put
      l.data confirm: h.t('stop_areas.actions.deactivate_confirm')
      l.add_class 'delete-action'
    end

    instance_decorator.action_link policy: :activate, secondary: true do |l|
      l.content h.activate_link_content('stop_areas.actions.activate')
      l.href do
        h.activate_stop_area_referential_stop_area_path(
          object.stop_area_referential,
          object
        )
      end
      l.method :put
      l.data confirm: h.t('stop_areas.actions.activate_confirm')
      l.add_class 'delete-action'
    end

    instance_decorator.destroy_action_link do |l|
      l.content h.destroy_link_content('stop_areas.actions.destroy')
      l.data confirm: h.t('stop_areas.actions.destroy_confirm')
    end
  end

  define_instance_method :waiting_time_text do
    return '-' if [nil, 0].include? waiting_time
    h.t('stop_areas.waiting_time_format', value: waiting_time)
  end

end
