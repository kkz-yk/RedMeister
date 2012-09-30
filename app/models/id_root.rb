class IdRoot < ActiveRecord::Base
  attr_accessible :user_name_d, :redmine_url, :redmine_user_name, :redmine_password

  has_one :info
end
