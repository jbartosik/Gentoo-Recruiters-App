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
require 'permissions/inherit.rb'
# TODO: all QuestionContents in one table(?)
# TODO: use standard serialization, not custom one (?)
# To answer question with QuestionContentEmail user should send to application
# email meeting specified requirements (recruits can't see requirements), they
# should learn them from question description and documentation.
class QuestionContentEmail < ActiveRecord::Base

  hobo_model # Don't put anything above this

  fields do
    requirements :text, :null => false, :default => ""
    description  HoboFields::MarkdownString
    timestamps
  end

  belongs_to            :question, :null => false
  attr_readonly         :question
  never_show            :requirements

  inherit_permissions(:question)

  # Returns array.
  # Each item of array is array [field, expected value]
  def req_array
    if requirements.nil? || requirements.empty?
      []
    else
      ActiveSupport::JSON.decode requirements
    end
  end

  # Returns easy-human-readable string
  # Each line is in format
  # field : value
  def req_text
    res = req_array.inject(String.new) do |res, cur|
      # escape colons
      cur[0].sub!(':', '\:')
      cur[1].sub!(':', '\:')

      res += "#{cur[0]} : #{cur[1]}\n"
    end
    HoboFields::Text.new(res)
  end

  # req_text escaped to display properly as HTML
  def req_html
    CGI.escapeHTML(req_text).sub("\n", "<br/>\n")
  end

  # Converts easy-human-readable string to JSON and saves in requirements
  # Ignore improperly formatted lines ( i.e. lines that
  def req_text=(str)
    # Split to lines
    # Split every line at /\s:/, unescape colons, strip white space
    # Ignore lines that don't have exactly one /\s:/
    res = str.split(/\n/).inject(Array.new) do |result, line|

      item = line.split(/\s:/).inject(Array.new) do |r,c|
        c.sub!('\:', ':')
        c.strip!
        r.push c
      end

      result.push(item) if item.count == 2
      result
    end

    self.requirements = res.to_json
  end
end
