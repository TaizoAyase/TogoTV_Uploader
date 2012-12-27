#encoding: utf-8

require "ap"
require "sinatra"
require "haml"

before do
	content_type = :txt
	@default = {rock: :scissors, paper: :rock, scissors: :paper}
	@throws = @default.keys
end

get '/throw/:type' do
	player_throw = params[:type].to_sym

	if !@throws.include?(player_throw)
		halt 403, "You must throw one of the following: #{@throws}"
	end

	computer_throw = @throws.sample

	if player_throw == computer_throw
		"You tied with the computer. Try again!"
	elsif computer_throw == @default[player_throw]
		"Nicely done; #{player_throw} beats #{computer_throw}!"
	else
		"Ouch; #{computer_throw} beats #{player_throw}. Better luck next time!"
	end
end
