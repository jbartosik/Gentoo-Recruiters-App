require 'spec_helper.rb'
describe 'Permissions' do
  it "should properly set single permission" do
   class DoAll < Question; single_permission { true }; end
   class DoNone < Question; single_permission { false}; end
   guest = Guest.new
   for mod in [ "creat", "updat", "destroy", "view", "edit"]
     DoAll.new.send("#{mod}able_by?", guest).should be_true
     DoNone.new.send("#{mod}able_by?", guest).should be_false
   end
  end
end
