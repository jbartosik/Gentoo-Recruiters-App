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

  auto_actions      :all, :except => [:index, :new]
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
end
