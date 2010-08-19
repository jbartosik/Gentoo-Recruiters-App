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
require 'permissions/set'
module Permissions
  # If you include this recruiters will be allowed to do everything,
  # others users will will be able only to view.
  module AnyoneCanViewRecruiterCanChange
    multi_permission :create, :update, :destroy do
      User.user_is_recruiter?(acting_user)
    end

    def view_permitted?(field)
      true
    end
  end
end
