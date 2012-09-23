class WelcomesController < ApplicationController

  def gate
  end


  def index
  end


  def signUpPage
  end


  def setting
  end


  def signUp
    user_name = params[:text_field][:user_name]
    password = params[:text_field][:password]
    conf_pass = params[:text_field][:conf_pass]
    exist_user = Info.find_by_user_name_d(user_name)

    if (password != "") && (password == conf_pass)
      if exist_user
        redirect_to "/signUpPage", :alert => "User Name '#{user_name}' is already exists."
      else
        user = Info.create(:user_name_d => user_name, :password_d => password)
        redirect_to "/index"
      end
    else
      redirect_to "/signUpPage", :alert => "Sorry, Password do not match."
    end
  end


  def redmeisterLogin
    user_name = params[:text_field][:user_name]
    password = params[:text_field][:password]

    user = Info.find_by_user_name_d_and_password_d(user_name, password)

    if user
      session["user_id"] = user.id
      redirect_to "/index"
    else
      session["user_id"] = nil
      redirect_to root_path, :alert => "Invalid login. Please try again."
    end
  end


end
