class Tagged
  attr_reader :name

  def initialize(name)
    @name = name.to_s
  end

  def guides
    @guides ||= Guide.tagged_with(name).by_title
  end

  def cheat_sheets
    @cheat_sheets ||= CheatSheet.tagged_with(name).by_title
  end

  def any?
    guides.any? || cheat_sheets.any?
  end
end
