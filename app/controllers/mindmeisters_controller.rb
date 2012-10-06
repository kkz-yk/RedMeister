# -*- coding: utf-8 -*-
require 'open-uri'
require 'active_support/core_ext'
require 'digest/md5'

class MindmeistersController < ApplicationController

  def logIn
    createToken
  end


  def callback
    frob = params[:frob]

    # If your auth token is 'nil' or 'invalid auth token(false)', get new auth token.
    if (session["auth_token"] == nil) || (checkToken == "false")
      session["auth_token"] = getToken(frob)
    end

    redirect_to "/setting"
  end


  def getFrob
    url = "http://www.mindmeister.com/services/rest?api_key={$api_key}&method=mm.auth.getFrob&response_format=xml"

    response = getXML(url)
    return response
  end


  def createToken
    url = "http://www.mindmeister.com/services/auth/?api_key=#{$api_key}&perms=delete"

    api_sig = md5Converter(url)
    url = url + "&api_sig=" + api_sig

    redirect_to url
  end


  def checkToken
    url = "http://www.mindmeister.com/services/rest?api_key=#{$api_key}&auth_token=#{session["auth_token"]}&method=mm.auth.checkToken&response_format=xml"

    resonse = getXML(url)
    return response["rsp"]["stat"]
  end


  def getToken(frob)
    url = "http://www.mindmeister.com/services/rest?api_key=#{$api_key}&frob=#{frob}&method=mm.auth.getToken&response_format=xml"

    response = getXML(url)
    return response["rsp"]["auth"]["token"]
  end


  def getChannel
    # Get Maps of User
    session["user_name"] = params[:text_field][:user_name]
    url = "http://www.mindmeister.com/services/rest?api_key=#{$api_key}&auth_token=#{session["auth_token"]}&method=mm.maps.getChannel&response_format=xml&user=#{session["user_name"]}"

    maps_xml = getXML(url)

    array = Array.new
    begin
      maps_xml["rsp"]["maps"]["map"].each{ |p|
        data = Hash.new
        data["title"] = p["title"].to_s
        data["id"] = p["id"].to_i
        array.push(data)
      }
    rescue
      maps = maps_xml["rsp"]["maps"]["map"]
      data = Hash.new
      data["title"] = maps["title"].to_s
      data["id"] = maps["id"].to_i
      array.push(data)
    end
    @channel = array
  end


  def searchParentOfIdea(array, array_tmp)
    idea = MindmeisterTable.find_by_map_id_and_idea_id(session["map_id"], array_tmp['parent'])
    if idea == nil
      array.each{ |p|
        if p['id'] == array_tmp['parent']
          if p['parent'] == session["map_id"]
            postToRedmine("nil",array_tmp)
          else
            searchParentOfIdea(array, p)
            idea = MindmeisterTable.find_by_map_id_and_idea_id(session["map_id"],array_tmp['parent'])
            record = RedmineTable.find_by_id(idea.id)
            postToRedmine(record.issue_id, array_tmp)
          end
          break
        end
      }
    else
      record = RedmineTable.find_by_id(idea.id)
      postToRedmine(record.issue_id, array_tmp)
    end
  end


  def updateAllRedmine(array_tmp)
    idea = MindmeisterTable.find_by_map_id_and_idea_id(session["map_id"], array_tmp['id'])
    record = RedmineTable.find_by_id(idea.id)

    update = MindmeisterTable.find_by_map_id_and_idea_id(session["map_id"], array_tmp["parent"])
    update_record = RedmineTable.find_by_id(update.id)

    updateRedmine(record.issue_id, update_record.issue_id, array_tmp["title"])

    idea.update_attributes(:parent_id => array_tmp["parent"], :title => array_tmp["title"])
    record.update_attributes(:parent_id => update_record.issue_id, :subject => array_tmp["title"])
  end


  def updateRedmine(issue_id, parent_id, subject)
    # Mindmeister -> Redmine
    issue = Issue.find(issue_id)
    issue.subject = subject
    issue.parent_issue_id = parent_id
    issue.save
  end


  def postToRedmine(parent_id, array_tmp)
    # Mindmeister -> Redmine
    issue = Issue.new(
                      :parent_issue_id => parent_id,
                      :subject => array_tmp["title"],
                      :project_id => session["project_id"]
                      )
    if issue.save
      createRecord(issue.id, parent_id, array_tmp["id"], array_tmp["parent"], array_tmp["title"])
    else
      puts issue.errors.full_messages
    end
  end

end
