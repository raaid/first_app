class Session < Authlogic::Session::Base

authenticate_with User

  def remember_me(value = nil)
    return @remember_me if defined? @remember_me
    return true
  end
end