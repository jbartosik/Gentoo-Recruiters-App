# Model storing comments mentors made for answers.
class Comment < ActiveRecord::Base

  hobo_model # Don't put anything above this

  fields do
    content HoboFields::MarkdownString, :null => false
    timestamps
  end
  belongs_to    :answer, :null => false
  attr_readonly :answer

  validates_presence_of :content

  after_create :notify_new_comment

  owned_model "User"

  def create_permitted?
    answer.owner.mentor_is?(acting_user) && owned_soft?
  end

  def view_permitted?(field)
    # only recruiters, mentor who created comment
    # and recruit who owns answer can view
    return true if owner_is?(acting_user)
    return true if answer.owner_is?(acting_user)
    return true if acting_user.role.is_recruiter?

    false
  end

  protected
    # Sends notification about new comment to owner of mentor
    def notify_new_comment
      UserMailer.deliver_new_comment(answer.owner, self)
    end
end
