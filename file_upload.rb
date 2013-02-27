#encoding: utf-8

require "sinatra"
require "haml"
require "ap"

require "./lib/movfile.rb"

# set tempfile directory
ENV['TMPDIR'] = "./tmp/"
@mes = ""

get '/' do
	# hamlテンプレートに飛ばす
	# Fileのアップローダー
	haml :upload_form
end

post '/upload' do
	#ページからアップロードされたファイルは
	# params[:file][:tempfile]にFileオブジェクトとして格納される
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
			redirect "/"
		end
		
		@mes = "Upload completed!"
		haml :uploaded
	else
		@mes = "MOVファイルを指定してください"
		redirect "/"
	end
end

__END__
