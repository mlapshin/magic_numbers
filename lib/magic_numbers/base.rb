module MagicNumbers
  module Base
    extend ::ActiveSupport::Concern
    
    included do
      class_attribute :magic_number_attributes, :instance_writer => false
    end

    module ClassMethods

      def enum_attribute(name, options = {})
        magic_number_attribute(name, options.merge({ :type => :enum }))
      end

      def bitfield_attribute(name, options = {})
        magic_number_attribute(name, options.merge({ :type => :bitfield }))
      end

      def magic_number_for(name, value)
        return nil if value.nil?
        attribute_options = magic_number_attribute_options(name)

        if attribute_options[:type] == :bitfield
          value = value.map do |v|
            attribute_options[:stringified_values].include?(v.to_s) ? v.to_s.intern : nil
          end.compact.uniq

          magic_number = 0
          value.each { |k| magic_number |= 1 << attribute_options[:values].index(k) }
          magic_number
        else
          if attribute_options[:stringified_values].include?(value.to_s)
            attribute_options[:values].index(value.to_s.intern)
          else
            nil
          end
        end
      end

      def magic_number_attribute_options(name)
        magic_number_attributes = self.magic_number_attributes || {}

        if magic_number_attributes.include?(name)
          magic_number_attributes[name]
        else
          raise ArgumentError, "Could not find magic number attribute `#{name}` in class #{self.class.name}"
        end
      end

    protected

      def magic_number_accessors(name)
        class_eval <<-EOE
          def #{name}; magic_number_read(:#{name}); end
          def #{name}=(new_value); magic_number_write(:#{name}, new_value); end
        EOE
      end

      def magic_number_attribute(name, options = {})
        magic_number_attributes = self.magic_number_attributes || {}
        options.assert_valid_keys(:values, :type)

        options[:stringified_values] = options[:values].map { |v| v.to_s }
        magic_number_attributes[name] = options
        self.magic_number_attributes = magic_number_attributes
        magic_number_accessors(name)
      end

    end

    def magic_number_read(name)
      attribute_options = self.class.magic_number_attribute_options(name)

      if attribute_options[:type] == :bitfield
        unless self[name].nil?
          attribute_options[:values].collect { |v| (self[name].to_i & (1 << attribute_options[:values].index(v))) > 0 ? v : nil }.compact
        else
          []
        end
      else
        unless self[name].nil?
          attribute_options[:values][self[name]]
        else
          nil
        end
      end
    end

    def magic_number_write(name, new_value)
      attribute_options = self.class.magic_number_attribute_options(name)
      self[name] = self.class.magic_number_for(name, new_value)

      new_value
    end
  end
end
