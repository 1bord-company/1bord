class ApplicationRecord < ActiveRecord::Base
  primary_abstract_class

  def self.belongs_to(name, scope = nil, **options)
    return super unless cross_domain? name
    return super if options[:polymorphic]

    options.merge! class_name: cross_domain_class_name(name).singularize

    super
  end

  def self.has_many(name, scope = nil, **options, &extension)
    return super unless cross_domain? name
    return super if options[:through]

    options.merge! class_name: cross_domain_class_name(name).singularize

    super
  end

  private

  def self.cross_domain?(name) = name.to_s.include?('__')

  def self.cross_domain_class_name(relation_name)
    relation_name.to_s.split('__').map(&:camelize).join('::')
  end
end
