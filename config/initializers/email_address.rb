require 'hobo_fields/email_address'

class HoboFields::EmailAddress
  def to_html_with_escape(xmldoctype = true)
    ERB::Util.h to_html_without_escape xmldoctype
  end

  alias_method_chain :to_html, :escape
end
