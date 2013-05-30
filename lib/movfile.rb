#encoding: utf-8

require 'fileutils'
require 'open3'
require 'net/ssh'
require 'net/scp'
require 'yaml'

require './lib/nikki_default'
require './lib/mov_tempfile'
require './lib/upload_file'
require './lib/thumbnail'

class MOVfile
	include Nikki
	include UploadFile

	def initialize(tempfile_path, filename, date)
		@tempfile = MOVTempFile.new(tempfile_path, filename, date)
		@filename = @tempfile.get_file_name
		@date = @tempfile.get_date
		# parse_propertiesで情報を格納するHashをセット
		@params = Hash.new
	end

  def create_thumbnail
    setPropaties
    # return path for thumbnail
    "./tmp/20#{@date}_0.jpg" 
  end

	# output nikki text
	def output
		setNikki
	end

	private

	def setPropaties
    info = call_ffmpeg
		parse_properties(info)
		setDuration
    @params
	end
	
	# call ffmpeg command
  def call_ffmpeg
   	pict_command = "ffmpeg -y -i ./tmp/#{@filename} -f image2 -r 1 -t 0:0:0.001 -an ./tmp/20#{@date}_0.jpg"
    stdin, stdout, stderr = Open3.popen3(pict_command)
    info = stderr.read.encode('UTF-8', 'Shift_JIS')
    stdin.close; stdout.close; stderr.close
    info
  end

	# setting date
	def setDate(arg_date)
		match_yyyymmdd = arg_date =~ /^\d{8}/ || @filename =~ /^\d{8}/
		match_yymmdd = arg_date =~ /^\d{6}/ || @filename =~ /^\d{6}/
		# match to 'yyyymmdd' format -> return yymmdd
		if match_yyyymmdd
	    return $&.sub(/^\d\d/, '')
		# match to 'yymmdd' format -> return self
		elsif match_yymmdd
	    return $&
		else
	    t = Time.now
	    return t.strftime("%y%m%d")
		end
	end

	#setting duration
	def setDuration
		h, m, s = @params[:time].split(':')
		@duration = h.to_i * 60 * 60 + 
								m.to_i * 60 + 
								s.to_i + 1
	end

	# set @params
	def parse_properties(info)
	  info = info.split("\n")
	  info.each do |line|
	    if line =~ /Duration:/
	      time, start, bitrate = line.chomp.split(', ')
	      _, @params[:time]    = time.split(': ')
	      _, @params[:start]   = start.split(': ')
  	    _, bitrate           = bitrate.split(': ')
    	  @params[:bitrate],   = bitrate.split("\s")

			elsif line =~ /Stream .+ Audio: /
	      _, arate, _ = line.split(', ')
	      @params[:arate] = arate.sub(/\sHz/, '')

	    elsif line =~ /Stream .+ Video: /
	      _, _, video     = line.chomp.split(': ')
	      video           = video.split(', ')
	      @params[:codec]  = video[0]
	      @params[:yuv]    = video[1]
	      size,           = video[2].split("\s")
	      @params[:width], @params[:height] = size.split('x')
	      @params[:frate], = video[3].split("\s")
  	  elsif line =~ /^Output/
    	  break
	    end
	  end
		return nil
	end
end
