class ReferentialAudit
  class Base
    include ProfilingSupport

    include Rails.application.routes.url_helpers

    attr_reader :status

    def self.inherited klass
      ReferentialAudit::FullReferential.register klass
    end

    def initialize referential, profiler: nil
      @referential = referential
      @profiler = profiler
    end

    def faulty
      @faulty ||= @referential.switch { find_faulty }
    end

    def perform logger
      faulty.each do |record|
        logger.add_error full_message(record, output: logger.output)
      end
      if faulty.size == 0 || faulty == [nil]
        @status = :success
      else
        @status = :error
      end
    end

    def full_message record, output: :console
      message(record, output: output)
    end

    def self.pretty_name
      self.name.split("::").last
    end

    def pretty_name
      self.class.pretty_name
    end

    def base_host
      SmartEnv['RAILS_HOST']
    end

    def link_to label, url
      "<a href='#{url}'>#{label}</a>"
    end
  end
end

require_dependency 'referential_audit/checksums'
require_dependency 'referential_audit/journey_pattern_distances'
require_dependency 'referential_audit/journey_pattern_stop_points'
require_dependency 'referential_audit/vehicle_journey_at_stop_times'
require_dependency 'referential_audit/vehicle_journey_initial_offset'
