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
    return xml["rsp"]["map"]
  end


  def publishMap(map_id)
    url = "http://www.mindmeister.com/services/rest?api_key=#{$api_key}&auth_token=#{session["auth_token"]}&map_id=#{map_id.to_s}&method=mm.maps.publish&response_format=xml"

    api_sig = md5Converter(url)
    _url = url + "&api_sig=" + api_sig

    xml = getXML(_url)
    return xml
  end


  def changeIdeas(map_id, project_name)
    url = "http://www.mindmeister.com/services/rest?api_key=#{$api_key}&auth_token=#{session["auth_token"]}&idea_id=#{map_id.to_s}&map_id=#{map_id.to_s}&method=mm.ideas.change&response_format=xml&title=#{project_name}"

    api_sig = md5Converter(url)
    _url = url + "&api_sig=" + api_sig
    uri = URI.escape(_url)

    xml = getXML(uri)
    return xml
  end

end
