require 'authority_badger'

ActiveRecord::Base.send(:include, AuthorityBadger::ActsAsToken)
ActiveRecord::Base.send(:include, AuthorityBadger::ActsAsTokenBalance)
ActiveRecord::Base.send(:include, AuthorityBadger::ActsAsTokenTransaction)
ActiveRecord::Base.send(:include, AuthorityBadger::ActsAsTokenPrice)
ActiveRecord::Base.send(:include, AuthorityBadger::HasTokens)