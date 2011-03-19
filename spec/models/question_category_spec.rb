require 'spec_helper.rb'

describe QuestionCategory do
  include Permissions::TestPermissions

  it "should allow admin to do everything" do
    allow_all Factory(:administrator), Factory(:question_category)
  end
end
