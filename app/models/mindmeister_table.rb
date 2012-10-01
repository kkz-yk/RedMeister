class MindmeisterTable < ActiveRecord::Base
  # attr_accessible :title, :body
  attr_accessible :map_id, :idea_id, :parent_id, :title
end
