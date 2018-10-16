module AF83::ChecksumManager
  THREAD_VARIABLE_NAME = "current_checksum_manager".freeze

  class NotInTransactionError < StandardError; end
  class AlreadyInTransactionError < StandardError; end
  class MultipleReferentialsError < StandardError; end

  def self.current
    current_manager = Thread.current.thread_variable_get THREAD_VARIABLE_NAME
    current_manager || self.current = AF83::ChecksumManager::Inline.new
  end

  def self.current= manager
    Thread.current.thread_variable_set THREAD_VARIABLE_NAME, manager
    manager
  end

  def self.logger
    @@logger ||= Rails.logger
  end

  def self.logger= logger
    @@logger = logger
  end

  def self.log_level
    @@log_level ||= :debug
  end

  def self.log_level= log_level
    @@log_level = log_level if logger.respond_to?(log_level)
  end

  def self.log msg
    prefix = "[ChecksumManager::#{current.class.name.split('::').last} #{current.object_id.to_s(16)}]"
    logger.send log_level, "#{prefix} #{msg}"
  end

  def self.start_transaction
    raise AlreadyInTransactionError if in_transaction?
    log "=== NEW TRANSACTION ==="
    self.current = AF83::ChecksumManager::Transactional.new
  end

  def self.in_transaction?
    current.is_a?(AF83::ChecksumManager::Transactional)
  end

  def self.commit
    current.log "=== COMMITTING TRANSACTION ==="
    raise NotInTransactionError unless current.is_a?(AF83::ChecksumManager::Transactional)
    current.commit
    log "=== DONE COMMITTING TRANSACTION ==="
    self.current = nil
  end

  def self.after_create object
    current.after_create object
  end

  def self.after_destroy object
    current.after_destroy object
  end

  def self.transaction
    start_transaction
    yield
    commit
  end

  def self.watch object, from: nil
    current.watch object, from: from
  end

  def self.object_signature object
    SerializedObject.new(object).signature
  end

  def self.checksum_parents object
    klass = object.class
    return [] unless klass.respond_to? :checksum_parent_relations
    return [] unless klass.checksum_parent_relations

    parents = []
    klass.checksum_parent_relations.each do |parent_model, opts|
      belongs_to = opts[:relation] || parent_model.model_name.singular
      has_many = opts[:relation] || parent_model.model_name.plural

      if object.respond_to? belongs_to
       reflection = klass.reflections[belongs_to.to_s]
       if reflection
         parent_id = object.send(reflection.foreign_key)
         parent_class = reflection.klass.name
       else
         # the relation is not a true ActiveRecord Relation
         parent = object.send(belongs_to)
         parents << [parent.class.name, parent.id]
       end
       parents << [parent_class, parent_id] if parent_id
     end
     if object.respond_to? has_many
       reflection = klass.reflections[has_many.to_s]
       if reflection
         parents += [reflection.klass.name].product(object.send(has_many).pluck(reflection.foreign_key).compact)
       else
         # the relation is not a true ActiveRecord Relation
         parents += object.send(has_many).map {|parent| [parent.class.name, parent.id] }
       end
     end
    end
    parents.compact
  end

  def self.parents_to_sentence parents
    parents.group_by(&:first).map{ |klass, v| "#{v.size} #{klass}" }.to_sentence
  end

  def self.child_after_save object
    if object.changed? || object.destroyed?
      parents = checksum_parents object
      log "Request from #{object.class.name}##{object.id} checksum updates for #{parents.count} parent(s): #{parents_to_sentence(parents)}"
      parents.each { |parent| watch parent, from: object }
    end
  end

  def self.child_before_destroy object
    parents = checksum_parents object

    log "Prepare request for #{object.class.name}##{object.id} deletion checksum updates for #{parents.count} parent(s): #{parents_to_sentence(parents)}"

    @_parents_for_checksum_update ||= {}
    @_parents_for_checksum_update[object_signature(object)] = parents
  end

  def self.child_after_destroy object
    if @_parents_for_checksum_update.present? && @_parents_for_checksum_update[object_signature(object)].present?
      parents = @_parents_for_checksum_update[object_signature(object)]
      log "Request from #{object.class.name}##{object.id} checksum updates for #{parents.count} parent(s): #{parents_to_sentence(parents)}"
      parents.each { |parent| AF83::ChecksumManager.watch parent, from: object }
      @_parents_for_checksum_update.delete object
    end
  end
end
