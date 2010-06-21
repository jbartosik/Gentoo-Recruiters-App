class UserHints < Hobo::ViewHints
  children :answers, :question_categories, :project_acceptances
end
