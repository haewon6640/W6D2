require_relative '02_searchable'
require 'active_support/inflector'

# Phase IIIa
class AssocOptions
  attr_accessor(
    :foreign_key,
    :class_name,
    :primary_key
  )

  def model_class
    # ...
    self.class_name.constantize
  end

  def table_name
    # ...
    self.class_name.downcase + 's'
  end
end

class BelongsToOptions < AssocOptions
  def initialize(name, options = {})
    # ...
    self.primary_key = :id
    self.foreign_key = "#{name}_id".to_sym
    self.class_name = "#{name.to_s.camelcase}"
    options.each do |k,v|
      self.send("#{k.to_s}=",v)
    end
  end
end

class HasManyOptions < AssocOptions
  def initialize(name, self_class_name, options = {})
    # ...
    self.primary_key = :id
    self.foreign_key = "#{self_class_name.downcase.underscore}_id".to_sym
    self.class_name = name.singularize.camelcase
    options.each do |k,v|
      self.send("#{k.to_s}=",v)
    end
  end
end

module Associatable
  # Phase IIIb
  def belongs_to(name, options = {})
    # ...
    options = BelongsToOptions.new(name, options)

    define_method(name) {
      foreign_key = self.send(options.foreign_key)
      cl = options.model_class
      cl.where(options.primary_key => foreign_key).first
    }

  end

  def has_many(name, options = {})
    # ...
    
  end

  def assoc_options
    # Wait to implement this in Phase IVa. Modify `belongs_to`, too.
  end
end

class SQLObject
  # Mixin Associatable here...
  extend Associatable
end
