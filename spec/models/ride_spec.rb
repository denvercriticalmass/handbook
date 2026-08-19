require "rails_helper"

RSpec.describe Ride do
  describe "in summer" do
    subject(:ride) { described_class.next(on: Date.new(2026, 7, 1)) }

    it "falls on the last Friday" do
      expect(ride.on).to eq(Date.new(2026, 7, 31))
    end

    it "gathers at half six" do
      expect(ride.gathers_at).to eq("6:30pm")
    end

    it "rolls at seven" do
      expect(ride.rides_at).to eq("7:00pm")
    end
  end

  describe "in winter" do
    subject(:ride) { described_class.next(on: Date.new(2026, 12, 1)) }

    it "moves to the last Sunday" do
      expect(ride.on).to eq(Date.new(2026, 12, 27))
    end

    it "gathers in the afternoon while it is still light" do
      expect(ride.gathers_at).to eq("1:30pm")
    end

    it "knows it is winter" do
      expect(ride).to be_winter
    end
  end

  it "counts April as winter and May as summer" do
    expect([ described_class.next(on: Date.new(2026, 4, 1)).winter?,
             described_class.next(on: Date.new(2026, 5, 1)).winter? ]).to eq([ true, false ])
  end

  it "puts April's ride on the last Sunday now that winter reaches it" do
    expect(described_class.next(on: Date.new(2026, 4, 1)).on).to eq(Date.new(2026, 4, 26))
  end

  it "goes back to Friday evenings in May" do
    expect(described_class.next(on: Date.new(2026, 5, 1)).on).to eq(Date.new(2026, 5, 29))
  end

  it "still points at today's ride on the day itself" do
    expect(described_class.next(on: Date.new(2026, 7, 31)).on).to eq(Date.new(2026, 7, 31))
  end

  it "rolls to next month once this month's ride has passed" do
    expect(described_class.next(on: Date.new(2026, 8, 1)).on).to eq(Date.new(2026, 8, 28))
  end

  it "crosses the year end" do
    expect(described_class.next(on: Date.new(2026, 12, 28)).on).to eq(Date.new(2027, 1, 31))
  end
end
