class AnswersController < ApplicationController

  hobo_model_controller

  auto_actions :all
  index_action :my_recruits, :my_recruits_cat

end
