module AuthorityBadger
  module ActsAsPermissionUse
    
    def self.included(base)
      base.extend ActMethods
    end 

    module ActMethods
      def acts_as_permission_use
        belongs_to :permission
        
        belongs_to :use, :polymorphic => true
        
        attr_accessible :used_at, :value_before, :value_after, :note, :use

        validates_presence_of :used_at, :value_before, :value_after
        
        named_scope :with_note, :conditions => ["permission_uses.note IS NOT NULL AND permission_uses.note != ''"]
      end
    end
    
  end
end