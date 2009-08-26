module AuthorityBadger
  module HasPermissions

    def self.included(base)
      base.extend(ActMethods)
    end 

    module ActMethods
      def has_permissions(*group_permissions)
        group_permissions = group_permissions[0] if group_permissions.is_a?(Array)
        
        has_many :permissions, :as => :owner
        
        cattr_accessor :group_permissions
        
        self.group_permissions = group_permissions
        
        include InstanceMethods
      end
      
      module InstanceMethods
        def create_permissions(name)
          self.class.group_permissions[name.to_s].each do |name, value|
            self.permissions.create(:name => name.to_s, :value => value.to_i) unless self.permissions.exists?(:name => name.to_s)
          end
        end
        
        def update_permissions(permissions)
          permissions.each do |name, permission|
            case permission["action"].to_s
            when "create"
              self.permissions.create(:name => name.to_s, :value => permission["value"].to_i) unless self.permissions.exists?(:name => name.to_s)
            when "update"
              self.update_permission(name.to_s, permission["value"].to_i)
            when "destroy"
              self.permission(name.to_s).destroy
            when "sum"
              self.increment_permission(name.to_s, permission["value"].to_i)
            end
          end
        end
        
        def destroy_permissions(name)
          self.class.group_permissions[name.to_s].each do |name, value|
            self.permission(name.to_s).destroy
          end
        end
        
        def permission(name)
          self.permissions.first(:conditions => { :name => name.to_s })
        end
        
        def update_permission(name, value)
          self.permission(name).update_attribute(:value, value.to_i)
        end
        
        def permission?(name)
          self.permission(name).value?
        end
        
        def enough_permission?(name)
          self.permission(name).enough?
        end
        
        def increment_permission(name, by = 1)
          self.permission(name).increment(by)
        end
        
        def decrement_permission(name, by = 1)
          self.permission(name).decrement(by)
        end

        def unlimited_permission(name)
          self.permission(name).unlimited
        end
        
        def reset_permission(name)
          self.permission(name).reset
        end
        
        def clear_permission(name)
          self.permission(name).clear
        end
      end
    end

  end
end