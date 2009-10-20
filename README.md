# AuthorityBadger

AuthorityBadger is a lightweight plugin to manage permissions.

It has not been build in the line of the authorization plugins you can usually find.

The aim is to manage simple permission using a token balance for specifics actions.

## Requirements

### Plugin

has_many_polymorphs

## Install

### Create the required tables

    List here...

## Example

Let's say we are an online publishing company.

We want to allow somebody to publish only 5 books in our website.

We also want to notify people about their current credits.

### Permission model

    class TokenBalance < ActiveRecord::Base
  
      acts_as_token_balance

      permission :about => :book_publishing, 
                 :on    => :create,
                 :do    => Proc.new { |p| p.owner.deliver_init_credits_status(p.owner) }

      permission :about => :book_publishing, 
                 :on    => :update,
                 :from  => 1,
                 :to    => 0,
                 :do    => Proc.new { |p| p.owner.deliver_all_credits_used(p.owner) }
                              
    end

You can set up as much token balances events as you want.


The following options are available :

**about** name of the field

**on** active record callback

**from** if the value was the giving value before changed

**to** if the value is the giving value

**if** add as if condition... (Proc / Method)

**unless** add as unless condition... (Proc / Method)

**do** action triggered (Proc / Method)


The acts_as_token_balance class method include few helpful instance methods.

Have a look at the file acts_as_token_balance.rb in the plugin for more information.

### Set up permissions

We need a hash. We can use YML file loaded in the CONFIG var :

    free_account:
      book_publishing: 2
      
    advanced_account:
      book_publishing: 10

    free_account_to_advanced_account:
      book_publishing:
        action: sum
        value: 10
      
### Add permissions to a model (the owner)

    class Person < ActiveRecord::Base

      has_tokens
  
    end

Now you can manage your owner tokens. By default nothing is created, it's up to you to create the required tokens (next point).

### Now Manage permissions

** Will create the owner's token balances **

    Person.find(1).create_tokens(CONFIG["free_account"])
    Person.find(2).create_tokens(CONFIG["advanced_account"])
    
** Will update the owner's token balances (following the content of the YML file) **

    Person.find(1).update_tokens(CONFIG["free_account_to_advanced_account"])

** You can jump between tokens using the following actions**

*create* to add a new token :

    free_account_to_advanced_account:
      allow_people_to_comment:
        action: create
        value: 1 # result : 1

*update* to replace the current value :

    free_account_to_advanced_account:
      book_publishing:
        action: update
        value: 10 # result : 10

*sum* to increment the current value :

    free_account_to_advanced_account:
      book_publishing:
        action: sum
        value: 10 # result : 11

*destroy* if you need to destroy useless permission :

    free_account_to_advanced_account:
      book_publishing:
        action: destroy

In any way, you are free to upgrade, downgrade, add, destroy token balances following your need.
        
### Use Methods

Finally, we can use the permissions...

    Person.first.token(:book_publishing) #=> 4
    
    # Increment / Decrement (or Use)
    Person.first.increment_token(:book_publishing)
    Person.first.token(:book_publishing) #=> 5
    Person.first.increment_token(:book_publishing, 2)
    Person.first.token(:book_publishing) #=> 7
    Person.first.decrement_token(:book_publishing, 3)
    Person.first.token(:book_publishing) #=> 4
    Person.first.use_token(:book_publishing, 1)
    Person.first.token(:book_publishing) #=> 3
    
    # Return true if more than 0 or -1 (unlimited)
    Person.first.enough_token?(:book_publishing) #=> true
    
    # A value can't be less the 0
    Person.first.decrement_token(:book_publishing, 6) 
    Person.first.token(:book_publishing) #=> 1
    
    # Set -1, mean unlimited
    Person.first.unlimited_token(:book_publishing)
    Person.first.token(:book_publishing) #=> -1
    
    # Reset
    Person.first.reset_token(:book_publishing)
    Person.first.token(:book_publishing) #=> nil
    
    # Clear
    Person.first.clear_token(:book_publishing)
    Person.first.token(:book_publishing) #=> 0
    
    # After a token is used it creates a transaction, so you can check if a token has already been used :
    # @book is the reference you used the token for
    Person.first.used_token?(:book_publishing, @book)

    # Add doc for .permission => after owner user credits
    
- [CompletelyNovel Website](http://www.completelynovel.com/ "CompletelyNovel")
- [Find us on Github](https://github.com/completelynovel "Github")