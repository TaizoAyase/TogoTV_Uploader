#encoding: utf-8

require "sinatra"
require "haml"
require "ap"
require "fileutils"
require "./movfile"

get '/' do
	#hamlテンプレートに飛ばす
	#Fileのアップローダー
	haml :index
end

put '/upload' do
	#ページからアップロードされたファイルは
	#params[:file][:tempfile]にFileオブジェクトとして格納される
	if params[:file]
		ap params #for debug
		file = params[:file][:tempfile]
		file_path = params[:file][:tempfile].path
		filename = params[:file][:filename]
		upload_date = params[:date] if params[:date]
		mov = MOVfile.new(file, filename, upload_date)
		#FileUtils.cp(file_path, "./") #for debug
		@mes = "#{filename} upload completed!!!!!!!!!"
		haml :upload
	end
end

#TODO:HAML templateの外部ファイルへの移行
__END__
@@index
%html
	%head
		%title TogoTV Upload Page
	%body
		%p= "Welcome to TogoTV upload page!"
		%form{:action => "/upload", :method => "POST", :enctype => "multipart/form-data"}
			%p
				%label{:for => "file"} MOVファイルを選択:
				%input{:type => "file", :name => "file"}
			%p
				%label{:for => "text"} Uploadする日付を選択(yymmdd形式で):
				%input{:type => "text", :name => "date"}
			%p
				%label{:for => "togoserver_pass"} password:
				%input{:type => "password", :name => "togoserver_pass"}
			%p
				%input{:type => "submit", :value => "upload"}
				%input{:type => "hidden", :name => "_method", :value => "put"}

@@upload
%html
	%head
		%title Uploaded
	%body
		%p= @mes
