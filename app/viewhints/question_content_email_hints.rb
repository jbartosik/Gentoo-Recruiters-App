class QuestionContentEmailHints < Hobo::ViewHints
  field_help :req_text => "Enter one requirement per line.
                            Each requirement should be 'Field : regexp to match' (including spaces around colon).
                            If you want to use colon in field and regexp then escape it with backslash."
end
