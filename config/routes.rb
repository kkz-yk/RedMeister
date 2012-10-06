RedMeister::Application.routes.draw do
  get "welcomes/index"
  root :to => "welcomes#index"

  match "/gate" => "welcomes#gate", :as => :gate
  match "/signUpPage" => "welcomes#signUpPage", :as => :signUpPage
  match "/signUp" => "welcomes#signUp", :as => :signUp
  match "/setting" => "welcomes#setting", :as => :setting
  match "/gate" => "welcomes#gate", :as => :gate
  match "/redmeisterLogin" => "welcomes#redmeisterLogin", :as => :redmeisterLogin
  match "/inputInfo" => "redmines#inputInfo", :as => :inputInfo
  match "/getProjects" => "redmines#getProjects", :as => :getProjects
  match "/getIssues" => "redmines#getIssues", :as => :getIssues
#  match "/postToMindmeister" => "redmines#postToMindmeister", :as => :postToMindmeister

  match "/destroy" => "application#destroy", :as => :destroy

  match "/logIn" => "mindmeisters#logIn", :as => :logIn
  match "/callback" => "mindmeisters#callback", :as => :callback
#  match "/getToken" => "mindmeisters#getToken", :as => :getToken
#  match "/getChannel" => "mindmeisters#getChannel", :as => :getChannel
#  match "/getMap" => "mindmeisters#getMap", :as => :getMap
#  match "/postToRedmine" => "application#postToRedmine", :as => :postToRedmine

end
