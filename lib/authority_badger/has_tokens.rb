module AuthorityBadger
  module HasTokens

    def self.included(base)
      base.extend(ActMethods)
    end 

    module ActMethods
      def has_tokens
        has_many :token_balances, :as => :owner
        
        has_many :token_transactions, :through => :token_balances, :source => :transactions, :foreign_key => :owner_id
        
        include InstanceMethods
      end
      
      module InstanceMethods
        def create_tokens(tokens)
          tokens.each do |name, value|
            self.create_token(name, value)
          end
        end
        
        def update_tokens(tokens)
          tokens.each do |name, token|
            case token["action"].to_s
            when "create"
              self.create_token(name token["value"])
            when "update"
              self.update_token(name, token["value"])
            when "destroy"
              self.token(name).destroy
            when "sum"
              self.increment_token(name, token["value"])
            end
          end
        end
        
        def create_token(name, value)
          token = Token.find_by_name(name)
          
          if token.present? && !self.token_balances.exists?(:token_id => token)
            self.token_balances.create do |tb|
              tb.token = Token.find_by_name(name)
              tb.value = value.to_i
            end
          end
        end
        
        def update_token(name, value, options = {})
          self.token(name).update_balance(value, options)
        end
        
        def destroy_tokens(tokens)
          tokens.each do |name, value|
            self.destroy_token(name)
          end
        end
        
        def destroy_token(name)
          self.token(name).destroy
        end
        
        def token(name)
          self.token_balances.first(:conditions => { :name => name.to_s })
        end
        
        def token?(name, reference = nil)
          reference.present? ? self.token(name).has_owner_used?(reference) : self.token(name).value?
        end
        
        def enough_token?(name)
          self.token(name).enough?
        end
        
        def increment_token(name, options = {})
          self.token(name).increment(options)
        end
        
        def decrement_token(name, options = {})
          self.token(name).decrement(options)
        end

        def credits_token(name, options = {})
          self.increment_token(name, options)
        end
        
        def use_token(name, options = {})
          self.decrement_token(name, options)
        end
        
        def unlimited_token(name)
          self.token(name).unlimited
        end
        
        def reset_token(name)
          self.token(name).reset
        end
        
        def clear_token(name)
          self.token(name).clear
        end
      end
    end

  end
end