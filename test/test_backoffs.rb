require 'minitest/autorun'
require File.expand_path(File.dirname(__FILE__) + '/helper')

describe Rhod::Backoffs do
  describe "backoff_sugar_to_enumerator" do
    it "returns enumerators as is" do
      e = Rhod::Backoffs::Constant.new(0)
      Rhod::Backoffs.backoff_sugar_to_enumerator(e).must_equal e
    end

    it "generates constant backoffs from a Numeric" do
      Rhod::Backoffs.backoff_sugar_to_enumerator(2.0).next.must_equal 2.0
      Rhod::Backoffs.backoff_sugar_to_enumerator(5).next.must_equal 5
    end

    it "generates expoential backoffs with '^' syntax" do
      results = []
      eb = Rhod::Backoffs.backoff_sugar_to_enumerator("^2.0")

      3.times { results << eb.next }

      results.must_equal [4.0, 8.0, 16.0]
    end

    it "generates logarithmic backoffs with 'l' syntax" do
      results = []
      lb = Rhod::Backoffs.backoff_sugar_to_enumerator("l2.0")

      3.times { results << lb.next }

      results.must_equal [2.0, 3.169925001442312, 4.0]
    end

    it "generates random backoffs with 'r' syntax" do
      results = []
      rb = Rhod::Backoffs.backoff_sugar_to_enumerator("r1..2")

      10.times { results << rb.next }

      results.min.floor.must_equal 1
      results.max.ceil.must_equal 2
    end

    it "generates expoential backoffs with :^ syntax" do
      results = []
      eb = Rhod::Backoffs.backoff_sugar_to_enumerator(:^)

      3.times { results << eb.next }

      results.must_equal [1.0, 2.0, 4.0]
    end

    it "generates logarithmic backoffs with :l syntax" do
      results = []
      lb = Rhod::Backoffs.backoff_sugar_to_enumerator(:l)

      3.times { results << lb.next }

      results.must_equal [0.7570232465074598, 2.403267722339301, 3.444932048942182]
    end

    it "generates random backoffs with :r syntax" do
      results = []
      rb = Rhod::Backoffs.backoff_sugar_to_enumerator(:r)

      100.times { results << rb.next }

      results.min.floor.must_equal 0
      results.max.ceil.must_equal 10
    end
  end
end
