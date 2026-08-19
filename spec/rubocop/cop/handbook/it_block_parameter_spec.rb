require "cop_helper"

RSpec.describe RuboCop::Cop::Handbook::ItBlockParameter, :config do
  it "flags a named parameter on a one-line block" do
    expect_offense(<<~RUBY)
      names.map { |e| e.strip }
                      ^ Use the `it` block parameter.
    RUBY

    expect_correction(<<~RUBY)
      names.map { it.strip }
    RUBY
  end

  it "flags a do..end block whose body is one line" do
    expect_offense(<<~RUBY)
      names.each do |e|
        puts e.upcase
             ^ Use the `it` block parameter.
      end
    RUBY
  end

  it "leaves a multi-line body alone" do
    expect_no_offenses(<<~RUBY)
      names.each do |e|
        puts e
        puts e.upcase
      end
    RUBY
  end

  # The outer block keeps its name because an inner `it` would shadow it. The
  # inner block has nothing nested inside it, so it is fair game.
  it "spares the outer block when one is nested, and still flags the inner" do
    expect_offense(<<~RUBY)
      names.map { |e| e.chars.map { |c| c.upcase } }
                                        ^ Use the `it` block parameter.
    RUBY

    expect_correction(<<~RUBY)
      names.map { |e| e.chars.map { it.upcase } }
    RUBY
  end

  it "leaves a block taking two parameters alone" do
    expect_no_offenses(<<~RUBY)
      pairs.each { |k, v| puts k }
    RUBY
  end
end
