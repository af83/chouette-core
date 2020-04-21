class Import::Base < ApplicationModel
  self.table_name = "imports"
  include OptionsSupport
  include NotifiableSupport
  include PurgeableResource
  include ProfilingSupport

  PERIOD_EXTREME_VALUE = 15.years

  after_create :purge_imports

  def self.messages_class_name
    "Import::Message"
  end

  def self.resources_class_name
    "Import::Resource"
  end

  def self.human_name
    I18n.t("export.#{short_type}")
  end

  def self.file_extension_whitelist
    %w(zip)
  end

  def self.human_name
    I18n.t("import.#{short_type}")
  end

  def self.short_type
    @short_type ||= self.name.demodulize.underscore
  end

  def short_type
    self.class.short_type
  end

  scope :workbench, -> { where type: "Import::Workbench" }

  include IevInterfaces::Task
  # we skip validation once the import has been persisted,
  # in order to allow async workers (which don't have acces to the file) to
  # save the import
  validates_presence_of :file, unless: Proc.new {|import| @local_file.present? || import.persisted? || import.errors[:file].present? }

  validates_presence_of :workbench

  def self.model_name
    ActiveModel::Name.new Import::Base, Import::Base, "Import"
  end

  def operation_type
    :import
  end

  # call this method to mark an import as failed, as weel as the resulting referential
  def force_failure!
    if parent
      parent.force_failure!
      return
    end

    do_force_failure!
  end

  def do_force_failure!
    children.each &:do_force_failure!

    update status: 'failed', ended_at: Time.now
    referential&.failed!
    resources.map(&:referential).compact.each &:failed!
    notify_parent
  end

  def purge_imports
    workbench.imports.file_purgeable.where.not(file: nil).each do |import|
      import.update(remove_file: true)
    end
    workbench.imports.purgeable.destroy_all
  end

  def file_type
    return unless file
    return :gtfs if Import::Gtfs.accepts_file?(file.path)
    return :netex if Import::Netex.accepts_file?(file.path)
    return :neptune if Import::Neptune.accepts_file?(file.path)
  end

  # Returns all attributes of the imported file from the user point of view
  def user_file
    Chouette::UserFile.new basename: name.parameterize, extension: file_extension, content_type: content_type
  end

  # Expected and used file content type
  # Can be overrided by sub classes
  def content_type
    'application/zip'
  end

  protected

  # Expected and used file extension
  # Can be overrided by sub classes
  def file_extension
    "zip"
  end

  private

  def initialize_fields
    super
    self.token_download ||= SecureRandom.urlsafe_base64
  end

end
