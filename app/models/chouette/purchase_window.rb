require 'range_ext'
require_relative '../calendar/period'

module Chouette
  class PurchaseWindow < Chouette::TridentActiveRecord
    # include ChecksumSupport
    include ObjectidSupport
    include PeriodSupport
    extend Enumerize
    enumerize :color, in: %w(#9B9B9B #FFA070 #C67300 #7F551B #41CCE3 #09B09C #3655D7 #6321A0 #E796C6 #DD2DAA)

    has_paper_trail
    belongs_to :referential
    has_and_belongs_to_many :vehicle_journeys, :class_name => 'Chouette::VehicleJourney'

    validates_presence_of :name, :referential

    scope :contains_date, ->(date) { where('date ? <@ any (date_ranges)', date) }
    
    def self.ransackable_scopes(auth_object = nil)
      [:contains_date]
    end

    def self.colors_i18n
      Hash[*color.values.map{|c| [I18n.t("enumerize.purchase_window.color.#{c[1..-1]}"), c]}.flatten]
    end

    def local_id
      "IBOO-#{self.referential.id}-#{self.id}"
    end

    # def checksum_attributes
    # end

  end
end
