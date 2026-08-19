Season = Data.define(:weekday, :gathers_at, :rides_at)

class Season
  WINTER = new(weekday: :sunday, gathers_at: "12:30pm", rides_at: "1:00pm")
  SUMMER = new(weekday: :friday, gathers_at: "6:30pm", rides_at: "7:00pm")
  WINTER_MONTHS = [ 11, 12, 1, 2, 3, 4 ].freeze

  def self.for(month)
    WINTER_MONTHS.include?(month) ? WINTER : SUMMER
  end

  def winter?
    self == WINTER
  end
end
