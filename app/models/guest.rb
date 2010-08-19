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
# Model representing guest users.
# It has methods that allow us to treat Guests as regular users.
class Guest < Hobo::Guest
  def administrator?; false; end
  def answered_questions; []; end
  def any_pending_acceptances?; false; end
  def id; nil; end
  def mentor; nil; end
  def mentor_is?(x); false; end
  def nick; nil; end
  def project_lead; false; end
  def questions_to_approve; []; end
  def role; RichTypes::Role.new(:guest); end
  def token; nil; end
  def valid?; true; end
  def save!; true; end
end
