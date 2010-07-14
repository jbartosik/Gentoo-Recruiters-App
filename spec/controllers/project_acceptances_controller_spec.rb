require 'spec_helper.rb'
describe ProjectAcceptancesController do
  it "should not have index action" do
    ProjectAcceptancesController .action_methods.include?('index').should be_false
  end
end
