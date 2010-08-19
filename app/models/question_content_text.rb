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
require 'permissions/inherit.rb'
class QuestionContentText < ActiveRecord::Base

  hobo_model # Don't put anything above this

  fields do
    content HoboFields::MarkdownString, :null => false
    timestamps
  end

  belongs_to    :question, :null => false
  attr_readonly :question

  validates_length_of   :content, :minimum => 2

  inherit_permissions(:question)

  # Returns new answer (of proper class) of user for question (relation).
  def new_answer_of(user)
    Answer.new :question_id => question_id, :owner => user
  end
end
