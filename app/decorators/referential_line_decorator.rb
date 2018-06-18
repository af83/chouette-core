class ReferentialLineDecorator < AF83::Decorator
  decorates Chouette::Line

  set_scope { context[:referential] }

  # Action links require:
  #   context: {
  #     referential: ,
  #     current_organisation:
  #   }

  with_instance_decorator do |instance_decorator|
    instance_decorator.show_action_link

    instance_decorator.action_link secondary: true do |l|
      l.content { Chouette::Line.tmf(:footnotes) }
      l.href { h.referential_line_footnotes_path(context[:referential], object) }
    end

    instance_decorator.action_link secondary: true do |l|
      l.content t('routing_constraint_zones.index.title')
      l.href do
        h.referential_line_routing_constraint_zones_path(
          scope,
          object
        )
      end
    end

    instance_decorator.action_link(
      if: ->() {
        (!object.hub_restricted? ||
          (object.hub_restricted? && object.routes.size < 2)) &&
        (h.policy(Chouette::Route).create? &&
          context[:referential].organisation == context[:current_organisation])
      },
      secondary: true
    ) do |l|
      l.content t('routes.actions.new')
      l.href { h.new_referential_line_route_path(scope, object) }
    end
  end
end
