# -*- coding: utf-8 -*-
require 'open-uri'
require 'active_support/core_ext'
require 'oauth'
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

    redirect_to "/mindmeister_top"
  end


  def getFrob
    url = "http://www.mindmeister.com/services/rest?api_key=" + $api_key + "&method=mm.auth.getFrob&response_format=xml"
    str = url.clone

    api_sig = md5Converter(str)
    _url = url + "&api_sig=" + api_sig

    xml = getXML(_url)
    return xml
  end


  def createToken
    url = "http://www.mindmeister.com/services/auth/?api_key=" + $api_key + "&perms=delete"
    str = url.clone

    str.slice!("http://www.mindmeister.com/services/auth/?")
    str.delete!("=")
    str.delete!("&")

    api_sig = md5Converter(str)
    _url = url + "&api_sig=" + api_sig

    redirect_to _url
  end


  def getToken(frob)
    url = "http://www.mindmeister.com/services/rest?api_key=" + $api_key + "&frob=" + frob + "&method=mm.auth.getToken&response_format=xml"
    str = url.clone

    api_sig = md5Converter(str)
    _url = url + "&api_sig=" + api_sig

    xml = getXML(_url)
    return xml["rsp"]["auth"]["token"]
  end


  def checkToken
    url = "http://www.mindmeister.com/services/rest?api_key=" + $api_key + "&auth_token=" + session["auth_token"] + "&method=mm.auth.checkToken&response_format=xml"
    str = url.clone

    api_sig = md5Converter(str)
    _url = url + "&api_sig=" + api_sig

    xml = getXML(_url)
    return xml["rsp"]["stat"]
  end


  def getMaps
    # Get Maps of User
    session["user_name"] = params[:text_field][:user_name]
    url = "http://www.mindmeister.com/services/rest?api_key=" + $api_key + "&auth_token=" + session["auth_token"] + "&method=mm.maps.getChannel&response_format=xml&user=" + session["user_name"]
    str = url.clone
    api_sig = md5Converter(str)
    _url = url + "&api_sig=" + api_sig

    maps_xml = getXML(_url)

    array = Array.new
    maps_xml["rsp"]["maps"]["map"].each{ |p|
      data = Hash.new
      data["title"] = p["title"].to_s
      data["id"] = p["id"].to_i
      array.push(data)
    }
    session[:maps] = array

    redirect_to "/mindmeister_top"
  end


  def getNodes
    # Get Nodes of Map
    session["map_title"] = params[:title]
    session["map_id"] = params[:id]
    url = "http://www.mindmeister.com/services/rest?api_key=" + $api_key + "&auth_token=" + session["auth_token"] + "&map_id=" + session["map_id"] + "&method=mm.maps.getMap&response_format=xml"
    str = url.clone
    api_sig = md5Converter(str)
    _url = url + "&api_sig=" + api_sig

    map_xml = getXML(_url)

    array = Array.new
    map_xml["rsp"]["ideas"]["idea"].each{ |p|
      data = Hash.new
      data["id"] = p["id"].to_i
      data["title"] = p["title"].to_s
      data["parent"] = p["parent"].to_i
      array.push(data)
    }
    session[:map] = array

    redirect_to "/mindmeister_map"
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


  def md5Converter(str)
    str.slice!("http://www.mindmeister.com/services/rest?")
    str.delete!("=")
    str.delete!("&")

    md5 = Digest::MD5.hexdigest($api_secret  + str)
    return md5
  end


  def destroyAnother
    reset_session
    redirect_to "/mindmeister_top"
  end
end
