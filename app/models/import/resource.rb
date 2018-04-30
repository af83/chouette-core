class Import::Resource < ApplicationModel
  self.table_name = :import_resources

  include IevInterfaces::Resource

  belongs_to :import, class_name: Import::Base
  belongs_to :referential
  has_many :messages, class_name: "Import::Message", foreign_key: :resource_id

  scope :main_resources, ->{ where(resource_type: "referential") }

  def root_import
    import = self.import
    import = import.parent while import.parent
    import
  end

  def next_step
    if root_import.class == Import::Workbench

      return unless netex_import&.successful?

      if workbench.import_compliance_control_set_id.present? && workbench_import_control_set.nil?
        ComplianceControlSetCopyWorker.perform_async workbench.import_compliance_control_set_id, referential_id
        return
      end

      return if workbench_import_control_set && !workbench_import_control_set.successful?

      if workgroup.import_compliance_control_set_id.present? && workgroup_import_control_set.nil?
        ComplianceControlSetCopyWorker.perform_async workgroup.import_compliance_control_set_id, referential_id
      end
    end
  end

  def workbench
    import.workbench
  end

  def workgroup
    workbench.workgroup
  end

  def netex_import
    return unless self.resource_type == "referential"
    import.children.where(name: self.reference).last
  end

  def workbench_import_control_set
    return unless referential.present?
    return unless referential.workbench.import_compliance_control_set_id.present?
    referential.compliance_check_sets.where(compliance_control_set_id: referential.workbench.import_compliance_control_set_id, referential_id: referential_id).last
  end

  def workgroup_import_control_set
    return unless referential.present?
    return unless referential.workbench.workgroup.import_compliance_control_set_id.present?
    referential.compliance_check_sets.where(compliance_control_set_id: referential.workbench.workgroup.import_compliance_control_set_id, referential_id: referential_id).last
  end
end
