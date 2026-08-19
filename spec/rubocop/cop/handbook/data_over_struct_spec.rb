require "rubocop"
require "rubocop/rspec/support"
require_relative "../../../../.rubocop/cops/data_over_struct"

RSpec.describe RuboCop::Cop::Handbook::DataOverStruct, :config do
  # rubocop's parser defaults below the project's Ruby, and rejects an endless
  # method whose body is an assignment.
  let(:ruby_version) { 3.4 }

  it "flags Struct.new" do
    expect_offense(<<~RUBY)
      Season = Struct.new(:weekday, :gathers_at)
               ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use Data.define unless this has to mutate.
    RUBY
  end

  it "flags a top-level ::Struct.new" do
    expect_offense(<<~RUBY)
      Point = ::Struct.new(:x, :y)
              ^^^^^^^^^^^^^^^^^^^^ Use Data.define unless this has to mutate.
    RUBY
  end

  it "leaves Data.define alone" do
    expect_no_offenses(<<~RUBY)
      Season = Data.define(:weekday, :gathers_at)
    RUBY
  end

  it "still flags a struct whose block only reads" do
    expect_offense(<<~RUBY)
      Point = Struct.new(:x, :y) do
              ^^^^^^^^^^^^^^^^^^ Use Data.define unless this has to mutate.
        def area = x * y
      end
    RUBY
  end

  it "spares a struct that assigns to a member" do
    expect_no_offenses(<<~RUBY)
      Counter = Struct.new(:count) do
        def rename(value) = (self.count = value)
      end
    RUBY
  end

  it "spares a struct that increments a member" do
    expect_no_offenses(<<~RUBY)
      Counter = Struct.new(:count) do
        def bump = self.count += 1
      end
    RUBY
  end
end
