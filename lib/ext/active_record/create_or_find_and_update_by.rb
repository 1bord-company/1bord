module ActiveRecord::CreateOrFindAndUpdateBy
  def create_or_find_and_update_by!(attributes, &block)
    create_or_find_by!(attributes, &block)
  rescue ActiveRecord::RecordNotFound
    unique_attribute_names = attributes_in_unique_indexes(self.base_class)
    unique_attributes = attributes.slice *unique_attribute_names

    create_or_find_by!(unique_attributes, &block)
      .tap { _1.update(attributes) }
  end

  private

  def attributes_in_unique_indexes(ar_class)
    unique_attributes = []

    ar_class.connection.indexes(ar_class.table_name).each do |index|
      next unless index.unique

      index_columns = index.columns

      index_columns.each do |column|
        if column.ends_with?('_type') && index_columns.include?(column.sub('_type', '_id'))
          unique_attributes << column.sub('_type', '').to_sym
          unique_attributes << column.sub('_type', '_id').to_sym
        elsif column.ends_with?('_id') && index_columns.include?(column.sub('_id', '_type'))
          unique_attributes << column.sub('_id', '').to_sym
          unique_attributes << column.sub('_id', '_type').to_sym
        else
          unique_attributes << column.to_sym
        end
      end
    end

    unique_attributes.uniq
  end
end
