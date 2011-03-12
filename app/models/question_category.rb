#   Gentoo Recruiters Web App - to help Gentoo recruiters do their job better
#   Copyright (C) 2011 Petteri Räty
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

# Associates questions to categories
class QuestionCategory < ActiveRecord::Base

  hobo_model # Don't put anything above this

  fields do
  end

  belongs_to :question, :null => false, :index => false
  belongs_to :category, :null => false, :index => false
  index [:question_id, :category_id], :unique => true
end
