#encoding: utf-8

require 'ap'

class FileControler
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
    @mov.create_thumbnail
    @thumbnail = Thumbnail.new()
  end

  def upload!
    @mov.upload!(@username, @passwd)
    @thumbnail.upload!(@username, @passwd)
  end
end
