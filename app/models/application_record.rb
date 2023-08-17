class ApplicationRecord < ActiveRecord::Base
  primary_abstract_class

  def self.belongs_to(name, scope = nil, **options)
    return super if name.to_s.exclude? '__'
    return super if options[:polymorphic]

    options.merge! class_name: name.to_s.split('__').map(&:camelize).join('::')

    super
  end

  def self.has_many(name, scope = nil, **options, &extension)
    return super if name.to_s.exclude? '__'
    return super if options[:through]

    options.merge! class_name: name.to_s
                                   .split('__')
                                   .map(&:camelize)
                                   .join('::')
                                   .singularize

    super
  end
end
