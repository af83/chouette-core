class CleanUp < ApplicationModel
  extend Enumerize
  include AASM
  belongs_to :referential
  has_one :clean_up_result

  enumerize :date_type, in: %i(between before after)

  # validates_presence_of :date_type, message: :presence
  validates_presence_of :begin_date, message: :presence, if: :date_type
  validates_presence_of :end_date, message: :presence, if: Proc.new {|cu| cu.date_type == 'between'}
  validate :end_date_must_be_greater_that_begin_date
  after_commit :perform_cleanup, :on => :create

  scope :for_referential, ->(referential) do
    where(referential_id: referential.id)
  end

  attr_accessor :methods, :original_state

  def end_date_must_be_greater_that_begin_date
    if self.end_date && self.date_type == 'between' && self.begin_date >= self.end_date
      errors.add(:base, I18n.t('activerecord.errors.models.clean_up.invalid_period'))
    end
  end

  def perform_cleanup
    raise "You cannot specify methods (#{methods.inspect}) if you call the CleanUp asynchronously" unless methods.blank?
    CleanUpWorker.perform_async_or_fail(self, original_state) do
      log_failed({})
    end
  end

  def clean
    referential.switch
    referential.pending_while do
      {}.tap do |result|
        if date_type.present?
          processed = send("destroy_time_tables_#{self.date_type}")
          self.overlapping_periods.each do |period|
            exclude_dates_in_overlapping_period(period)
          end
        end

        destroy_routes_outside_referential
        # Disabled for the moment. See #5372
        # destroy_time_tables_outside_referential

        # Run caller-specified cleanup methods
        run_methods
      end
    end

    if original_state.present? && referential.respond_to?("#{original_state}!")
      referential.send("#{original_state}!") && referential.save!
    end
  end

  def run_methods
    return if methods.nil?

    methods.each { |method| send(method) }
  end

  def destroy_time_tables_between
    time_tables = Chouette::TimeTable.where('end_date < ? AND start_date > ?', self.end_date, self.begin_date)
    self.destroy_time_tables(time_tables)
  end

  def destroy_time_tables_before(date=nil)
    date ||= self.begin_date
    time_tables = Chouette::TimeTable.where('end_date < ?', date)
    self.destroy_time_tables(time_tables)
  end

  def destroy_time_tables_after(date=nil)
    date ||= self.end_date
    time_tables = Chouette::TimeTable.where('start_date > ?', date)
    self.destroy_time_tables(time_tables)
  end

  def destroy_time_tables_outside_referential
    metadatas_period = referential.metadatas_period
    destroy_time_tables_before(metadatas_period.min) && destroy_time_tables_after(metadatas_period.max)
  end

  def destroy_routes_outside_referential
    line_ids = referential.metadatas.pluck(:line_ids).flatten.uniq
    Chouette::Route.where(['line_id not in (?)', line_ids]).find_each &:clean!
  end

  def destroy_vehicle_journeys
    Chouette::VehicleJourney.where("id not in (select distinct vehicle_journey_id from time_tables_vehicle_journeys)").destroy_all
  end

  def destroy_journey_patterns
    Chouette::JourneyPattern.where("id not in (select distinct journey_pattern_id from vehicle_journeys)").destroy_all
  end

  def destroy_routes
    Chouette::Route.where("id not in (select distinct route_id from journey_patterns)").find_each &:clean!
  end

  def destroy_unassociated_footnotes
    Chouette::Footnote.not_associated.destroy_all
  end

  def destroy_unassociated_calendars
    Chouette::TimeTable.not_associated.destroy_all
    Chouette::PurchaseWindow.not_associated.destroy_all
  end

  def destroy_empty
    destroy_vehicle_journeys
    destroy_journey_patterns
    destroy_routes
    destroy_unassociated_footnotes
  end

  def overlapping_periods
    self.end_date = self.begin_date if self.date_type != 'between'
    Chouette::TimeTablePeriod.where('(period_start, period_end) OVERLAPS (?, ?)', self.begin_date, self.end_date)
  end

  def exclude_dates_in_overlapping_period(period)
    days_in_period  = period.period_start..period.period_end
    day_out         = period.time_table.dates.where(in_out: false).map(&:date)
    # check if day is greater or less then cleanup date
    if date_type != 'between'
      operator = date_type == 'after' ? '>' : '<'
      to_exclude_days = days_in_period.map do |day|
        day if day.public_send(operator, self.begin_date)
      end
    else
      days_in_cleanup_periode = (self.begin_date..self.end_date)
      to_exclude_days = days_in_period & days_in_cleanup_periode
    end

    to_exclude_days.to_a.compact.each do |day|
      # we ensure day is not already an exclude date
      # and that day is not equal to the boundariy date of the clean up
      if !day_out.include?(day) && day != self.begin_date && day != self.end_date
        self.add_exclude_date(period.time_table, day)
      end
    end
  end

  def add_exclude_date(time_table, day)
    day_in = time_table.dates.where(in_out: true).map(&:date)
    unless day_in.include?(day)
      time_table.add_exclude_date(false, day)
    else
      time_table.dates.where(date: day).take.update_attribute(:in_out, false)
    end
  end

  def destroy_vehicle_journey_without_time_table
    Chouette::VehicleJourney.without_any_time_table.destroy_all
  end

  def destroy_time_tables(time_tables)
    Chouette::TimeTable.delete_and_clean_offer! time_tables
  end

  aasm column: :status do
    state :new, :initial => true
    state :pending
    state :successful
    state :failed

    event :run, after: :log_pending do
      transitions :from => [:new, :failed], :to => :pending
    end

    event :successful, after: :log_successful do
      transitions :from => [:pending, :failed], :to => :successful
    end

    event :failed, after: :log_failed do
      transitions :from => :pending, :to => :failed
    end
  end

  def log_pending
    update_attribute(:started_at, Time.now)
  end

  def log_successful message_attributes
    update_attribute(:ended_at, Time.now)
    CleanUpResult.create(clean_up: self, message_key: :successfull, message_attributes: message_attributes)
  end

  def log_failed message_attributes
    update_attribute(:ended_at, Time.now)
    CleanUpResult.create(clean_up: self, message_key: :failed, message_attributes: message_attributes)
  end
end
