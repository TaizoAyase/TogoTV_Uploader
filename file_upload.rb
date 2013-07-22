#encoding: utf-8

require 'sinatra'
require 'haml'
require 'ap'

require './lib/movfile.rb'
require './lib/file_controller'

# set tempfile directory
ENV['TMPDIR'] = './tmp/'

class TogoUploaderApp < Sinatra::Base

  configure do
    enable :sessions
  end

	get '/' do
		# hamlテンプレートに飛ばす
		# Fileのアップローダー
    @mes = session.has_key?(:message) ? session[:message] : ''
		haml :upload_form
	end

	post '/upload' do
		#ページからアップロードされたファイルは
		# params[:file][:tempfile]にFileオブジェクトとして格納される

	  unless params[:file]
			@mes = 'MOVファイルを指定してください'
	l		redirect '/'
	  end
	  
	  begin
	    controller = FileController.new(params)
	    controller.upload!
	    #@nikki_text
	  rescue Exception => e
	    ap e
	    puts e.message
      session[:message] = e.message
	    redirect '/'
	  end
	    
=begin
	### former version that do not use file controller
		if params[:file]
			# set some valiables for constructor
			file_path = params[:file][:tempfile].path
			filename = params[:file][:filename]
			upload_date = params[:date]
			username = params[:togoserver_username]
			passwd = params[:togoserver_pass]

			begin
				mov = MOVfile.new(file_path, filename, upload_date)
				mov.upload!(username, passwd)
				@nikki_text = mov.output
			rescue ArgumentError => e
				puts e.message
				@mes = e.message
				redirect '/'
			end
			
			@mes = 'Upload completed!'
			haml :uploaded
		else
			@mes = 'MOVファイルを指定してください'
			redirect '/'
		end
=end
	end
end

TogoUploaderApp.run!

__END__
