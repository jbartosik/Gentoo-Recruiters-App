class ProjectAcceptancesController < ApplicationController

  hobo_model_controller

  auto_actions :all, :except => [:index]
  index_action :pending_acceptances

  def pending_acceptances
    hobo_index ProjectAcceptance.accepting_nick_is(current_user.nick)
  end
end
