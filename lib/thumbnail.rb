# coding: utf-8

require './lib/upload_file'

class Thumbnail
  include UploadFile

  def initialize(tmpfile_path)
    @tmpfile = ThumbnailTempFile.new(tmpfile_path)
  end

end
