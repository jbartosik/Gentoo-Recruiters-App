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
# Hobo model storing options for multiple choice questions.
# Inherits permissions from option_owner.
class Option < ActiveRecord::Base

  hobo_model # Don't put anything above this

  fields do
    content :string, :null => false
    timestamps
  end

  belongs_to    :option_owner, :polymorphic => true, :creator => true, :null => false
  never_show    :option_owner_type

  inherit_permissions(:option_owner)
end
