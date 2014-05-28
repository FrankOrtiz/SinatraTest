require 'sinatra'
require 'pp'

enable :sessions

# show the current state
get "/" do 
	h = "<html><head><link rel='stylesheet' href='game.css' /></head><body class='#{session[:where_i_am]}'>"
	h += "<p>You are currently at: #{session[:where_i_am]}</p>"

	case session[:where_i_am]
	when :field
		h += "<form action='/atm/rob' method='post'><input type='submit' value='rob the ATMd' /></form>"
		h += "<form action='/tavern' method='post'><input type='submit' value='go to tavern' /></form>"
	when :tavern
		h += "<form action='/tavern/drink' method='post'><input type='submit' value='buy a drink (95 gp)' /></form>"
		h += "<form action='/field' method='post'><input type='submit' value='go to field' /></form>"
	end

	h += "<h1>session</h1>"
	session.each do |k, v|
		h += "<p><strong>#{k}</strong>: #{v.pretty_inspect}</p>"
	end

	h += '</body></html>'

	h
	
end

post "/tavern" do
	session[:where_i_am] = :tavern
	redirect to '/'
end

post "/tavern/drink" do
	session[:gold] -= 95
	session[:drinks] ||= 0
	session[:drinks] += 1
	redirect to '/'
end

post "/atm/rob" do
	session[:gold] ||= 0
	session[:gold] += 5000
	redirect to '/'
end

post "/field" do
	session[:where_i_am] = :field
	redirect to '/'
end

