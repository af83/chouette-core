class FullTimeZoneInput < SimpleForm::Inputs::CollectionSelectInput
  def collection
    @collection ||= begin
      collection = options.delete(:collection) || begin
        coll = {}

        TZInfo::Timezone.all_data_zones.map do |tzinfo|
          # v = ActiveSupport::TimeZone.zones_map[k]
        # coll.sort_by do |v|
        #   "(#{v.formatted_offset}) #{v.name}"
        # end
          next if tzinfo.friendly_identifier =~ /^etc/i
          tz = ActiveSupport::TimeZone.new tzinfo.name#, nil, tzinfo
          coll[[tz.utc_offset, tzinfo.friendly_identifier(true)]] = ["(#{tz.formatted_offset}) #{tzinfo.friendly_identifier(true)}", tz.name]
        end
        coll.sort.map(&:last)
      end
      collection.respond_to?(:call) ? collection.call : collection.to_a
    end
  end

  def detect_collection_methods
    label, value = options.delete(:label_method), options.delete(:value_method)

    label ||= :first
    value ||= :last
    [label, value]
  end

  def input_html_options
    options = super
    options[:data] = (options[:data] || {}).merge(select2ed: true)
    options
  end

  def input(wrapper_options = {})
    super wrapper_options
  end
end
