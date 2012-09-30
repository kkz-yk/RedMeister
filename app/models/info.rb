class Info < ActiveRecord::Base
  attr_accessible :password_d, :user_name_d

  belongs_to :id_root
end
