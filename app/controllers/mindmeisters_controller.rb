# -*- coding: utf-8 -*-
require 'open-uri'
require 'active_support/core_ext'
require 'digest/md5'

class MindmeistersController < ApplicationController

  $api_key = RedMeister::Application.config.api_key
  $api_secret = RedMeister::Application.config.api_secret


  def mindmeister_top
  end

  def mindmeister_map
  end


  def logIn
    createToken
  end


  def callback
    frob = params[:frob]

    # If your auth token is 'nil' or 'invalid auth token(false)', get new auth token.
    if (session["auth_token"] == nil) || (checkToken == "false")
      session["auth_token"] = getToken(frob)
    end

    redirect_to root_path
  end


  def getFrob
    url = "http://www.mindmeister.com/services/rest?api_key={$api_key}&method=mm.auth.getFrob&response_format=xml"

    api_sig = md5Converter(url)
    _url = url + "&api_sig=" + api_sig

    xml = getXML(_url)
    return xml
  end


  def createToken
    url = "http://www.mindmeister.com/services/auth/?api_key=#{$api_key}&perms=delete"

    api_sig = md5Converter(url)
    _url = url + "&api_sig=" + api_sig

    redirect_to _url
  end


  def getToken(frob)
    url = "http://www.mindmeister.com/services/rest?api_key=#{$api_key}&frob=#{frob}&method=mm.auth.getToken&response_format=xml"

    api_sig = md5Converter(url)
    _url = url + "&api_sig=" + api_sig

    xml = getXML(_url)
    return xml["rsp"]["auth"]["token"]
  end


  def checkToken
    url = "http://www.mindmeister.com/services/rest?api_key=#{$api_key}&auth_token=#{session["auth_token"]}&method=mm.auth.checkToken&response_format=xml"

    api_sig = md5Converter(url)
    _url = url + "&api_sig=" + api_sig

    xml = getXML(_url)
    return xml["rsp"]["stat"]
  end


  def getChannel
    # Get Maps of User
    session["user_name"] = params[:text_field][:user_name]
    url = "http://www.mindmeister.com/services/rest?api_key=#{$api_key}&auth_token=#{session["auth_token"]}&method=mm.maps.getChannel&response_format=xml&user=#{session["user_name"]}"

    api_sig = md5Converter(url)
    _url = url + "&api_sig=" + api_sig

    maps_xml = getXML(_url)

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


  def getMap
    # Get Nodes of Map
    session["map_title"] = params[:title]
    session["map_id"] = params[:id]
    url = "http://www.mindmeister.com/services/rest?api_key=#{$api_key}&auth_token=#{session["auth_token"]}&map_id=#{session["map_id"]}&method=mm.maps.getMap&response_format=xml"

    api_sig = md5Converter(url)
    _url = url + "&api_sig=" + api_sig

    map_xml = getXML(_url)

    array = Array.new
    begin
      map_xml["rsp"]["ideas"]["idea"].each{ |p|
        data = Hash.new
        data["id"] = p["id"].to_i
        data["title"] = p["title"].to_s
        data["parent_id"] = p["parent"].to_i
        data["parent_name"] = "root"
        data["parent_issue_id"] = "nil"
        data["flag"] = "post"
        data["issue_id"] = "nil"
        array.push(data)
      }
    rescue
      map = map_xml["rsp"]["ideas"]["idea"]
      data = Hash.new
      data["id"] = map["id"].to_i
      data["title"] = map["title"].to_s
      data["parent_id"] = map["parent"].to_i
      data["parent_name"] = "root"
      data["parent_issue_id"] = "nil"
      data["flag"] = "post"
      data["issue_id"] = "nil"
      array.push(data)
    end
    @map = array
    session["map"] = @map
  end


  def postToRedmine
    array = session["map"]
    root_id = 0

    array.each{ |p1|
      puts p1["id"]
      if p1["parent_id"].to_i == 0
        root_id = p1["id"]
        p1["flag"] = "nil"
      else
        if p1["parent_id"] != root_id
          array.each{ |p2|
            if p1["parent_id"] == p2["id"]
              p1["parent_name"] = p2["title"]
              break
            end
          }
        end
      end
    }


    # Compare subject of Redmine with title of Mindmeister
    $r_user = session["r_user"]
    $r_password = session["r_password"]
    issues = Issue.find(:all)

    array.each{ |p1|
      issues.each{ |p2|
        if p1["parent_name"] == p2.subject
          p1["parent_issue_id"] = p2.id
        end
        if p1["title"] == p2.subject
          p1["flag"] = "nil"
        end
      }
    }

    # Createing an issue
    array.each{ |p1|
      if p1['flag'] == "post"
        if p1['parent_name'] != "root" && p1['parent_issue_id'] == "nil"
          array.each{ |p2|
            if p1['parent_name'] == p2['title']
              p1['parent_issue_id'] = p2['issue_id']
              break
            end
          }
        end

        issue = Issue.new(
                          :parent_issue_id => p1['parent_issue_id'],
                          :subject => p1['title'],
                          #:project_id => 56
                          :project_id => 57
                          )
        if issue.save
          puts issue.id
          p1['issue_id'] = issue.id
        else
          puts "failed create ticket from Mindmeister"
        end
      end
    }

    redirect_to root_path
  end

end


# REDMINE REST API
class Issue < ActiveResource::Base
#  self.site = 'http://redmine.ie.u-ryukyu.ac.jp/projects/pro3-2012-redmine'
  self.site = 'http://redmine.ie.u-ryukyu.ac.jp/projects/pro3-test'
  self.format = :xml
  self.user = $r_user
  self.password = $r_password
end
