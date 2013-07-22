#encoding: utf-8

require 'ap'

class FileController
  attr_reader :nikki

  def initialize(params)  
    # no file in args raises error
    raise ArgumentError unless params[:file]

    # set some valiables for constructor
    file_path = params[:file][:tempfile].path
    filename = params[:file][:filename]
    upload_date = params[:date]

    # set username/passwd for upload
    @username = params[:togoserver_username]
    @passwd = params[:togoserver_pass]
    
    @mov = MOVfile.new(file_path, filename, upload_date)
    thumbnail_path = @mov.create_thumbnail
    @thumbnail = Thumbnail.new(thumbnail_path)
  end

  def upload!
    @mov.upload!(@username, @passwd)
    @thumbnail.upload!(@username, @passwd)
    @nikki = get_nikki
  end

  private

  # get nikki text from MOVfile object
  def get_nikki
    @mov.output
  end
end
