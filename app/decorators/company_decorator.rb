class CompanyDecorator < AF83::Decorator
  decorates Chouette::Company

  set_scope { context[:referential] }

  create_action_link do |l|
    l.content { h.t('companies.actions.new') }
  end

  with_instance_decorator do |instance_decorator|
    instance_decorator.show_action_link

    instance_decorator.edit_action_link do |l|
      l.content {|l| l.action == "show" ? h.t('actions.edit') : h.t('companies.actions.edit') }
    end

    instance_decorator.destroy_action_link do |l|
      l.content { h.destroy_link_content('companies.actions.destroy') }
      l.data {{ confirm: h.t('companies.actions.destroy_confirm') }}
    end
  end
end
