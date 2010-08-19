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
# Model storing answers for questions with multiple choice content.
class MultipleChoiceAnswer < Answer
  # Returns RichTypes::CheckList describing given answer
  def options
    if @options.nil?
      @options          = RichTypes::CheckList.new(question.content.options)
      @options.options  = content.to_s
    end
    @options
  end

  # Sets new answer
  def options=(what)
    self.options
    @options.options = what
    self.content = @options.to_s
  end
end
