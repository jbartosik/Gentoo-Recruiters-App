module NavigationHelpers
  # Maps a name to a path. Used by the
  #
  #   When /^I go to (.+)$/ do |page_name|
  #
  # step definition in web_steps.rb
  #
  def path_to(page_name)
    case page_name

    when /the home\s?page/
      '/'

    when /login page/
      user_login_path

    when /edit "([^\"]*)" user page/
      edit_user_path(User.find_by_name($1))

    when /"([^\"]*)" user page/
      user_path(User.find_by_name($1))

    when /unanswered questions page/
      unanswered_questions_questions_path

    when /answer of "([^\"]*)" for question "([^\"]*)" page/
      answer_path(Question.find_by_title($2).answer_of(User.find_by_name($1)))

    when /new comment for answer of "([^\"]*)" for question "([^\"]*)"/
      new_comment_for_answer_path(Question.find_by_title($2).answer_of(User.find_by_name($1)))

    when /newest comment page/
      comment_path(Comment.last)

    when /recruits waiting for your acceptance page/
      pending_acceptances_project_acceptances_path

    when /project acceptance of "([^\"]*)" by "([^\"]*)" edit page/
      edit_project_acceptance_path(ProjectAcceptance.find_by_user_name_and_accepting_nick($1, $2))

    when /all my questions page/
      my_questions_questions_path

    when /my answered questions page/
      answered_questions_questions_path

    when /my unanswered questions page/
      unanswered_questions_questions_path

    when /questions index page/
      questions_path

    when /question groups index page/
      category_question_groups_path
    # Add more mappings here.
    # Here is an example that pulls values out of the Regexp:
    #
    #   when /^(.*)'s profile page$/i
    #     user_profile_path(User.find_by_login($1))
    when /ready recruits/
      ready_recruits_users_path

    else
      begin
        page_name =~ /the (.*) page/
        path_components = $1.split(/\s+/)
        self.send(path_components.push('path').join('_').to_sym)
      rescue Object => e
        raise "Can't find mapping from \"#{page_name}\" to a path.\n" +
          "Now, go and add a mapping in #{__FILE__}"
      end
    end
  end
end

World(NavigationHelpers)
