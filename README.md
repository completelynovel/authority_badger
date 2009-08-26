# AuthorityBadger

AuthorityBadger is a simple plugin to manage permissions.

## Requirements

### Plugin
has_many_polymorphs

## Install

### Create the Permissions table

    create_table :permissions do |t|
      t.string  :name
      t.integer :value
      t.integer :owner_id
      t.string  :owner_type
      t.timestamps
    end

## Example

### Permission model

    class Permission < ActiveRecord::Base
  
      acts_as_permission

      permission :about => :book_publishing, 
                 :on    => :update,
                 :do    => Proc.new { |p| p.owner.deliver_email_notification(p.owner) }
             
    end

### Set up permissions

Example in a yml file :


### Add permissions to a model (the owner)

    class Person < ActiveRecord::Base

      has_permissions PERMISSION_CONFIG
  
    end

### How to use it?

** Create permissions **

    person.create_free_writer_permissions
    person.create_free_publisher_permissions

** Update permissions **

** Methods **

    method_name = 4
    person.increment_method_name => 5
    person.increment_method_name(2) => 7
    person.method_name => return 7
    person.method_name? => 7 : return false
    person.decrement_method_name(6) => 1
    person.method_name? => 1 : return true
    person.method_name.between?(0, 4) => return true
    person.method_name(-1) => -1
    person.increment_method_name(10) => -1 (because -1 mean unlimited so it doesn't change)