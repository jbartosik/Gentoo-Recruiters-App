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
# If you call this in your model it will have exactly the same permissions as
# source.
def inherit_permissions(source)
  one_permission(:view){ send(source).nil? || send(source).send("viewable_by?", acting_user)}
  one_permission(:create){ send(source).nil? || send(source).send("creatable_by?", acting_user)}
  one_permission(:update){ send(source).nil? || send(source).send("updatable_by?", acting_user)}
  one_permission(:destroy){ send(source).nil? || send(source).send("destroyable_by?", acting_user)}
  one_permission(:edit){ send(source).nil? || send(source).send("editable_by?", acting_user)}
end
