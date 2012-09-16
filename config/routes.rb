RedMeister::Application.routes.draw do
  get "welcomes/index"
  root :to => "welcomes#index"

  match "/redmine_top" => "redmines#redmine_top", :as => :redmine_top
  match "/getProjects" => "redmines#getProjects", :as => :getProjects
  match "/getIssues" => "redmines#getIssues", :as => :getIssues
  match "/redmine_project" => "redmines#redmine_project", :as => :redmine_project
  match "/destroy" => "redmines#destroy", :as => :destroy


  match "/mindmeister_top" => "mindmeisters#mindmeister_top", :as => :mindmeister_top
  match "/logIn" => "mindmeisters#logIn", :as => :logIn
  match "/callback" => "mindmeisters#callback", :as => :callback
  match "/getToken" => "mindmeisters#getToken", :as => :getToken
  match "/getMaps" => "mindmeisters#getMaps", :as => :getMaps
  match "/getNodes" => "mindmeisters#getNodes", :as => :getNodes
  match "/mindmeister_map" => "mindmeisters#mindmeister_map", :as => :mindmeister_map
  match "/destroyAnother" => "mindmeisters#destroyAnother", :as => :destroyAnother

end
