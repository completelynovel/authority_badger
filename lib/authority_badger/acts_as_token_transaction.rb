module AuthorityBadger
  module ActsAsTokenTransaction
    
    def self.included(base)
      base.extend ActMethods
    end 

    module ActMethods
      def acts_as_token_transaction
        belongs_to :token_balance
        
        has_one :token, :through => :token_balance
        
        belongs_to :reference, :polymorphic => true
        
        attr_accessible :token_amount_value, :token_balance_before, :token_balance_after, :reference, :description
        
        validates_presence_of :token_amount_value, :token_balance_before, :token_balance_after
        
        named_scope :described, :conditions => ["token_transactions.description IS NOT NULL AND token_transactions.description != ''"]
      end
    end
    
  end
end