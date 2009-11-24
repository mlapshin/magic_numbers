module ActiveRecord
  module MagicNumbers

    def self.included(base)
      base.extend(ClassMethods)
      base.send(:include, InstanceMethods)
    end

    module ClassMethods

      def enum_column(name, options = {})
        magic_number_column(name, options.merge({ :type => :enum }))
      end

      def bitfield_column(name, options = {})
        magic_number_column(name, options.merge({ :type => :bitfield }))
      end

      def magic_number_for(name, value)
        return nil if value.nil?
        column_options = magic_number_column_options(name)

        if column_options[:type] == :bitfield
          value = value.map do |v|
            column_options[:stringified_values].include?(v.to_s) ? v.to_s.intern : nil
          end.compact.uniq

          magic_number = 0
          value.each { |k| magic_number |= 1 << column_options[:values].index(k) }
          magic_number
        else
          if column_options[:stringified_values].include?(value.to_s)
            column_options[:values].index(value.to_s.intern)
          else
            nil
          end
        end
      end

      def magic_number_column_options(name)
        magic_number_columns = read_inheritable_attribute(:magic_number_columns) || {}

        if magic_number_columns.include?(name)
          magic_number_columns[name]
        else
          raise ArgumentError, "Could not find magic number column `#{name}` in class #{self.class.name}"
        end
      end

    protected

      def magic_number_accessors(name)
        class_eval <<-EOE
          def #{name}; magic_number_read(:#{name}); end
          def #{name}=(new_value); magic_number_write(:#{name}, new_value); end
        EOE
      end

      def magic_number_column(name, options = {})
        magic_number_columns = read_inheritable_attribute(:magic_number_columns) || {}
        options.assert_valid_keys(:values, :type)

        options[:stringified_values] = options[:values].map { |v| v.to_s }
        magic_number_columns[name] = options
        write_inheritable_attribute(:magic_number_columns, magic_number_columns)
        magic_number_accessors(name)
      end

    end

    module InstanceMethods

      def magic_number_read(name)
        column_options = self.class.magic_number_column_options(name)

        if column_options[:type] == :bitfield
          unless self[name].nil?
            column_options[:values].collect { |v| (self[name].to_i & (1 << column_options[:values].index(v))) > 0 ? v : nil }.compact
          else
            []
          end
        else
          unless self[name].nil?
            column_options[:values][self[name]]
          else
            nil
          end
        end
      end

      def magic_number_write(name, new_value)
        column_options = self.class.magic_number_column_options(name)
        self[name] = self.class.magic_number_for(name, new_value)
      end

    end
  end
end

ActiveRecord::Base.send(:include, ActiveRecord::MagicNumbers)
