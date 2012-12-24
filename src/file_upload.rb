#encoding: utf-8

require "sinatra"
require "haml"
require "ap"
require "fileutils"

get '/' do
	#hamlテンプレートに飛ばす
	#Fileのアップローダー
	haml :index
end

put '/upload' do
	#ページからアップロードされたファイルは
	#params[:file][:tempfile]にFileオブジェクトとして格納される
	if params[:file]
		ap params #params[:file][:tempfile]はFileオブジェクト
		ap params[:file]
		ap params[:file][:tempfile].class
		ap str = params[:file][:tempfile].path
		FileUtils.cp(str, "./")
		names = params[:file][:filename]
		@mes = "#{names} upload completed!!!!!!!!!"
		haml :upload
	end
end

__END__
@@index
%html
	%head
		%title TogoTV Upload Page
	%body
		%p= "Welcome to TogoTV upload page!"
		%form{:action => '/upload', :method => 'POST', :enctype => 'multipart/form-data'}
			%p
				%label{:for => "file"} MOVファイルを選択:
				%input{:type => 'file', :name => 'file'}
			%p
				%input{:type => 'submit', :value => 'upload'}
				%input{:type => 'hidden', :name => '_method', :value => 'put'}

@@upload
%html
	%head
		%title Uploaded
	%body
		%p= @mes
