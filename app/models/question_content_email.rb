require 'permissions/inherit.rb'
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

  def req_text_view_permitted?
    return true if acting_user.role.is_recruiter?
    return true if question.owner_is?(acting_user) && !question.approved
  end

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
    h(req_text).sub("\n", "<br/>\n")
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
