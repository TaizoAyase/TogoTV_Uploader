#encoding: utf-8

require 'ap'
require 'yaml'

class FileController
  attr_reader :nikki

  CONFIG = YAML.load_file('./lib/server_config.yaml')[:'-t']

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
    
    # create instance of MOV and thumbnail
    @mov = MOVfile.new(file_path, filename, upload_date)
    thumbnail_path = @mov.create_thumbnail
    @thumbnail = Thumbnail.new(thumbnail_path)
  end

  def upload!
    @mov.upload!(@username, @passwd, CONFIG[:movie_path])
    @thumbnail.upload!(@username, @passwd, CONFIG[:thumbnail_path])
    @nikki = get_nikki
  end

  # get nikki text from MOVfile object
  def get_nikki
    @mov.output
  end
end
