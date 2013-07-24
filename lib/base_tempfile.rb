# coding: utf-8

require 'ap'
require 'fileutils'

class BaseTempFile
	# some getter methods
	def get_upload_file_path
		@upload_file_path
	end

	def get_file_name
		File.basename(@upload_file_path)
	end

	def get_date
		@upload_date
	end
end
