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
class QuestionsController < ApplicationController

  hobo_model_controller

  auto_actions :all, :except => :index
  index_action :answered_questions, :unanswered_questions, :suggest_questions, :approve_questions

  def answered_questions
    hobo_index current_user.answered_questions
  end

  def suggest_questions
    hobo_index Question.suggested_questions(current_user.id)
  end

  def approve_questions
    hobo_index Question.questions_to_approve
  end
end
