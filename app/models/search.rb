class Search
  attr_reader :term

  def initialize(term)
    @term = term.to_s.strip
  end

  def guides
    @guides ||= Guide.search(term)
  end

  def cheat_sheets
    @cheat_sheets ||= CheatSheet.search(term)
  end

  def any?
    guides.any? || cheat_sheets.any?
  end
end
