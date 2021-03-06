# -*- coding: utf-8 -*-
require 'open-uri'
require 'active_support/core_ext'
require 'digest/md5'

class ApplicationController < ActionController::Base
  # ApplicationController have common method.

  protect_from_forgery

  # Mindmeister's APIkey and APIsecret
  $api_key = RedMeister::Application.config.api_key
  $api_secret = RedMeister::Application.config.api_secret


  # Jointly method.
  def getXML(url)
    puts url

    # Add api_sig to url if url is "mindmeister.com".
    if url.index("http://www.mindmeister.com")
      api_sig = md5Converter(url)
      url = url + "&api_sig=" + api_sig
      url = URI.escape(url)
    end

    begin
      response = Hash.from_xml(open(url))
      return response
    rescue SocketError
      puts "SocketError"
      exit
    rescue OpenURI::HTTPError
      puts "HTTPError: #{url}"
      exit
    end
  end


  def md5Converter(url)
    str = url.clone

    str.slice!("http://www.mindmeister.com/services/auth/?")
    str.slice!("http://www.mindmeister.com/services/rest?")
    str.delete!("=")
    str.delete!("&")

    md5 = Digest::MD5.hexdigest($api_secret  + str)
    return md5
  end


  def destroy
    reset_session
    redirect_to "/gate"
  end


  def createRecord(issue_id, issue_parent, idea_id, idea_parent, title)
    RedmineTable.create(:project_id => session["project_id"], :issue_id => issue_id, :parent_id => issue_parent, :subject => title)
    MindmeisterTable.create(:map_id => session["map_id"], :idea_id => idea_id, :parent_id => idea_parent, :title => title)
  end





# Common Method (Operate Mindmeister) ---------------
  def getMap
    url = "http://www.mindmeister.com/services/rest?api_key=#{$api_key}&auth_token=#{session["auth_token"]}&map_id=#{session["map_id"]}&method=mm.maps.getMap&response_format=xml"

    response = getXML(url)

    if response["rsp"]["stat"] == "fail"
      RedmeisterRelationship.delete_all(:map_id => session["map_id"])
      RedmineTable.delete_all(:project_id => session["project_id"])
      MindmeisterTable.delete_all(:map_id => session["map_id"])
      addMap
      return nil
    end

    return response["rsp"]["ideas"]["idea"]
  end


  def addMap
    url = "http://www.mindmeister.com/services/rest?api_key=#{$api_key}&auth_token=#{session["auth_token"]}&method=mm.maps.add&response_format=xml"

    response = getXML(url)
    session["map_id"] = response["rsp"]["map"]["id"]
    publishMap(session["map_id"])
    changeIdeas(session["map_id"], session["project_name"])
    RedmeisterRelationship.create(:project_id => session["project_id"], :map_id => session['map_id'])
  end


  def publishMap(map_id)
    url = "http://www.mindmeister.com/services/rest?api_key=#{$api_key}&auth_token=#{session["auth_token"]}&map_id=#{map_id.to_s}&method=mm.maps.publish&response_format=xml"

    getXML(url)
  end


  def insertIdeas(parent_id, array_tmp)
    url = "http://www.mindmeister.com/services/rest?api_key=#{$api_key}&auth_token=#{session["auth_token"]}&map_id=#{session["map_id"]}&method=mm.ideas.insert&parent_id=#{parent_id}&response_format=xml&title=#{array_tmp["subject"]}&x_pos=200&y_pos=0"

    response = getXML(url)

    session["response"] = response["rsp"]["id"].to_i

    createRecord(array_tmp["id"], array_tmp["parent"], session["response"], parent_id, array_tmp["subject"])

  end


  def changeIdeas(idea_id, title)
    url = "http://www.mindmeister.com/services/rest?api_key=#{$api_key}&auth_token=#{session["auth_token"]}&idea_id=#{idea_id}&map_id=#{session["map_id"]}&method=mm.ideas.change&response_format=xml&title=#{title}"

    getXML(url)
  end


  def moveIdeas(idea_id, parent_id)
    url = "http://www.mindmeister.com/services/rest?api_key=#{$api_key}&auth_token=#{session["auth_token"]}&idea_id=#{idea_id}&map_id=#{session["map_id"]}&method=mm.ideas.move&parent_id=#{parent_id}&rank=0&response_format=xml"

    getXML(url)
  end


  def diffToMindmeister()
    # Mindmeister -> Redmine (Difference)
    Issue.site = session["redmine_url"] + "/projects/pro3-2012-redmine"
    Issue.user = session["redmine_user_name"]
    Issue.password = session["redmine_password"]

    response = getMap

    response.each{ |array_tmp|
      if array_tmp['parent'] != nil
        idea = MindmeisterTable.find_by_map_id_and_idea_id(session["map_id"], array_tmp['id'])
        if idea == nil
          if array_tmp['parent'] != session["map_id"]
            searchParentOfIdea(response, array_tmp)
          else
            postToRedmine(parent_id, array_tmp)
          end
        else
          if idea.title != array_tmp['title'] || idea.parent_id.to_i != array_tmp['parent'].to_i
            updateAllRedmine(array_tmp)
          end
        end
      end
    }
  end

end


# REDMINE REST API
class Issue < ActiveResource::Base
  self.site = nil
  self.user = nil
  self.password = nil
  self.format = :xml
end
