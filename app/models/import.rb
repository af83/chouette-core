class Import < ActiveRecord::Base
  mount_uploader :file, ImportUploader
  belongs_to :workbench
  belongs_to :referential

  belongs_to :parent, polymorphic: true

  has_many :messages, class_name: "ImportMessage", dependent: :destroy
  has_many :resources, class_name: "ImportResource", dependent: :destroy
  has_many :children, foreign_key: :parent_id, class_name: "Import", dependent: :destroy

  scope :where_started_at_in, ->(period_range) do
    where('started_at BETWEEN :begin AND :end', begin: period_range.begin, end: period_range.end)
   end

  extend Enumerize
  enumerize :status, in: %i(new pending successful warning failed running aborted canceled), scope: true, default: :new

  validates :name, presence: true
  validates :file, presence: true
  validates_presence_of :workbench, :creator
  validates_format_of :file, with: %r{\.zip\z}i, message: I18n.t('activerecord.errors.models.import.attributes.file.wrong_file_extension')

  before_create :initialize_fields

  def self.model_name
    ActiveModel::Name.new Import, Import, "Import"
  end

  def children_succeedeed
    children.with_status(:successful).count
  end

  def self.failing_statuses
    symbols_with_indifferent_access(%i(failed aborted canceled))
  end

  def self.finished_statuses
    symbols_with_indifferent_access(%i(successful failed warning aborted canceled))
  end

  def notify_parent
    parent.child_change
    update(notified_parent_at: DateTime.now)
  end

  def child_change
    return if self.class.finished_statuses.include?(status)

    update_status
    update_referentials
  end

  def update_status
    status_count = children.group(:status).count
    children_finished_count = children_failed_count = children_count = 0

    status_count.each do |status, count|
      if self.class.failing_statuses.include?(status)
        children_failed_count += count
      end
      if self.class.finished_statuses.include?(status)
        children_finished_count += count
      end
      children_count += count
    end

    attributes = {
      current_step: children_finished_count
    }

    status =
      if children_failed_count > 0
        'failed'
      elsif status_count['successful'] == children_count
        'successful'
      end

    if self.class.finished_statuses.include?(status)
      attributes[:ended_at] = Time.now
    end

    update attributes.merge(status: status)
  end

  def update_referentials
    return unless self.class.finished_statuses.include?(status)

    children.each do |import|
      import.referential.update(ready: true) if import.referential
    end
  end

  private

  def initialize_fields
    self.token_download = SecureRandom.urlsafe_base64
  end

  def self.symbols_with_indifferent_access(array)
    array.flat_map { |symbol| [symbol, symbol.to_s] }
  end
end
