#encoding: utf-8

require "ap"
require "fileutils"
require './lib/base_tempfile'

class MOVTempFile < BaseTempFile
	def initialize(tempfile_path, filename, date = "")
		@tempfile_path = tempfile_path
		@filename = filename
		raise ArgumentError, "movファイルしか指定できません" unless @filename =~ /\.mov$/
		@upload_date = setDate(date.to_s.gsub(/-/, ""))
		date.to_s.gsub(/-/, "")
		rename_tempfile
	end

	private

	# tempfileを元の名前にrenameする
	def rename_tempfile
		if @filename =~ /^\d{8}/ # match for yyyymmdd
			new_filepath = File.dirname(@tempfile_path) + "/" + @filename
		else
			new_filepath = File.dirname(@tempfile_path) + "/" + @upload_date + @filename
		end
		File.rename(@tempfile_path, new_filepath)
		@upload_file_path = new_filepath
	end

	# setting date
	def setDate(arg_date)
		match_yymmdd = arg_date =~ /^\d{6}/ || @filename =~ /^\d{6}/
		match_yyyymmdd = arg_date =~ /^\d{8}/ || @filename =~ /^\d{8}/
		# match to "yyyymmdd" format -> return yymmdd
		if match_yyyymmdd
	    return $&.sub(/^\d\d/, "")
		# match to "yymmdd" format -> return self
		elsif match_yymmdd
	    return $&
		else
	    t = Time.now
	    return t.strftime("%y%m%d")
		end
	end

end
