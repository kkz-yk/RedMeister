# -*- coding: utf-8 -*-
require 'open-uri'
require 'active_support/core_ext'

class RedminesController < ApplicationController

  def redmine_top
  end

  def redmine_project
  end

  def getProjects
    # Acquire Redmine Projects
    session[:r_url] = params[:text_field][:r_url]
    url_union = session[:r_url] + "/projects.xml?"
    projects_xml = getXML(url_union)

    array = Array.new
    projects_xml["projects"].each{ |p|
      data = Array.new
      data = [ p["name"].to_s, p["identifier"].to_s ]
      puts data[1]
      array.push(data)
    }
    session[:projects] = array

    redirect_to "/redmine_top"
  end


  def getIssues
    @para = params[:para]
    url_union = session[:r_url] + "/projects/" + @para +  "/issues.xml"
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
    session[:issues] = array

    redirect_to "/redmine_project"
  end


  def getXML(url)
    begin
      json = Hash.from_xml(open(url))
      return json
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
    redirect_to "/redmine_top"
  end

end
