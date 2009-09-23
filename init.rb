require 'authority_badger'

ActiveRecord::Base.send(:include, AuthorityBadger::ActsAsPermission)
ActiveRecord::Base.send(:include, AuthorityBadger::ActsAsPermissionUse)
ActiveRecord::Base.send(:include, AuthorityBadger::HasPermissions)