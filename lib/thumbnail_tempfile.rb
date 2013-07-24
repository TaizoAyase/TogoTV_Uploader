# coding: utf-8

require './lib/base_tempfile'

class ThumbnailTempFile < BaseTempFile
  def initialize(tempfile_path)
    @tempfile_path = tempfile_path
    @upload_file_path = @tempfile_path
  end
end
