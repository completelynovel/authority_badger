module AuthorityBadger
  module ActsAsPermission
    
    def self.included(base)
      base.extend ActMethods
    end 

    module ActMethods
      def acts_as_permission
        belongs_to :owner, :polymorphic => true
        
        named_scope :about, lambda { |about| { :conditions => ["permissions.name = ?", about.to_s] } }
        
        attr_accessible :name, :value, :owner

        validates_presence_of :name, :value, :owner
        
        include InstanceMethods
        extend ClassMethods
      end
      
      module InstanceMethods
        def value?
          self.value == 1 || self.value == -1
        end
        
        def enough?
          self.value? || self.value > 0
        end
        
        def increment(by = 1)
          unless self.value == -1
            value = self.value.nil? ? by : self.value += by
            self.update_attribute(:value, value) 
          end
        end
        
        def decrement(by = 1)
          unless self.value == -1
            value = self.value -= by
            value = 0 if value < 0
            self.update_attribute(:value, value) 
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
                
        def trigger_permission_callback(action)
          action.is_a?(Proc) ? action.call(self) : self.send(action.to_s)
        end
        
        def trigger_permission_callback?(options = {})
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
        
        def permission(options = {})
          options[:about]  ||= ""
          options[:on]     ||= ""
          options[:do]     ||= ""
          options[:from]   ||= nil
          options[:to]     ||= nil
          options[:if]     ||= nil
          options[:unless] ||= nil
          
          if options[:about].present? && options[:on].present? && options[:do].present?
            send("before_#{options[:on]}", Proc.new { |p| p.trigger_permission_callback(options[:do]) }, :if => Proc.new { |p| p.trigger_permission_callback?(options) })
          end
        end
      end
    end
    
  end
end