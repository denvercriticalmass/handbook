require "rails_helper"

RSpec.describe Season do
  it "runs winter from November through April" do
    expect((1..12).select { described_class.for(it).winter? }).to eq([ 1, 2, 3, 4, 11, 12 ])
  end

  it "meets on Sunday afternoons in winter" do
    expect(described_class.for(12)).to have_attributes(weekday: :sunday, gathers_at: "12:30pm", rides_at: "1:00pm")
  end

  it "meets on Friday evenings in summer" do
    expect(described_class.for(7)).to have_attributes(weekday: :friday, gathers_at: "6:30pm", rides_at: "7:00pm")
  end
end
