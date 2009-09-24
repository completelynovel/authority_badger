module AuthorityBadger
  module ActsAsTokenPrice
    
    def self.included(base)
      base.extend ActMethods
    end 

    module ActMethods
      def acts_as_token_price
        belongs_to :token
        
        belongs_to :reference, :polymorphic => true
        
        attr_accessible :currency, :value, :reference
        
        validates_presence_of :token, :currency, :value
      end
    end
    
  end
end