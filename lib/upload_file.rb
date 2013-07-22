#encoding: utf-8

require 'ap'
require 'net/scp'
require 'net/ssh'
require './lib/mov_tempfile'
require 'yaml'

# module for MOV class & Streaming file
module UploadFile

	# set some configuration for server
	CONFIG = YAML.load_file('./lib/server_config.yaml')[:'-t']
  SERVER = CONFIG[:server]
  MOVIE_PATH = CONFIG[:movie_path]
  THUMBNAIL_PATH = CONFIG[:thumbnail_path]

	def upload!(username, pass, to)
		scp!(username, pass, to)
		#put_to_public(username, pass)
	end

  private

	# TogoTV serverにSCP
  # @tempfile < BaseTempFileオブジェクトのget_upload_file_pathを使う
	def scp!(username, pass, dir_to)
    # get_upload_file_pathに応答しない場合はRunTimeError
    # TODO:BUG...RuntimeError here
    raise "Runtime Error in UploadFile module" unless @tempfile.respond_to? :get_upload_file_path

		Net::SCP.start(SERVER, username, {:password => pass, :compression => true}) do |scp|
			channel = scp.upload(@tempfile.get_upload_file_path, dir_to)
			channel.wait
		end
	end

	# chmod 644 on TogoTV server
	def chmod_remote!(username, pass)
		Net::SSH.start(SERVER, username, {:password => pass}) do |ssh|
			ssh.exec! "chmod 644 #{CONFIG[:server_path] + @filename}"
		end
	end

	# 公開用フォルダに移動
	def put_to_public(username, pass)
		# MOVのfilenameの拡張子をstreamingに変換したStringを生成
		@streaming_filename = @filename.sub(/\.mov/, '.streaming')

		Net::SSH.start(SERVER, username, {:password => pass}) do |ssh|
			# .streamingに.movからシンボリックリンクを作製
			streaming_path = CONFIG[:server_path] + @streaming_filename
      com = "ln -s #{CONFIG[:server_path] + @filename} #{streaming_path}"
			ssh.exec! com

			# movを移動
			#ssh.exec! "mv #{CONFIG[:server_path] + @filename} #{CONFIG[:tv_path]}/movie/"
			# streamingを移動
			#ssh.exec! "mv -i #{CONFIG[:server_path] + @streaming_filename} #{CONFIG[:tv_path]}/movie/"
		end

		# サムネイルを移動
		Net::SCP.start(SERVER, username, {:password => pass, :compression => true}) do |scp|
      thumbnail_path = "#{CONFIG[:tv_path]}/images/"
			channel = scp.upload("./tmp/20#{@date}_0.jpg", thumbnail_path)
			channel.wait
		end
	end


end
