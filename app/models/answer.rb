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
require 'permissions/owned_model.rb'
require 'permissions/set.rb'
# Model storing answers for questions with text content.
# Hooks:
#  * After creation notification is sent to mentor of owner of the answer
#  * After update notification is sent to mentor of owner of the answer
#  * If content of answer was changed it becomes un-approved
#
# Validations:
#  * There can be only one reference answer for each question
#  * User can give only one non-reference answer for each question
class Answer < ActiveRecord::Base

  hobo_model # Don't put anything above this

  fields do
    content   HoboFields::MarkdownString, :null => false, :default => ''
    approved  :boolean, :default => false
    reference :boolean, :default => false
    feedback  HoboFields::EnumString.for('', 'Documentation ok',
                  'Could not find documentation', 'Documentation insufficient'),
                  :default => ''
    timestamps
  end

  attr_readonly :reference
  belongs_to    :question, :null => false
  has_many      :comments

  named_scope   :of_mentored_by, lambda { |mentor| {
    :joins => :owner, :conditions => { 'users.mentor_id', mentor } } }

  named_scope   :in_category, lambda { |category| {
    :joins => :question, :conditions => { 'questions.question_category_id', category} } }

  named_scope   :with_feedback, lambda { |opt| {
    :conditions => { :feedback => opt } } }

  named_scope   :with_some_feedback, :conditions => "answers.feedback IS NOT NULL AND answers.feedback <> ''"

  validates_uniqueness_of :question_id, :scope => :reference, :if => :reference
  validates_uniqueness_of :question_id, :scope => :owner_id, :unless => :reference

  owned_model owner_class = "User"

  before_validation do |record|
    record.approved = false if record.content_changed?
  end

  after_create :notify_new_answer
  after_update :notify_changed_answer

  def update_permitted?
    # It's fine to change correct, because it's ignored in non-email answers
    # and email answers have separate permissions
    return true if owned? && !reference && !approved
    return true if reference && acting_user.role.is_recruiter?
    return true if only_changed?(:approved, :correct) && owner.mentor_is?(acting_user)

    false
  end

  def destroy_permitted?
    return true if owned? && !reference
    return true if reference && acting_user.role.is_recruiter?

    false
  end

  def create_permitted?
    return true if owned_soft? && !reference && !approved
    return true if reference && acting_user.role.is_recruiter?
    false
  end

  # Proper edit permissions can't be deduced, because we need to access value
  # of some fields to set them
  def edit_permitted?(field)
    return true if owned_soft?
    return true if owner.mentor_is?(acting_user)
    return true if reference && acting_user.signed_up? && acting_user.role.is_recruiter?
    false
  end

  def content_edit_permitted?
    return true if owned_soft?
    return true if reference && acting_user.signed_up? && acting_user.role.is_recruiter?
    false
  end

  def feedback_edit_permitted?
    owned_soft?
  end

  def approved_edit_permitted?
    owner.mentor_is?(acting_user)
  end

  def reference_edit_permitted?
    acting_user.role.is_recruiter?
  end

  def view_permitted?(field)
    return true if owned_soft?
    return true if acting_user.role.is_recruiter?
    return true if owner.mentor_is?(acting_user)
    false
  end

  # Returns hash containing updated answer attributes.
  def self.update_from(params)
    ans     = Answer.find(params['id'])
    result  = ans.attributes

    params[ans.class.to_s.underscore]._?.each{ |u| result[u[0]] = u[1] }

    result
  end

  # Returns new answer deducing type and attributes from params
  def self.new_from(params)
    for klass in [Answer, MultipleChoiceAnswer]
      name = klass.to_s.underscore
      return klass.new(params[name]) if params.include? name
    end
  end

  # Returns wrong answers of given user
  def self.wrong_answers_of(uid)
    MultipleChoiceAnswer.find_by_sql ["SELECT ans.* FROM answers ans, answers ref WHERE
      ref.reference = ? AND ans.question_id = ref.question_id AND
      ans.content != ref.content AND ans.owner_id = ?", true, uid]
  end

  protected
    # Sends email notification about new answer to mentor of owner
    def notify_new_answer
      UserMailer.delay.deliver_new_answer(owner.mentor, self) unless owner._?.mentor.nil?
    end

    # Sends email notification about changed answer to mentor of owner
    def notify_changed_answer
      UserMailer.delay.deliver_changed_answer(owner.mentor, self) unless owner._?.mentor.nil?
    end

end
