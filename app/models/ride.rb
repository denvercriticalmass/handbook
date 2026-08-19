# When the next ride is. Ported from the static site's main.js, which moves the
# ride to Sunday afternoons from November through March so it isn't in the dark.
class Ride
  WINTER_MONTHS = [ 11, 12, 1, 2, 3 ].freeze
  WINTER = { weekday: :sunday, gathers_at: "1:30pm", rides_at: "2:00pm" }.freeze
  SUMMER = { weekday: :friday, gathers_at: "6:30pm", rides_at: "7:00pm" }.freeze

  attr_reader :on

  def self.next(on: Date.current)
    candidate = new(last_ride_day_of(on.year, on.month))
    candidate.on < on ? new(last_ride_day_of(*next_month(on))) : candidate
  end

  def self.next_month(date)
    following = date.next_month
    [ following.year, following.month ]
  end

  # prev_occurring is strictly previous, so a month ending on the ride day
  # would otherwise skip back a week.
  def self.last_ride_day_of(year, month)
    weekday = WINTER_MONTHS.include?(month) ? WINTER[:weekday] : SUMMER[:weekday]
    last = Date.new(year, month, -1)

    last.public_send(:"#{weekday}?") ? last : last.prev_occurring(weekday)
  end

  def initialize(on)
    @on = on
  end

  def winter?
    WINTER_MONTHS.include?(on.month)
  end

  def gathers_at
    season[:gathers_at]
  end

  def rides_at
    season[:rides_at]
  end

  private

    def season
      winter? ? WINTER : SUMMER
    end
end
