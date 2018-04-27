class Import::Resource < ApplicationModel
  self.table_name = :import_resources

  include IevInterfaces::Resource

  belongs_to :import, class_name: Import::Base
  belongs_to :referential
  has_many :messages, class_name: "Import::Message", foreign_key: :resource_id

  def root_import
    import = self.import
    import = import.parent while import.parent
    import
  end

  def netex_import
    return unless self.resource_type == "referential"
    import.children.where(name: self.reference).last
  end
end
