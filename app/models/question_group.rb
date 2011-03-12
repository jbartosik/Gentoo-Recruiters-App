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
# Users should answer only one question from each group. The question recruit
# should answer is randomly chosen from group by application. Unless user is
# recruit [s]he can't view grouped questions [s]he is not supposed to answer.
# Recruits can prepare to answer grouped questions by reading group description.
class QuestionGroup < ActiveRecord::Base

  hobo_model # Don't put anything above this

  fields do
    name        :string, :null => false
    description HoboFields::MarkdownString, :null => false
    timestamps
  end

  has_many :questions
  validates_presence_of   :name, :description
  validates_uniqueness_of :name
  include Permissions::AnyoneCanViewAdminCanChange

  named_scope :in_category, lambda { |cid| {
    :joins => {:questions => :question_categories}, :conditions => ['question_categories.category_id = ?', cid],
    :group => 'question_groups.id, question_groups.name, question_groups.description,
      question_groups.created_at, question_groups.updated_at'}}

  named_scope :unassociated_in_category, lambda { |uid, cid| {
    :joins => {:questions => :question_categories}, :conditions => ['question_categories.category_id = ? AND NOT EXISTS
      (SELECT user_question_groups.* FROM user_question_groups INNER JOIN questions ON
      questions.id = user_question_groups.question_id WHERE (user_question_groups.user_id = ?
      AND questions.question_group_id = question_groups.id))', cid, uid],
    :group => 'question_groups.id, question_groups.name, question_groups.description,
      question_groups.created_at, question_groups.updated_at'}}
end
