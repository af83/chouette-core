require 'net/http'
class Import::Netex < Import::Base
  before_destroy :destroy_non_ready_referential

  after_commit do
    main_resource.update_status_from_importer self.status
    true
  end

  before_save do
    self.referential&.failed! if self.status == 'aborted' || self.status == 'failed'
  end

  validates_presence_of :parent

  def main_resource
    @resource ||= parent.resources.find_or_create_by(name: self.name, resource_type: "referential", reference: self.name)
  end

  def notify_parent
    compute_faulty_checksums! # See #7728
    if super
      main_resource.update_status_from_importer self.status
      update_referential
      next_step
    end
  end

  def next_step
    main_resource.next_step
  end

  def create_message args
    main_resource.messages.create args
  end

  def create_with_referential!
    save unless persisted?

    self.referential =
      Referential.new(
        name: self.name,
        organisation_id: workbench.organisation_id,
        workbench_id: workbench.id,
        metadatas: [referential_metadata]
      )
    self.referential.save

    if self.referential.valid?
      main_resource.update referential: referential
      save!
      call_iev_callback
    else
      Rails.logger.info "Can't create referential for import #{self.id}: #{referential.inspect} #{referential.metadatas.inspect} #{referential.errors.messages}"
      metadata = referential.metadatas.first

      if !@line_objectids.present?
        create_message criticity: :error, message_key: "referential_creation_missing_lines_in_files", message_attributes: {referential_name: referential.name}
      elsif metadata.line_ids.empty?
        create_message criticity: :error, message_key: "referential_creation_missing_lines", message_attributes: {referential_name: referential.name}
      elsif (overlapped_referential_ids = referential.overlapped_referential_ids).any?
        overlapped = Referential.find overlapped_referential_ids.last
        create_message(
          criticity: :error,
          message_key: "referential_creation_overlapping_existing_referential",
          message_attributes: {
            referential_name: referential.name,
            overlapped_name: overlapped.name,
            overlapped_url:  Rails.application.routes.url_helpers.referential_path(overlapped)
          }
        )
      else
        create_message(
          criticity: :error,
          message_key: "referential_creation",
          message_attributes: {referential_name: referential.name},
          resource_attributes: referential.errors.messages
        )
      end
      self.referential = nil
      aborted!
    end
  end

  private

  def update_referential
    if self.status.successful? || self.status.warning?
      self.referential&.active!
    else
      self.referential&.failed!
    end
  end

  def iev_callback_url
    URI("#{Rails.configuration.iev_url}/boiv_iev/referentials/importer/new?id=#{id}")
  end

  def destroy_non_ready_referential
    if referential && !referential.ready
      referential.destroy
    end
  end

  def referential_metadata
    metadata = ReferentialMetadata.new

    if self.file && self.file.path
      netex_file = STIF::NetexFile.new(self.file.path)
      frame = netex_file.frames.first

      if frame
        metadata.periodes = frame.periods

        @line_objectids = frame.line_refs.map { |ref| "STIF:CODIFLIGNE:Line:#{ref}" }
        metadata.line_ids = workbench.lines.where(objectid: @line_objectids).pluck(:id)
      end
    end

    metadata
  end

  def compute_faulty_checksums!
    return unless referential.present?
    referential.switch do
      faulty = Chouette::Footnote.where(checksum: nil); nil
      vj_ids = faulty.joins(:vehicle_journeys).pluck("vehicle_journeys.id")
      faulty.find_each do |footnote|
        footnote.set_current_checksum_source
        footnote.update_column :checksum, Digest::SHA256.new.hexdigest(footnote.checksum_source)
      end
      Chouette::VehicleJourney.where(id: vj_ids).find_each do |vj|
        vj.update_checksum!
      end
      Chouette::RoutingConstraintZone.find_each &:update_checksum!
      Chouette::JourneyPattern.find_each &:update_checksum!
    end
  end
end
