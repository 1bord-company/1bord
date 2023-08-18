class ApplicationRecord < ActiveRecord::Base
  primary_abstract_class

  class << self
    def belongs_to(name, scope = nil, **options)
      return super unless cross_domain? name
      return super if options[:polymorphic]

      options.merge! class_name: cross_domain_class_name(name).singularize

      super
    end

    def has_many(name, scope = nil, **options, &extension)
      return super unless cross_domain? name

      options.merge! class_name: cross_domain_class_name(name).singularize

      super
    end

    private

    def cross_domain?(name) = name.to_s.include?('__')

    def cross_domain_class_name(relation_name)
      relation_name.to_s.split('__').map(&:camelize).join('::')
    end
  end
end
