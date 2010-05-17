require 'spec_helper.rb'
describe 'User' do

  fixtures :users

  before(:each) do
    @new_user = users(:uriael)
    @admin    = users(:ann)
    @admin2   = users(:alice)
  end

  it "should be non-admin recruit" do
    @new_user.should_not   be_administrator
    @new_user.role.should  == :recruit
  end

  it "should be able to become mentor and recruiter" do
    for new_role in [:mentor, :recruiter] do
      @new_user.role        = new_role
      @new_user.should      be_valid
    end
  end

  it "should be valid if recruiter is administrator" do
    @new_user.role = :recruiter
    @new_user.administrator = true
    @new_user.should be_valid
  end

  it "should be invalid if non-recruiter is administrator" do
    @new_user.administrator = true

    for new_role in [:recruit, :mentor]
      @new_user.role        =  new_role
      @new_user.should_not  be_valid
    end
  end

  it "should be prohibited for non-admin to change anyone role" do
    for new_role in [:recruiter, :mentor]
      @new_user.role        =  new_role
      @new_user.should_not  be_updatable_by(@new_user)
    end
  end

  it "should be allowed for admin to change anyone else role" do
    for other_user in [@new_user, @admin]
      for new_role in [:recruit, :mentor, :recruiter]
        other_user.role    = new_role
        other_user.should  be_updatable_by(@admin2)
      end
    end
  end
end
