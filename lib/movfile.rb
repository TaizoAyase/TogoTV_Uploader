#encoding: utf-8

require "fileutils"
require "open3"
require "net/ssh"
require "net/scp"
require "yaml"

require "./lib/nikki_default"
require "./lib/mov_tempfile"
require "./lib/upload_file"

class MOVfile
	include Nikki
	include UploadFile

	def initialize(tempfile_path, filename, date)
		@tempfile = MOVTempFile.new(tempfile_path, filename, date)
		@filename = @tempfile.get_file_name
		@date = @tempfile.get_date
		# propertiesで情報を格納するHashをセット
		@params = Hash.new
	end

	def upload!(username, pass)
		scp!(username, pass)
		chmod_remote!(username, pass) #TODO:is this method nessessary???
		setPropaties # set @params hash
		put_to_public(username, pass)
	end

	# output nikki text
	def output
		@nikki = setNikki
	end

	private :scp!, :chmod_remote!
	private

	# call ffmpeg command
	def setPropaties
		pict_command = "ffmpeg -y -i ./tmp/#{@filename} -f image2 -r 1 -t 0:0:0.001 -an ./tmp/20#{@date}_0.jpg"
		stdin, stdout, stderr = Open3.popen3(pict_command)
		info = stderr.read.encode("UTF-8", "Shift_JIS")
		stdin.close
		stdout.close
		stderr.close

		properties(info)
		setDuration
	end
	
	# call ffmpeg command in remote server
	#def setPropaties_remote!(username, pass)
		#Net::SSH.start(CONFIG[:server], username, {:password => pass}) do |ssh|
			#ssh.exec! 
		#end
	#end

	# 公開用フォルダに移動
	def put_to_public(username, pass)
		# MOVのfilenameの拡張子をstreamingに変換したStringを生成
		@streaming_filename = @filename.sub(/\.mov/, ".streaming")

		Net::SSH.start(CONFIG[:server], username, {:password => pass}) do |ssh|
			# .streamingに.movからシンボリックリンクを作製
			streaming_path = CONFIG[:server_path] + @streaming_filename
			ssh.exec! "ln -s #{CONFIG[:server_path] + @filename} #{streaming_path}"
			# movを移動
			ssh.exec! "mv #{CONFIG[:server_path] + @filename} #{CONFIG[:tv_path]}/movie/"
			# streamingを移動
			ssh.exec! "mv -i #{CONFIG[:server_path] + @streaming_filename} #{CONFIG[:tv_path]}/movie/"
		end

		# サムネイルを移動
		Net::SCP.start(CONFIG[:server], username, {:password => pass, :compression => true}) do |scp|
			channel = scp.upload("./tmp/20#{@date}_0.jpg", "#{CONFIG[:tv_path]}/images/")
			channel.wait
		end
	end

	# setting date
	def setDate(arg_date)
		match_yyyymmdd = arg_date =~ /^\d{8}/ || @filename =~ /^\d{8}/
		match_yymmdd = arg_date =~ /^\d{6}/ || @filename =~ /^\d{6}/
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

	#setting duration
	def setDuration
		h, m, s = @params[:time].split(":")
		@duration = h.to_i * 60 * 60 + 
								m.to_i * 60 + 
								s.to_i + 1
	end

	# set @params
	def properties(info)
	  info = info.split("\n")
	  info.each do |line|
	    if line =~ /Duration:/
	      time, start, bitrate = line.chomp.split(", ")
	      _, @params[:time]    = time.split(": ")
	      _, @params[:start]   = start.split(": ")
  	    _, bitrate           = bitrate.split(": ")
    	  @params[:bitrate],   = bitrate.split("\s")

			elsif line =~ /Stream .+ Audio: /
	      _, arate, _ = line.split(", ")
	      @params[:arate] = arate.sub(/\sHz/, "")

	    elsif line =~ /Stream .+ Video: /
	      _, _, video     = line.chomp.split(": ")
	      video           = video.split(", ")
	      @params[:codec]  = video[0]
	      @params[:yuv]    = video[1]
	      size,           = video[2].split("\s")
	      @params[:width], @params[:height] = size.split("x")
	      @params[:frate], = video[3].split("\s")
  	  elsif line =~ /^Output/
    	  break
	    end
	  end
		return nil
	end
end
