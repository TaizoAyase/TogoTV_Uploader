# coding: utf-8

require './lib/upload_file'
require './lib/thumbnail_tempfile'

class Thumbnail
  include UploadFile

  def initialize(tmpfile_path)
    @tempfile = ThumbnailTempFile.new(tmpfile_path)
  end

end
