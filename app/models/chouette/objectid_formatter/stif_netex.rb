module Chouette
  module ObjectidFormatter
    class StifNetex
      def before_validation(model)
        model.attributes = {objectid: "__pending_id__#{SecureRandom.uuid}"}
      end

      def after_commit(model)
        oid = Chouette::Objectid::StifNetex.new(provider_id: "stif", object_type: model.class.name.gsub('Chouette::',''), local_id: model.local_id)
        model.update(objectid: oid.to_s) if oid.valid?
      end

      def get_objectid(definition)
        parts = definition.try(:split, ":")
        Chouette::Objectid::StifNetex.new(provider_id: parts[0], object_type: parts[1], local_id: parts[2], creation_id: parts[3])
      end

      def self.short_id_type
        :int
      end
    end
  end
end
