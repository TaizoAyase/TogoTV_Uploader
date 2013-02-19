#encoding: utf-8

require "test/unit"
require "ap"
require "./lib/movfile"

@movfile = "../test_file.mov"

class MOVfileTest < Test::Unit::TestCase
	def test_initialize_no_file
		assert_raise ArgumentError do
			mov = MOVfile.new(nil, "piyo", 121223)
		end
	end

	def test_initialize_not_mov_file
		assert_raise ArgumentError do
			mov = MOVfile.new("~/hoge.txt", "piyo", 121212)
		end
	end
end
