# coding: utf-8
Rails.application.config.to_prepare do
  Organisation.after_create do |organisation|
    line_referential      = LineReferential.find_by(name: "CodifLigne")
    stop_area_referential = StopAreaReferential.find_by(name: "Reflex")

    line_referential.organisations << organisation
    stop_area_referential.organisations << organisation

    workgroup = Workgroup.find_or_create_by(name: "Gestion de l'offre théorique IDFm") do |w|
      w.line_referential      = line_referential
      w.stop_area_referential = stop_area_referential
    end

    workbench = organisation.workbenches.find_or_create_by(name: "Gestion de l'offre") do |w|
      w.line_referential      = line_referential
      w.stop_area_referential = stop_area_referential
      w.objectid_format       = Workbench.objectid_format.stif_netex
      w.workgroup             = workgroup

      Rails.logger.debug "Create Workbench for #{organisation.name}"
    end
  end
end unless Rails.env.test?

Rails.application.config.to_prepare do
  Organisation.before_validation(on: :create) do |organisation|
    organisation.custom_view = "stif"
  end
end

Rails.application.config.to_prepare do
  Dashboard.default_class = Stif::Dashboard
end
