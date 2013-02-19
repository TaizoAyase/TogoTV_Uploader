#encoding: utf-8

require "./lib/TempFile"
require "ap"
require "test/unit"
require "fileutils"

class TempFileTest < Test::Unit::TestCase
	def test_initialize_no_file
		assert_raise ArgumentError do
			TempFile.new(nil, "hoge", 121212)
		end
	end

	def test_initialize_tempfile
		FileUtils.cp("test_file.mov", "./tmp/")
		date = 121212
		tmp = TempFile.new("./tmp/test_file.mov", "test_file.mov", date)
		exp_file_path = "./tmp/#{"20" + date.to_s}test_file.mov"
		assert_equal exp_file_path, tmp.get_upload_file_path
	end

end
