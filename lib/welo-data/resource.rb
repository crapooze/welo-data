require 'welo-data/promise'
require 'welo'

module Welo::Data
  # A Welo::Data::Resource is a sort of interface for persisting resources.
  module Resource
    # patches the path method
    # XXX maybe send this fix in welo instead
    def path(id=:default)
      File.join('', super)
    end

    def promise?
      false
    end

    attr_accessor :id

    def new_id
      "#{Time.now.tv_sec}-#{rand(65535)}"
    end

    # Initializes a new Data object given a hash of values.
    # if populate is true, then values are populated insted of directly merged
    def initialize(values, populate=false)
      if populate
        populate_with! values
      else
        merge! values
      end
      @id ||= new_id
      yield self if block_given?
    end

    # Assigns all values of the hash to this object.
    # No verification is done:
    # - no verification if one methods overwrite a value
    # - no verification if one values is not "valid" for your object 
    def merge!(hash)
      hash.each_pair do |k,v|
        self.send("#{k}=", v)
      end
    end

    # Populates every fields from the hash with populate_field.
    def populate_with!(hash)
      hash.each_pair do |k,v|
        populate_field k, v
      end
    end

    # Populate one field named k with value v.
    # If there is a relationship for this field, then, instead of loading
    # the values, Calf creates promises to later load the value if necessary.
    def populate_field(k,v)
      rel = relationship(k.to_sym)
      v = related_field_value(rel, v) if rel
      self.send("#{k}=", v)
    end

    # Returns the value for a relationship value for later retrieval.
    def related_field_value(rel, v)
      klass = self.class.const_get(rel.klass)
      if rel.many?
        if v.empty? or v.first.is_a?(klass)
          v
        else
          v.map{|path| Promise.new(klass, path)}
        end
      else
        if v.is_a?(klass)
          v
        else
          Promise.new(klass, v)
        end
      end
    end
  end
end
