#    Gentoo Recruiters Web App - to help Gentoo recruiters do their job better
#   Copyright (C) 2010 Joachim Filip Bartosik
#
#   This program is free software: you can redistribute it and/or modify
#   it under the terms of the GNU Affero General Public License as
#   published by the Free Software Foundation, version 3 of the License
#
#   This program is distributed in the hope that it will be useful,
#   but WITHOUT ANY WARRANTY; without even the implied warranty of
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#   GNU Affero General Public License for more details.
#
#   You should have received a copy of the GNU Affero General Public License
#   along with this program.  If not, see <http://www.gnu.org/licenses/>.
class AnswersController < ApplicationController

  hobo_model_controller
  auto_actions      :all, :except => [:index, :new, :show]
  auto_actions_for  :question, :new
  index_action      :my_recruits, :my_recruits_cat

  def update
    # This creates answer with type deduced from params
    # (as opposed answer with type Answer)
    hobo_update Answer.find(params['id']),:attributes => Answer.update_from(params)
  end

  def create
    # This creates answer with type deduced from params
    # (as opposed answer with type Answer)
    hobo_create Answer.new_from params
  end

  def show
    owner_id = Answer.find(params[:id]).owner_id
    answers = Answer.find_all_by_owner_id(owner_id)
    answer_id = answers.index{|x| x.id==params[:id].to_i}
    user  = User.find(owner_id)
    redirect_to "/users/#{user.id}-#{user.name.gsub(' ','-')}/answer/#{answer_id}"
  end
  def show_answer
     owner_id = (params[:user]).match(/\d+/)[0]
     if (not owner_id.nil?)
       answers = Answer.find_all_by_owner_id(owner_id)
       answer = answers[params[:answer_id].to_i]
       raise Exception if answers.nil? or answer.nil?
       params[:id] = answer.id
       hobo_show
     else raise Exception
     end
  end
end
