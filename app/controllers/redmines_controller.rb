# -*- coding: utf-8 -*-
require 'open-uri'
require 'active_support/core_ext'
require 'uri'

require 'mindmeisters_controller.rb'

class RedminesController < ApplicationController

  $api_key = RedMeister::Application.config.api_key
  $api_secret = RedMeister::Application.config.api_secret

  def getProjects
    session["r_user_name"] = params[:text_field][:r_user_name]
    session["r_password"] = params[:text_field][:r_password]

    # Acquire Redmine Projects
    session["r_url"] = params[:text_field][:r_url]
    url_union = session["r_url"] + "/projects.xml?"
    projects_xml = getXML(url_union)

    array = Array.new
    projects_xml["projects"].each{ |p|
      data = Array.new
      data = [ p["name"].to_s, p["identifier"].to_s ]
      puts data[1]
      array.push(data)
    }
    @projects = array
  end


  def getIssues
    @project_name = params[:project_name]
    project_id = params[:project_id]
    url_union = session["r_url"] + "/projects/" + project_id +  "/issues.xml"
    issues_xml = getXML(url_union)

    array = Array.new
    issues_xml["issues"].each{ |p|
      data = Hash.new
      data["id"] = p["id"].to_i
      data["subject"] = p["subject"].to_s
      if p["parent"]
        data["parent"] = p["parent"]["id"].to_i
      else
        data["parent"] = nil
      end

      array.push(data)
    }
    @issues = array
  end

  $map_id = 205113896

  def postToMindmeister
    array = session["issues"]
    array.each{ |array_tmp|
      puts array_tmp
      url = "http://www.mindmeister.com/services/rest?api_key=#{$api_key}&auth_token=#{session["auth_token"]}&map_id=#{$map_id}&method=mm.ideas.insert&parent_id=#{$map_id}&response_format=xml&title=#{array_tmp["subject"]}&x_pos=0&y_pos=0"
      str = url.clone
      api_sig = md5Converter(str)
      _url = url + "&api_sig="+api_sig

      uri = URI.escape(_url)
      getXML(uri)
    }

    redirect_to "/redmine_project"
  end


  def getXML(url)
    begin
      xml = Hash.from_xml(open(url))
      return xml
    rescue SocketError
      puts "SocketError"
      exit
    rescue OpenURI::HTTPError
      puts "HTTPError: #{url}"
      exit
    end
  end


  def destroy
    reset_session
    redirect_to root_path
  end

  def md5Converter(str)
    str.slice!("http://www.mindmeister.com/services/rest?")
    str.delete!("=")
    str.delete!("&")

    md5 = Digest::MD5.hexdigest($api_secret  + str)
    return md5
  end

end
