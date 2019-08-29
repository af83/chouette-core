module TransportModeEnumerations
  extend ActiveSupport::Concern

  included do |source|
    extend Enumerize
    enumerize :transport_mode, in: TransportModeEnumerations.transport_modes

    begin
      if source.column_names.include?('transport_submode')
        enumerize :transport_submode, in: TransportModeEnumerations.transport_submodes
      end
    rescue ActiveRecord::StatementInvalid
      # The tables have not been created yet
    end
  end

  def transport_mode_and_submode_match
    return unless transport_mode.present?

    return if transport_submode.blank?
    return if TransportModeEnumerations.full_transport_modes[transport_mode&.to_sym]&.include?(transport_submode.to_sym)

    errors.add(:transport_mode, :submode_mismatch)
  end

  module ClassMethods
    def transport_modes
      TransportModeEnumerations.transport_modes
    end

    def sorted_transport_modes
      TransportModeEnumerations.sorted_transport_modes
    end

    def transport_submodes
      TransportModeEnumerations.transport_submodes
    end

    def formatted_submodes_for_transports(modes=nil)
      TransportModeEnumerations.formatted_submodes_for_transports(modes)
    end
  end

  class << self
    def transport_modes
      full_transport_modes.keys
    end

    def transport_submodes
      full_transport_modes.values.flatten.uniq
    end

    def full_transport_modes
      {
        metro: [
          :undefined,
          :metro,
          :tube,
          :urbanRailway
        ],
        funicular: [
          :undefined,
          :allFunicularServices,
          :funicular,
        ],
        tram: [
          :undefined,
          :cityTram,
          :localTram,
          :regionalTram,
          :shuttleTram,
          :sightseeingTram,
          :tramTrain
        ],
        rail: [
          :undefined,
          :carTransportRailService,
          :crossCountryRail,
          :highSpeedRail,
          :international,
          :interregionalRail,
          :local,
          :longDistance,
          :nightTrain,
          :rackAndPinionRailway,
          :railShuttle,
          :replacementRailService,
          :sleeperRailService,
          :specialTrain,
          :suburbanRailway,
          :touristRailway,
        ],
        coach: [
          :undefined,
          :commuterCoach,
          :internationalCoach,
          :nationalCoach,
          :regionalCoach,
          :shuttleCoach,
          :sightseeingCoach,
          :specialCoach,
          :touristCoach,
        ],
        bus: [
          :undefined,
          :airportLinkBus,
          :demandAndResponseBus,
          :expressBus,
          :localBus,
          :mobilityBusForRegisteredDisabled,
          :mobilityBus,
          :nightBus,
          :postBus,
          :railReplacementBus,
          :regionalBus,
          :schoolAndPublicServiceBus,
          :schoolBus,
          :shuttleBus,
          :sightseeingBus,
          :specialNeedsBus,
        ],
        water: [
          :undefined,
          :internationalCarFerry,
          :nationalCarFerry,
          :regionalCarFerry,
          :localCarFerry,
          :internationalPassengerFerry,
          :nationalPassengerFerry,
          :regionalPassengerFerry,
          :localPassengerFerry,
          :postBoat,
          :trainFerry,
          :roadFerryLink,
          :airportBoatLink,
          :highSpeedVehicleService,
          :highSpeedPassengerService,
          :sightseeingService,
          :schoolBoat,
          :cableFerry,
          :riverBus,
          :scheduledFerry,
          :shuttleFerryService
        ],
        telecabin: [
          :undefined,
          :cableCar,
          :chairLift,
          :dragLift,
          :lift,
          :telecabinLink,
          :telecabin,
        ],
        air: [
          :undefined,
          :airshipService,
          :domesticCharterFlight,
          :domesticFlight,
          :domesticScheduledFlight,
          :helicopterService,
          :intercontinentalCharterFlight,
          :intercontinentalFlight,
          :internationalCharterFlight,
          :internationalFlight,
          :roundTripCharterFlight,
          :schengenAreaFlight,
          :shortHaulInternationalFlight,
          :shuttleFlight,
          :sightseeingFlight,
        ],
        hireCar: [
          :undefined,
          :allHireVehicles,
          :hireCar,
          :hireCycle,
          :hireMotorbike,
          :hireVan,
        ],
        taxi: [
          :undefined,
          :allTaxiServices,
          :bikeTaxi,
          :blackCab,
          :communalTaxi,
          :miniCab,
          :railTaxi,
          :waterTaxi,
        ]
      }
    end

    def sorted_transport_modes(modes=nil)
      modes ||= transport_modes
      transport_modes.sort_by do |m|
        I18n.t("enumerize.transport_mode.#{m}").parameterize
      end
    end

    def formatted_submodes_for_transports(modes=nil)
      modes ||= full_transport_modes
      modes.map do |t,s|
        {
          t => s.map do |k|
            [I18n.t("enumerize.transport_submode.#{ k.presence || 'undefined' }"), k]
          end.sort_by { |k| k.last ? k.first : "" }
        }
      end.reduce({}, :merge)
    end
  end
end
