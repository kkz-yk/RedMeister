# -*- coding: utf-8 -*-
class ApplicationController < ActionController::Base
  protect_from_forgery

  $api_key = RedMeister::Application.config.api_key
  $api_secret = RedMeister::Application.config.api_secret


  # Jointly method ---------
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
    redirect_to "/gate"
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


  def addMap
    url = "http://www.mindmeister.com/services/rest?api_key=#{$api_key}&auth_token=#{session["auth_token"]}&method=mm.maps.add&response_format=xml"

    api_sig = md5Converter(url)
    _url = url + "&api_sig=" + api_sig

    xml = getXML(_url)
    session["map_id"] = xml["rsp"]["map"]["id"]
    publishMap(session["map_id"])
    changeIdeas(session["map_id"], session["project_name"])
     RedmeisterRelationship.create(:project_id => session["project_id"], :map_id => session['map_id'])

  end


  def publishMap(map_id)
    url = "http://www.mindmeister.com/services/rest?api_key=#{$api_key}&auth_token=#{session["auth_token"]}&map_id=#{map_id.to_s}&method=mm.maps.publish&response_format=xml"

    api_sig = md5Converter(url)
    _url = url + "&api_sig=" + api_sig

    xml = getXML(_url)
  end


  def insertIdeas(parent_id, array_tmp)
    url = "http://www.mindmeister.com/services/rest?api_key=#{$api_key}&auth_token=#{session["auth_token"]}&map_id=#{session["map_id"]}&method=mm.ideas.insert&parent_id=#{parent_id}&response_format=xml&title=#{array_tmp["subject"]}&x_pos=200&y_pos=0"
    
    api_sig = md5Converter(url)
    _url = url + "&api_sig="+api_sig
    uri = URI.escape(_url)
    
    response = getXML(uri)
    session["response"] = response["rsp"]["id"].to_i
    puts "POST from Redmine to Mindmeister"

    RedmineTable.create(:project_id => session["project_id"], :issue_id => array_tmp["id"], :parent_id => array_tmp["parent"], :subject => array_tmp["subject"])
    MindmeisterTable.create(:map_id => session["map_id"], :idea_id => session["response"], :parent_id => parent_id, :title => array_tmp["subject"])

  end

  
  def changeIdeas(idea_id, title)
    url = "http://www.mindmeister.com/services/rest?api_key=#{$api_key}&auth_token=#{session["auth_token"]}&idea_id=#{idea_id}&map_id=#{session["map_id"]}&method=mm.ideas.change&response_format=xml&title=#{title}"

    api_sig = md5Converter(url)
    _url = url + "&api_sig=" + api_sig
    uri = URI.escape(_url)

    xml = getXML(uri)
  end

  def moveIdeas(idea_id, parent_id)
    url = "http://www.mindmeister.com/services/rest?api_key=#{$api_key}&auth_token=#{session["auth_token"]}&idea_id=#{idea_id}&map_id=#{session["map_id"]}&method=mm.ideas.move&parent_id=#{parent_id}&rank=0&response_format=xml"

    api_sig = md5Converter(url)
    _url = url + "&api_sig=" + api_sig
    uri = URI.escape(_url)

    xml = getXML(uri)

    p url
    puts "あああああああああああああ"
    p xml
  end
end
