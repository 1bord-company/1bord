module ActiveRecord::CreateOrFindAndUpdateBy
  def create_or_find_and_update_by!(attributes, &block)
    create_or_find_by!(attributes, &block)
  rescue ActiveRecord::RecordNotFound
    mappings =
      model
      .reflect_on_all_associations
      .select { _1.is_a? ActiveRecord::Reflection::BelongsToReflection }
      .select { _1.options[:polymorphic] }
      .collect { [_1.name, { foreign_key: _1.foreign_key.to_sym,
                             foreign_type: _1.foreign_type.to_sym }] }.to_h

    mappings.each do |attribute_name, mapping|
      attributes[mapping[:foreign_key]] = attributes[attribute_name].id
      attributes[mapping[:foreign_type]] = attributes[attribute_name].class.name
      attributes.delete attribute_name
    end

    uniqueness_columns =
      base_class.connection.indexes(base_class.table_name)
      .flat_map(&:columns).map(&:to_sym)
    unique_attributes =
      attributes.slice *uniqueness_columns

    find_by(unique_attributes, &block).tap { _1.update(attributes) }
  end
end
