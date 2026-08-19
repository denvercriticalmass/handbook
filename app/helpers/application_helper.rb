module ApplicationHelper
  def suspension_warning(user)
    if user.active?
      "Suspend #{user.name}? They are signed out and can't sign back in."
    else
      "Reinstate #{user.name}?"
    end
  end
end
