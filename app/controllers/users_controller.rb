class UsersController < ApplicationController

  hobo_user_controller
  openid_login:openid_opts => { :model => User }

  auto_actions :all, :except => [ :index, :new, :create ]
  index_action :ready_recruits
  index_action :mentorless_recruits
  show_action  :questions

  def ready_recruits
    hobo_index User.recruits_answered_all
  end

  def mentorless_recruits
    hobo_index  User.mentorless_recruits
  end

  def questions
    hobo_show do
      @user = this
    end
  end

  skip_before_filter :verify_authenticity_token, :only => [:receive_email]

  def receive_email
    raise Hobo::PermissionDeniedError unless request.remote_ip == '127.0.0.1'
    UserMailer.receive(params[:email])
    render :text => 'Email Received'
  end
end
