#encoding: utf-8

require "sinatra"
require "haml"
require "ap"
require "fileutils"
require "./lib/movfile"

get '/' do
	#hamlテンプレートに飛ばす
	#Fileのアップローダー
	haml :upload_form
end

put '/upload' do
	#ページからアップロードされたファイルは
	#params[:file][:tempfile]にFileオブジェクトとして格納される
	if params[:file]
		ap params #for debug

		#set some valiable for constructor
		file = params[:file][:tempfile]
		file_path = params[:file][:tempfile].path
		filename = params[:file][:filename]
		upload_date = params[:date]

		mov = MOVfile.new(file, filename, upload_date)
		ap mov #for debug
		#FileUtils.cp(file_path, "./") #for debug
		
		@mes = "#{filename} upload completed!!!!!!!!!"
		haml :uploaded
	end
end

__END__
