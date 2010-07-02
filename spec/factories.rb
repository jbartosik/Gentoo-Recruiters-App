  Factory.sequence :recruit do |n|
    "recruit-#{n}"
  end

  Factory.sequence :mentor do |n|
    "mentor-#{n}"
  end

  Factory.sequence :recruiter do |n|
    "recruiter-#{n}"
  end

  Factory.sequence :administrator do |n|
    "administrator-#{n}"
  end

  # Creates a new mentor for recruit by default
  Factory.define :recruit, :class => User do |u|
    u.name          { Factory.next(:recruit) }
    u.email_address { |u| "#{u.name}@recruits.org" }
    u.mentor        { Factory(:mentor) }
  end

  Factory.define :mentor, :class => User do |u|
    u.name          { Factory.next(:mentor) }
    u.email_address { |u| "#{u.name}@recruiters.org" }
    u.role          :mentor
    u.nick          { |u| u.name }
  end

  Factory.define :recruiter, :class => User do |u|
    u.name          { Factory.next(:recruiter) }
    u.email_address { |u| "#{u.name}@recruiters.org" }
    u.role          :recruiter
    u.nick          { |u| u.name }
  end

  Factory.define :administrator, :class => User do |u|
    u.name          { Factory.next(:administrator) }
    u.email_address { |u| "#{u.name}@admins.org" }
    u.role          :recruiter
    u.administrator true
    u.nick          { |u| u.name }
  end

  Factory.sequence :question_category do |n|
    "question category-#{n}"
  end

  Factory.define :question_category do |q|
    q.name  { Factory.next(:question_category) }
  end

  Factory.sequence :question do |n|
    "question-#{n}"
  end

  # it'll belong to new category by default
  Factory.define :question do |q|
    q.title             { Factory.next(:question) }
    q.question_category { Factory(:question_category)}
  end

  Factory.sequence :answer do |n|
    "answer-#{n}"
  end

  # It'll be answer of new recruit for a new question by default
  Factory.define :answer do |a|
    a.content   { Factory.next(:answer) }
    a.question  { Factory(:question)}
    a.owner     { Factory(:recruit)}
  end

  Factory.define :user_category do |q|
    q.user              { Factory(:recruit) }
    q.question_category { Factory(:question_category) }
  end

  Factory.sequence :comment do |n|
    "comment-#{n}"
  end

  Factory.define :comment do |c|
    c.answer  { Factory(:answer) }
    c.owner   { |c| c.answer.owner.mentor }
    c.content { Factory.next(:comment) }
  end

  # create new recruit (being accepted) and mentor (accepting) by default
  Factory.define :project_acceptance do |a|
    a.user            { Factory(:recruit) }
    a.accepting_nick  { Factory(:mentor).nick }
  end

  Factory.sequence :question_group do |n|
    "question_group-#{n}"
  end

  Factory.define :question_group do |c|
    c.name        { Factory.next(:question_group) }
    c.description "Just another group"
  end

  Factory.define :user_question_group do |c|
    c.user            { Factory(:user) }
    c.question        { Factory(:question, :question_group => Factory(:question_group)) }
  end

  Factory.define :question_content_text do |q|
    q.content         "fake"
  end

  Factory.define :question_content_multiple_choice do |q|
  end
