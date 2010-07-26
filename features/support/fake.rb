# Fake object to be returned when stubbing doesnt't work
class Fake
  # OpenID - related stuff
  def redirect_url(arg1, arg2)
    "/users/complete_openid"
  end
  def status
    return OpenID::Consumer::SUCCESS
  end
  def identity_url
    "/"
  end
  def message
    ""
  end
end
