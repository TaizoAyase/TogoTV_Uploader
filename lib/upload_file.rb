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

	def upload!(username, pass, to)
		scp!(username, pass, to)
	end

  private

	# TogoTV serverにSCP
  # @tempfile < BaseTempFileオブジェクトのget_upload_file_pathを使う
	def scp!(username, pass, dir_to)
    # get_upload_file_pathに応答しない場合はRunTimeError
    raise "Runtime Error in UploadFile module" unless @tempfile.respond_to? :get_upload_file_path

		Net::SCP.start(SERVER, username, {:password => pass, :compression => true}) do |scp|
			channel = scp.upload(@tempfile.get_upload_file_path, dir_to)
			channel.wait
		end
	end

  # universal method for executing the command in SSH
  def ssh_command(com, username, pass)
    Net::SSH.start(SERVER, username, {:password => pass}) do |ssh|
      ssh.exec! com
    end
  end

	# chmod 644 on TogoTV server
	def chmod_remote!(username, pass)
    com = "chmod 644 #{CONFIG[:server_path] + @filename}"
    ssh_command(com, username, pass)
	end

end
