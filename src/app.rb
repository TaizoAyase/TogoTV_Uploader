#encoding: utf-8

require "sinatra"
require "sinatra/base"

class App < Sinatra::Base
	enable :inline_templates
	#enable :logging

	get '/' do
		@title = "Top"
		haml "My Way"
	end

	get '/name/:name' do
		@name = params[:name]
		@title = "Song for #{@name}"
		haml "#{@name}'s Way"
	end
end

App.run!

__END__

@@layout
!!! 5
%html
 %head
  %title=@title
 %body
  %h1=@title
  %div=yield
