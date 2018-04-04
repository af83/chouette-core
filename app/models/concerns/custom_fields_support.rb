module CustomFieldsSupport
  extend ActiveSupport::Concern

  included do
    validate :custom_fields_values_are_valid
    after_initialize :initialize_custom_fields

    def self.custom_fields workgroup=nil
      fields = CustomField.where(resource_type: self.name.split("::").last)
      fields = fields.where(workgroup_id: workgroup.id) if workgroup.present?
      fields
    end

    def custom_fields workgroup=nil
      CustomField::Collection.new self, workgroup
    end

    def custom_field_values= vals
      out = {}
      custom_fields.each do |code, field|
        out[code] = field.preprocess_value_for_assignment(vals.symbolize_keys[code.to_sym])
      end
      write_attribute :custom_field_values, out
    end

    def initialize_custom_fields
      self.custom_field_values ||= {}
      custom_fields.values.each &:initialize_custom_field
      custom_fields.each do |k, v|
        custom_field_values[k] ||= v.default_value
      end
    end

    def custom_field_value key
      (custom_field_values&.stringify_keys || {})[key.to_s]
    end

    private
    def custom_fields_values_are_valid
      custom_fields.values.all?{|cf| cf.valid?}
    end
  end
end
