class IdRoot < ActiveRecord::Base
  set_primary_key :user_name_d
  attr_accessible :user_name_d, :redmine_url, :redmine_user_name, :redmine_password

  has_one :info
end
