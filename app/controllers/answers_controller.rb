class AnswersController < ApplicationController

  hobo_model_controller

  auto_actions      :all, :except => [:index, :new]
  auto_actions_for  :question, :new
  index_action      :my_recruits, :my_recruits_cat

 def create
  # This creates answer with type deduced from params
  # (as opposed answer with type Answer)
  hobo_create Answer.new_from params
 end
end
