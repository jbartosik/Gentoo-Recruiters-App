require 'spec_helper.rb'
describe QuestionsController do
  it "shold not have index" do
    QuestionsController.action_methods.include?('index').should be_false
  end
end
