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
  match "/postToMindmeister" => "redmines#p5ostToMindmeister", :as => :postToMindmeister

  match "/destroy" => "redmines#destroy", :as => :destroy

  match "/logIn" => "application#logIn", :as => :logIn
  match "/callback" => "application#callback", :as => :callback
  match "/getToken" => "application#getToken", :as => :getToken
  match "/getChannel" => "application#getChannel", :as => :getChannel
  match "/getMap" => "application#getMap", :as => :getMap
  match "/postToRedmine" => "application#postToRedmine", :as => :postToRedmine
  match "/mindmeister_map" => "application#mindmeister_map", :as => :mindmeister_map

end
