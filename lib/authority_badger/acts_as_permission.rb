module AuthorityBadger
  module ActsAsPermission
    
    def self.included(base)
      base.extend ActMethods
    end 

    module ActMethods
      def acts_as_permission
        belongs_to :owner, :polymorphic => true
        
        has_many :uses, :class_name => 'PermissionUse'
        
        named_scope :about, lambda { |about| { :conditions => ["permissions.name = ?", about.to_s] } }
        
        attr_accessible :name, :value, :owner

        validates_presence_of :name, :value, :owner
        
        send("before_update", Proc.new { |p| p.create_permission_use })
        
        include InstanceMethods
        extend ClassMethods
      end
      
      module InstanceMethods
        attr_accessor :note_on_use
        attr_accessor :use_on_use
        
        def create_permission_use
          fields = {
            :note => self.note_on_use, 
            :use => self.use_on_use,
            :value_before => self.value_was,
            :value_after => self.value,
            :used_at => Time.now
          }
          
          self.uses.create(fields)
        end
        
        def value?
          self.value == -1
        end
        
        def enough?
          self.value? || self.value > 0
        end
        
        def has_owner_used?(use)
          self.uses.exists?(:use_id => use.id, :use_type => use.class.to_s)
        end
        
        def update_value(value, options = {})
          self.note_on_use = options[:note] || nil
          self.use_on_use  = options[:use] || nil
          self.value       = value
          self.save
        end
        
        def increment(options = {})
          options[:by]   ||= 1
          self.note_on_use = options[:note] || nil
          self.use_on_use  = options[:use] || nil
          
          unless self.value == -1
            value = self.value.nil? ? options[:by] : self.value += options[:by]
            self.value = value
            self.save
          end
        end
        
        def decrement(options = {})
          options[:by]   ||= 1
          self.note_on_use = options[:note] || nil
          self.use_on_use  = options[:use] || nil
          
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