require "cop_helper"

RSpec.describe RuboCop::Cop::Handbook::PreferData, :config do
  # rubocop's parser defaults below the project's Ruby, and rejects an endless
  # method whose body is an assignment.
  let(:ruby_version) { 3.4 }

  describe "Struct.new" do
    it "is flagged" do
      expect_offense(<<~RUBY)
        Season = Struct.new(:weekday, :gathers_at)
                 ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use Data.define unless this has to mutate.
      RUBY
    end

    it "is flagged at the top level too" do
      expect_offense(<<~RUBY)
        Point = ::Struct.new(:x, :y)
                ^^^^^^^^^^^^^^^^^^^^ Use Data.define unless this has to mutate.
      RUBY
    end

    it "is still flagged when its block only reads" do
      expect_offense(<<~RUBY)
        Point = Struct.new(:x, :y) do
                ^^^^^^^^^^^^^^^^^^ Use Data.define unless this has to mutate.
          def area = x * y
        end
      RUBY
    end

    it "is spared when the block assigns to a member" do
      expect_no_offenses(<<~RUBY)
        Counter = Struct.new(:count) do
          def rename(value) = (self.count = value)
        end
      RUBY
    end

    it "is spared when the block increments a member" do
      expect_no_offenses(<<~RUBY)
        Counter = Struct.new(:count) do
          def bump = self.count += 1
        end
      RUBY
    end
  end

  describe "a frozen hash constant" do
    it "is flagged when it holds literal fields" do
      expect_offense(<<~RUBY)
        WINTER = { weekday: :sunday, gathers_at: "1:30pm" }.freeze
                 ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use Data.define for a record with named fields.
      RUBY
    end

    it "is spared when a value is not a literal, since that is usually an options bag" do
      expect_no_offenses(<<~RUBY)
        OPTIONS = { timeout: 30, browser: ENV["CI"] ? {} : nil }.freeze
      RUBY
    end

    it "is spared with a single pair" do
      expect_no_offenses(<<~RUBY)
        ONLY = { one: :thing }.freeze
      RUBY
    end

    it "is spared when not frozen" do
      expect_no_offenses(<<~RUBY)
        MUTABLE = { a: 1, b: 2 }
      RUBY
    end
  end

  it "leaves Data.define alone" do
    expect_no_offenses(<<~RUBY)
      Season = Data.define(:weekday, :gathers_at)
    RUBY
  end
end
