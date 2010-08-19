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
