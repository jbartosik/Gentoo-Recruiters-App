class CommentsController < ApplicationController

  hobo_model_controller

  auto_actions :all, :except => [:index, :new]
  auto_actions_for :answer, :new
end
