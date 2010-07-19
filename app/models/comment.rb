class Comment < ActiveRecord::Base

  hobo_model # Don't put anything above this

  fields do
    content HoboFields::MarkdownString
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
    return true if owner_is?(acting_user)
    return true if answer.owner_is?(acting_user)
    return true if acting_user.try.role.try.is_recruiter?

    false
  end

  protected
    def notify_new_comment
      UserMailer.deliver_new_comment(answer.owner, self)
    end
end
