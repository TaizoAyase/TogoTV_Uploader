#encoding: utf-8

require 'sinatra'
require 'haml'

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

	  controller = FileController.new(params)
	  controller.upload!
    @nikki_text = controller.get_nikki
    haml :uploaded
	end

end

TogoUploaderApp.run!

__END__
