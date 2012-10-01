class RedmineTable < ActiveRecord::Base
  # attr_accessible :title, :body
   attr_accessible :project_id, :issue_id, :parent_id, :subject 
end
