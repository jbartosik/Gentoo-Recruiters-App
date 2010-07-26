Given /^openid is always succesfull$/ do
  OpenID::Consumer.class_eval do
    def begin(arg={})
      Fake.new
    end

    def complete(arg={}, arg2={})
      Fake.new
    end
  end
  OpenID::SReg::Response.class_eval do
    def self.from_success_response(arg={})
      []
    end
  end
end
