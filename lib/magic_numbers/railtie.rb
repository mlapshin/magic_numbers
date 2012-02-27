module MagicNumbers
  class Railtie < ::Rails::Railtie
    ActiveSupport.on_load :active_record do
      ActiveRecord::Base.send(:include, MagicNumbers::Base)
    end    
  end
end