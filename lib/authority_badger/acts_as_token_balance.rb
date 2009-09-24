module AuthorityBadger
  module ActsAsTokenBalance
    
    def self.included(base)
      base.extend ActMethods
    end 

    module ActMethods
      def acts_as_token_balance
        belongs_to :owner, :polymorphic => true
        belongs_to :token
        
        has_many :transactions, :class_name => 'TokenTransaction'
        
        named_scope :about, lambda { |about| { :include => :tokens, :conditions => ["tokens.name = ?", about.to_s] } }
        
        attr_accessible :token, :value, :owner

        validates_presence_of :token, :value, :owner
        
        send("before_update", Proc.new { |p| p.create_transaction })
        
        include InstanceMethods
        extend ClassMethods
      end
      
      module InstanceMethods
        attr_accessor :description_on_transaction
        attr_accessor :reference_on_transaction
        
        def create_transaction
          self.transactions.create({
            :reference            => self.reference_on_transaction,
            :token_amount_value   => self.value_was - self.value,
            :token_balance_before => self.value_was,
            :token_balance_after  => self.value,
            :description          => self.description_on_transaction
          })
        end
        
        def value?
          self.value == -1
        end
        
        def enough?
          self.value? || self.value > 0
        end
        
        def has_owner_used?(reference)
          self.transactions.exists?(:reference_id => reference.id, :reference_type => reference.class.to_s)
        end
        
        def update_balance(value, options = {})
          self.description_on_transaction = options[:desc] || nil
          self.reference_on_transaction   = options[:ref]  || nil
          
          self.value = value
          self.save
        end
        
        def increment(options = {})
          options[:by] ||= 1
          
          self.description_on_transaction = options[:desc] || nil
          self.reference_on_transaction   = options[:ref]  || nil
          
          unless self.value == -1
            value = self.value.nil? ? options[:by] : self.value += options[:by]
            self.value = value
            self.save
          end
        end
        
        def decrement(options = {})
          options[:by] ||= 1
          
          self.description_on_transaction = options[:desc] || nil
          self.reference_on_transaction   = options[:ref]  || nil
          
          unless self.value == -1
            value = self.value -= options[:by]
            value = 0 if value < 0
            self.value = value
            self.save
          end
        end
        
        def between?(min, max)
          self.value >= min && self.value <= max
        end
        
        def unlimited
          self.update_attribute(:value, -1)
        end
        
        def reset
          self.update_attribute(:value, nil)
        end
        
        def clear
          self.update_attribute(:value, 0)
        end
        
        def to_s
          self.value
        end

        def to_i
          self.value
        end
                
        def trigger_token_balance_callback(action)
          action.is_a?(Proc) ? action.call(self) : self.send(action.to_s)
        end
        
        def trigger_token_balance_callback?(options = {})
          return false unless self.name == options[:about].to_s
          
          if options[:if].nil?
            if_condition = true
          elsif options[:if].is_a?(Proc)
            if_condition = options[:if].call(self)
          else
            if_condition = self.send(options[:if].to_s)
          end
          
          if options[:unless].nil?
            unless_condition = false
          elsif options[:unless].is_a?(Proc)
            unless_condition = options[:unless].call(self)
          else
            unless_condition = self.send(options[:unless].to_s)
          end
          
          if options[:from].nil?
            from_condition = true
          else
            from_condition = self.value_was == options[:from]
          end
          
          if options[:to].nil?
            to_condition = true
          else
            to_condition = self.value == options[:to]
          end
          
          if_condition && !unless_condition && from_condition && to_condition
        end
      end
      
      module ClassMethods
        
        def balance(options = {})
          options[:about]  ||= ""
          options[:on]     ||= ""
          options[:do]     ||= ""
          options[:from]   ||= nil
          options[:to]     ||= nil
          options[:if]     ||= nil
          options[:unless] ||= nil
          
          if options[:about].present? && options[:on].present? && options[:do].present?
            send("before_#{options[:on]}", Proc.new { |p| p.trigger_token_balance_callback(options[:do]) }, :if => Proc.new { |p| p.trigger_token_balance_callback?(options) })
          end
        end
      end
    end
    
  end
end