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
require 'permissions/set.rb'
# Associates users with question categories
# Hooks:
#  * Before creation looks through groups in category and associates user with
#     one randomly chosen question from each group (unless user is already
#     associated with some question from the group)
#     TODO: wrap the whole thing in transaction (?)
class UserCategory < ActiveRecord::Base

  hobo_model # Don't put anything above this

  fields do
    timestamps
  end

  belongs_to :user, :null => false
  belongs_to :category, :null => false

  validates_uniqueness_of :user_id, :scope => :category_id

  multi_permission :create, :update, :destroy do
    return true if acting_user.role.is_recruiter?
    return true if user_is?(acting_user)

    false
  end

  def view_permitted?(field)
    return true if acting_user.role.is_recruiter?
    return true if user_is?(acting_user)
    return true if user.mentor_is?(acting_user)

    false
  end

  def before_create
    for group in QuestionGroup.unassociated_in_category(user, category).all
      chosen_question = rand(group.questions.count)
      UserQuestionGroup.create! :user => user, :question =>
        (Question.all :limit => 1, :offset => chosen_question, :conditions => {:question_group_id => group.id})[0]
    end
  end
end
