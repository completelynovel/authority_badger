module AuthorityBadger
  module ActsAsToken
    
    def self.included(base)
      base.extend ActMethods
    end 

    module ActMethods
      def acts_as_token
        has_many :prices, :class_name => 'TokenPrice'
        has_many :balances, :class_name => 'TokenBalance'
        
        attr_accessible :name
        
        validates_presence_of :name
        
        include InstanceMethods
      end
      
      module InstanceMethods
        def price(currency)
          self.prices.of_currency(currency)
        end
      end
    end
    
  end
end