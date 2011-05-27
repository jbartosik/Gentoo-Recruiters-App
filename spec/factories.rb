  # Creates a new mentor for recruit by default
  Factory.define :recruit, :class => User do |u|
    u.sequence(:name) { |n| "recruit-#{n}" }
    u.email_address { |u| "#{u.name}@recruits.org" }
    u.mentor        { Factory(:mentor) }
  end

  Factory.define :developer, :class => User do |u|
    u.sequence(:name) { |n| "developer-#{n}" }
    u.email_address { |u| "#{u.name}@developers.org" }
    u.role          :developer
    u.nick          { |u| u.name }
  end

  Factory.define :mentor, :class => User do |u|
    u.sequence(:name) { |n| "mentor-#{n}" }
    u.email_address { |u| "#{u.name}@recruiters.org" }
    u.role          :mentor
    u.nick          { |u| u.name }
  end

  Factory.define :recruiter, :class => User do |u|
    u.sequence(:name) { |n| "recruiter-#{n}" }
    u.email_address { |u| "#{u.name}@recruiters.org" }
    u.role          :recruiter
    u.nick          { |u| u.name }
  end

  Factory.define :administrator, :class => User do |u|
    u.sequence(:name) { |n| "administrator-#{n}" }
    u.email_address { |u| "#{u.name}@admins.org" }
    u.role          :recruiter
    u.administrator true
    u.nick          { |u| u.name }
  end

  Factory.define :category do |q|
    q.sequence(:name)  { |n| "category-#{n}" }
  end

  Factory.define :question_category do |qc|
    qc.association :question
    qc.association :category
  end

  # it'll belong to new category by default
  Factory.define :question do |q|
    q.sequence(:title)  { |n| "question-#{n}" }
    q.after_build { |q|
      q.categories = [Factory.build :category]
    }
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

  # It'll be answer of new recruit for a new question by default
  Factory.define :multiple_choice_answer do |a|
    a.content   { Factory.next(:answer) }
    a.question  { Factory(:question)}
    a.owner     { Factory(:recruit)}
  end

  Factory.define :user_category do |q|
    q.user              { Factory(:recruit) }
    q.category { Factory(:category) }
  end

  Factory.define :comment do |c|
    c.answer  { Factory(:answer) }
    c.owner   { |c| c.answer.owner.mentor }
    c.sequence(:content) { |n| "comment-#{n}" }
  end

  # create new recruit (being accepted) and mentor (accepting) by default
  Factory.define :project_acceptance do |a|
    a.user            { Factory(:recruit) }
    a.accepting_nick  { Factory(:mentor).nick }
  end

  Factory.define :question_group do |c|
    c.sequence(:name) { |n| "question_group-#{n}" }
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
    q.content "fake"
  end

  Factory.define :question_content_email do |q|
    q.question {Factory(:question)}
  end

  Factory.define :option do |o|
    o.content "fake"
  end

  Factory.define :guest do |g|; end
