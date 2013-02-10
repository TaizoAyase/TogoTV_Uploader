#encoding: utf-8

require "fileutils"
require "open3"
require "./lib/nikki_default"
require "net/ssh"
require "net/scp"

class MOVfile
	include Nikki

	#アップロードサーバー
	#@@server = "togotv.dbcls.jp"
	@@server = "192.168.11.9"
	#サーバー上のtogotv公開フォルダ
	# -*- !!!!!!Public folder!!!!!! -*-*
	@@tv_path = "/var/www/togotv"

	def initialize(tmpfile_path, filename, date)
		@tmpfile_path = tmpfile_path
		@filename = filename
		raise ArgumentError, "movファイルしか指定できません" unless @filename =~ /\.mov$/
		rename_tmpfile
		@upload_date = setDate(date.to_s)

		# propertiesで情報を格納するHashをセット
		@params = Hash.new
	end

	#TODO:implement
	def upload!(username, pass)
		scp!(username, pass)
		puts @params
		#setPropaties #TODO:remoteでこれを行うには？
		chmod_remote!
	end

	# output nikki text
	def output
		@nikki = setNikki
	end

	private

	# tempfileを元の名前にrenameする
	def rename_tmpfile
		new_filepath = File.dirname(@tmpfile_path) + "/" + @filename
		File.rename(@tmpfile_path, new_filepath)
		@file_path = new_filepath
	end

	# set @params from system call "ffmpeg"
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

	def setPropaties
		pict_command = "ffmpeg -y -i #{@filename} -f image2 -r 1 -t 0:0:0.001 -an #{@upload_date}_0.jpg"
		stdin, stdout, stderr = Open3.popen3(pict_command)
		info = stderr.read.encode("UTF-8", "Shift_JIS") #出力に日本語が含まれている...
		stdin.close
		stdout.close
		stderr.close

		properties(info)
		setDuration
	end
	
	#TODO:ここで動かない。動くようにする
	def scp!(username, pass)
		@server_path = "/#{@filename}"
		Net::SCP.start(@@server, username, {:password => pass, :compression => true}) do |scp|
			channel = scp.upload!(@file_path, "/")
			channel.wait
		end
	end

	#TODO:テスト未完
	def chmod_remote!(username, pass)
		Net::SSH.start(@@server, username, {:password => pass}) do |ssh|
			puts ssh.exec! "chmod 664 #{@server_path}"
		end
	end

	# setting date
	def setDate(arg_date)
		match_yyyymmdd = arg_date =~ /^\d{8}/ || @filename =~ /^\d{8}/
		match_yymmdd = arg_date =~ /^\d{6}/ || @filename =~ /^\d{6}/
		# match to "yyyymmdd" format -> return self
		if match_yyyymmdd
	    return $&
		# match to "yymmdd" format -> return 20yymmdd
		elsif match_yymmdd
	    return "20" + $&
		else
	    t = Time.now
	    return t.strftime("%Y%m%d")
		end
	end

	#setting duration
	def setDuration
		h, m, s = @params[:time].split(":")
		@duration = h.to_i * 60 * 60 + 
								m.to_i * 60 + 
								s.to_i + 1
	end
end
