class UsersController < ApplicationController

  hobo_user_controller

  auto_actions :all, :except => [ :index, :new, :create ]
  index_action :ready_recruits
  index_action :mentorless_recruits

  def ready_recruits
    hobo_index
  end

  def mentorless_recruits
    hobo_index  User.mentorless_recruits
  end
end
