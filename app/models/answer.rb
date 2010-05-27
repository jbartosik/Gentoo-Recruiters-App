require 'permissions/owned_model.rb'
require 'permissions/set.rb'
class Answer < ActiveRecord::Base

  hobo_model # Don't put anything above this

  fields do
    content   :text
    reference :boolean, :default => false
    timestamps
  end
  attr_readonly :reference
  belongs_to    :question

  validates_uniqueness_of :question_id, :scope => :reference, :if => :reference
  validates_uniqueness_of :question_id, :scope => :owner_id, :unless => :reference

  owned_model owner_class = "User"

  multi_permission :update, :destroy do
    (owned? && !reference) || (reference && acting_user.role.is_recruiter?)
  end

  multi_permission :create, :view do
    (owned_soft? && !reference)||(reference && acting_user.role.is_recruiter?)
  end

  def edit_permitted?(field)
    owned_soft? ||
    (reference && acting_user.signed_up? && acting_user.role.is_recruiter?)
  end

  def content_edit_permitted?
    owned_soft? ||
    (reference && acting_user.signed_up? && acting_user.role.is_recruiter?)
  end

  def view_permitted?(field)
    owned_soft? ||
      User.user_is_recruiter?(acting_user)||
      User.user_is_mentor_of?(acting_user, owner)
  end
end
