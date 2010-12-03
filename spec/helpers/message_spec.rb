require 'spec_helper.rb'
describe Mail::Message do
  it "should recognize signatures" do
    mails_dir   = "#{RAILS_ROOT}/spec/files"
    mail_files  = ["valid-signed-thun-01.eml", "invaild-signed-thun-01.eml",
                    "valid-signed-mutt-01.eml", "valid-signed-mutt-02.eml",
                    "valid-signed-mac-01.eml", "invalid-signed-mutt-01.eml",
                    "invalid-signed-mutt-02.eml", "invalid-signed-mac-01.eml"]
    for mail_file in mail_files
      mail = Mail.read("#{mails_dir}/#{mail_file}")
      mail.signatures.length.should ==  1
      mail.signatures.first.match(/signature/).should_not be_nil
    end
  end

  it "should recognize unsigned messages" do
    mails_dir   = "#{RAILS_ROOT}/spec/files"
    mail_files  = ["unsigned-gmail-01.eml",
                  "unsigned-thunderbird-w-atachment-01.eml",
                  "unsigned-thunderbird-w-atachment-02.eml"]

    for mail_file in mail_files
      mail = Mail.read("#{mails_dir}/#{mail_file}")
      mail.signatures.should ==  []
    end
  end
end
