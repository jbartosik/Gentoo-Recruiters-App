class Comment < ActiveRecord::Base

  hobo_model # Don't put anything above this

  fields do
    content :text
    timestamps
  end
  belongs_to    :answer

  validates_presence_of :content

  after_create :notify_new_comment

  owned_model "User"
  def create_permitted?
    answer.owner.mentor_is?(acting_user) && owned_soft?
  end

  def view_permitted?(field)
    # only recruiters, mentor who created comment
    # and recruit who owns answer can view
    owner_is?(acting_user) || answer.owner_is?(acting_user) ||
      acting_user.try.role.try.is_recruiter?
  end

  protected
    def notify_new_comment
      UserMailer.deliver_new_comment(answer.owner, self)
    end
end
