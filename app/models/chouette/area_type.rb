class Chouette::AreaType
  include Comparable

  COMMERCIAL = %i(zdep zder zdlp zdlr lda gdl).freeze
  NON_COMMERCIAL = %i(deposit border service_area relief other).freeze
  ALL = COMMERCIAL + NON_COMMERCIAL

  @@commercial = COMMERCIAL
  @@non_commercial = NON_COMMERCIAL
  @@all = ALL
  mattr_accessor :all, :commercial, :non_commercial

  def self.commercial=(values)
    @@commercial = COMMERCIAL & values
    reset_caches!
  end

  def self.non_commercial=(values)
    @@non_commercial = NON_COMMERCIAL & values
    reset_caches!
  end

  @@instances = {}
  def self.find(code)
    return unless code

    code = code.to_sym
    @@instances[code] ||= new(code) if ALL.include? code
  end

  def self.reset_caches!
    @@all = @@commercial + @@non_commercial
    @@instances = {}
    @@options = {}
  end

  def self.options(kind=:all)
    @@options ||= {}
    @@options[kind] ||= self.send(kind).map { |c| find(c) }.map { |t| [ t.label, t.code ] }
  end

  attr_reader :code
  def initialize(code)
    @code = code
  end

  def <=>(other)
    all.index(code) <=> all.index(other.code)
  end

  def label
    I18n.translate code, scope: 'area_types.label'
  end

end
