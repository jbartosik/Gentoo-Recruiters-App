class UsersController < ApplicationController

  hobo_user_controller

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
end
