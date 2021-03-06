# -*- coding: utf-8 -*-
require 'open-uri'
require 'active_support/core_ext'
require 'uri'

class RedminesController < ApplicationController

  def inputInfo
    if ((params[:text_field][:redmine_user_name] != "") && (params[:text_field][:redmine_password] != "") &&  (params[:text_field][:redmine_url] != ""))
      session["redmine_user_name"] = params[:text_field][:redmine_user_name]
      session["redmine_password"] = params[:text_field][:redmine_password]
      session["redmine_url"] = params[:text_field][:redmine_url]

      IdRoot.create(:user_name_d => session["redmeister_user"].user_name_d, :redmine_url => session["redmine_url"], :redmine_user_name => session["redmine_user"], :redmine_password => session["redmine_password"])

      redirect_to root_path
    else
      redirect_to "/setting"
    end
  end


  def getProjects
    if (session["redmine_user_name"] == nil) || (session["redmine_password"] == nil) ||  (session["redmine_url"] == nil)
      redirect_to root_path
    else

      url_union = session["redmine_url"] + "/projects.xml?"
      projects_xml = getXML(url_union)

      array = Array.new
      projects_xml["projects"].each{ |p|
        data = Array.new
        data = [ p["name"].to_s, p["identifier"].to_s ]
        array.push(data)
      }
      @projects = array
      session["projects"] = @projects
    end
  end


  def getIssues
    session["project_name"] = params[:project_name]
    project_id = params[:project_id]

    url_union = session["redmine_url"] + "/projects/" + project_id +  "/issues.xml?sort=id&status_id=*&limit=100"
    issues_xml = getXML(url_union)

    url = session["redmine_url"] + "/projects/" + project_id +  ".xml"
    project_xml = getXML(url)
    session["project_id"] = project_xml["project"]["id"]

    array = Array.new
    issues_xml["issues"].each{ |p|
      data = Hash.new
      data["id"] = p["id"].to_i
      data["subject"] = p["subject"].to_s
      if p["parent"]
        data["parent"] = p["parent"]["id"].to_i
      else
        data["parent"] = 0
      end

      array.push(data)
    }

    @issues = array
    session["issues"] = @issues
    postToMindmeister(array)
    diffToMindmeister
  end


  def postToMindmeister(array)
    map = RedmeisterRelationship.find_by_project_id(session["project_id"])

    if map == nil
      addMap
    else
      session["map_id"] = map.map_id
      getMap
    end

    array.each{ |array_tmp|
      issue = RedmineTable.find_by_project_id_and_issue_id(session["project_id"], array_tmp['id'])
      if issue == nil
        if array_tmp['parent'] != 0
          search_parent(array, array_tmp)
        else
          insertIdeas(session["map_id"], array_tmp)
        end
      else
        if issue.subject != array_tmp['subject'] || issue.parent_id != array_tmp['parent']
          updateMindmeister(array_tmp)
        end
      end
    }
  end


  def search_parent(array, array_tmp)
    issue = RedmineTable.find_by_project_id_and_issue_id(session["project_id"], array_tmp['parent'])
    if issue == nil
      array.each{ |p|
        if p['id'] == array_tmp['parent']
          if p['parent'] == 0
            insertIdeas(session["map_id"], array_tmp)
          else
            search_parent(array, p)
            issue = RedmineTable.find_by_project_id_and_issue_id(session["project_id"],array_tmp['parent'])
            record = MindmeisterTable.find_by_id(issue.id)
            insertIdeas(record.idea_id, array_tmp)
          end
          break
        end
      }
    else
      record = MindmeisterTable.find_by_id(issue.id)
      insertIdeas(record.idea_id, array_tmp)
    end
  end


  def updateMindmeister(array_tmp)
    issue = RedmineTable.find_by_project_id_and_issue_id(session["project_id"], array_tmp['id'])
    record = MindmeisterTable.find_by_id(issue.id)
    update = RedmineTable.find_by_project_id_and_issue_id(session["project_id"], array_tmp["parent"])
    update_record = MindmeisterTable.find_by_id(update.id)

    if issue.subject != array_tmp['subject']
      changeIdeas(record.idea_id, array_tmp["subject"])
    end

    if issue.parent_id != array_tmp['parent']
      moveIdeas(record.idea_id, update_record.idea_id)
    end

    issue.update_attributes(:parent_id => array_tmp["parent"], :subject => array_tmp["subject"])
    record.update_attributes(:parent_id => update_record.idea_id, :title => array_tmp["subject"])
  end

end
