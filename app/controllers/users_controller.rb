class UsersController < ApplicationController

  hobo_user_controller

  auto_actions :all, :except => [ :index, :new, :create ]
  index_action :ready_recruits

  def ready_recruits
    hobo_index
  end
end
