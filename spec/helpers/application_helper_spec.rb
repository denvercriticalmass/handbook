require "rails_helper"

RSpec.describe ApplicationHelper do
  it "says what suspending does" do
    expect(helper.suspension_warning(build(:user, name: "Corker Joe")))
      .to eq("Suspend Corker Joe? They are signed out and can't sign back in.")
  end

  it "asks plainly when reinstating" do
    expect(helper.suspension_warning(build(:user, :suspended, name: "Corker Joe")))
      .to eq("Reinstate Corker Joe?")
  end
end
