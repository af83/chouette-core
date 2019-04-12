module ReferentialIndexSupport
  extend ActiveSupport::Concern

  def self.target_relations
    @target_relations ||= []
  end

  def self.register_target_relation(rel)
    target_relations.push rel
  end

  included do
    class << self
      def belongs_to_public(rel_name, opts={})
        rel = ReferentialIndexRelation.new(self, rel_name, opts)
        referential_index_relations[rel.cache_key] = rel

        ReferentialIndexSupport.register_target_relation rel

        after_commit on: %i[create update] do
          CrossReferentialIndexEntry.update_index_with_relation_from_target rel, self
        end

        after_destroy do
          CrossReferentialIndexEntry.clean_index_from_target self
        end
      end

      def has_many_scattered(rel_name, opts={})
        rel = ReferentialIndexRelation.new(self, rel_name, opts)

        raise MissingReciproqueRelation.new("Missing reciproque relation for #{self.name}##{rel_name} on #{target_class.name}") unless rel.reciproque.present?
        referential_index_relations[rel.cache_key] = rel

        define_method(rel_name) do
          ReferentialIndexRelationProxy.new(self, rel_name)
        end

        after_destroy do
          CrossReferentialIndexEntry.clean_index_from_parent self
        end
      end

      def referential_index_relations
        @referential_index_relations ||= {}
      end
    end
  end

  class ReferentialIndexRelation
    def initialize(parent_class, rel_name, opts={})
      @parent_class = parent_class
      @rel_name = rel_name
      @opts = opts
    end

    def name
      @rel_name
    end

    def klass
      @parent_class
    end

    def reciproque
      @reciproque ||= begin
        target_class_name = name.to_s.singularize.classify
        target_class = target_class_name.safe_constantize
        target_class ||= "Chouette::#{target_class_name}".constantize
        target_class.present? ? target_class.referential_index_relations[@parent_class.table_name.split('.').last.to_sym] : nil
      end
    end

    def cache_key
      @rel_name
    end

    def multiple?
      @multiple = name.to_s.pluralize == name.to_s
    end

    def collection(source)
      method = @opts[:collection_name] || name
      if multiple?
        source.send(method)
      else
        [source.send(method)]
      end
    end
  end

  class ReferentialIndexRelationProxy
    def initialize(parent, rel_name)
      @parent = parent
      rel = ReferentialIndexRelation.new(parent.class, rel_name)
      @relation = parent.class.referential_index_relations[rel.cache_key]
    end

    def each
      CrossReferentialIndexEntry.in_each_referential_for(@relation, @parent) do |referential|
        CrossReferentialIndexEntry.each_target_for(@relation, @parent, referential.slug) do |target|
          yield target
        end
      end
    end

    # def map
    #   [].tap do |out|
    #     each do |item|
    #       out << yield(item)
    #     end
    #   end
    # end

    def all
      out = []
      CrossReferentialIndexEntry.in_each_referential_for(@relation, @parent) do |referential|
        out += CrossReferentialIndexEntry.all_targets_for(@relation, @parent, referential.slug)
      end
      out
    end
  end

  class MissingReciproqueRelation < StandardError; end
end
