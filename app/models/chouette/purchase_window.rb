require 'range_ext'
require_relative '../calendar/period'

module Chouette
  class PurchaseWindow < Chouette::TridentActiveRecord
    # include ChecksumSupport
    include ObjectidSupport
    include PeriodSupport
    include ChecksumSupport
    extend Enumerize

    enumerize :color, in: %w(#9B9B9B #FFA070 #C67300 #7F551B #41CCE3 #09B09C #3655D7 #6321A0 #E796C6 #DD2DAA)

    has_metadata
    belongs_to :referential
    has_and_belongs_to_many :vehicle_journeys, :class_name => 'Chouette::VehicleJourney'

    validates_presence_of :name, :referential, :date_ranges

    scope :contains_date, ->(date) { where('date ? <@ any (date_ranges)', date) }
    scope :overlap_dates, ->(date_range) { where('daterange(?, ?) && any (date_ranges)', date_range.first, date_range.last + 1.day) }
    scope :matching_dates, ->(date_range) { where('ARRAY[daterange(?, ?)] = date_ranges', date_range.first, date_range.last + 1.day) }

    # VehicleJourneys include PurchaseWindow checksums in their checksums
    # OPTIMIZEME
    def update_vehicle_journey_checksums
      vehicle_journeys.find_each(&:update_checksum!)
    end
    after_commit :update_vehicle_journey_checksums

    def self.ransackable_scopes(auth_object = nil)
      [:contains_date]
    end

    def self.colors_i18n
      Hash[*color.values.map{|c| [I18n.t("enumerize.purchase_window.color.#{c[1..-1]}"), c]}.flatten]
    end

    def local_id
      "IBOO-#{self.referential.id}-#{self.id}"
    end

    def checksum_attributes
      attrs = ['name', 'color', 'referential_id']
      ranges_attrs = date_ranges.map{|r| [r.min, r.max]}.flatten.sort
      self.slice(*attrs).values + ranges_attrs
    end

    def bounding_dates
      [
        date_ranges.map(&:first).min,
        date_ranges.map(&:max).max,
      ]
    end

    def color
      _color = read_attribute(:color)
      _color.present? ? _color : nil
    end
  end
end
