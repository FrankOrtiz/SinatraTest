require 'sinatra'
require 'pp'

enable :sessions

def check
	session[:stamina] ||= 10
	session[:gold] ||= 0
	session[:gold_owed] ||= 0
	session[:drinks] ||= 0
	session[:drunk] ||= 0
	session[:current_location] ||= :home
end
# show the current state
get "/" do 
	session[:current_location] ||= :home

	h = "<html><head><link rel='stylesheet' href='game.css' /></head><body class='#{session[:current_location]}'>"
	h += "<form action='/home' method='post'><input type='submit' value='Restart Drunken Adventure' /></form>"
	h += "<p>You are currently at: #{session[:current_location]}</p>"
	h += "<p><strong>You've had:</strong> #{session[:drinks]} drinks</p>"
	h += "<p><strong>You owe the tavern:</strong> #{session[:gold_owed]} gp"
	h += "<p><strong>Gold:</strong> #{session[:gold]}</p>"
	h += "<p><strong>Stamina:</strong> #{session[:stamina]}</p>"
	h += "<p><strong>Drunken level</strong> #{session[:drunk]}</p>"


	case session[:current_location]
	when :home
		check
		h += "<form action='/town' method='post'><input type='submit' value='Start Drunken Adventure' /></form>"
	when :town
		check
		h += "<form action='/tavern' method='post'><input type='submit' value='Go to local tavern' /></form>"
		h += "<form action='/field' method='post'><input type='submit' value='Go to the field' /></form>"
	when :field
		check
		h += "<form action='/field/explore' method='post'><input type='submit' value='Explore field' /></form>"
		h += "<form action='/search/gold' method='post'><input type='submit' value='Search for gold' /></form>"
		h += "<form action='/town' method='post'><input type='submit' value='Head back to town' /></form>"
	when :tavern
		check
		h += "<form action='/tavern/drink' method='post'><input type='submit' value='Buy a drink (3 gp)' /></form>"
		h += "<form action='/town' method='post'><input type='submit' value='Head back outside' /></form>"
		h += "<form action='/tavern/rest' method='post'><input type='submit' value='Rest for the night (5 gp)' /></form>"
		if session[:gold_owed] > session[:gold]
			h += "<form action='/pay/dept' method='post'><input type='submit' value='Pay off dept (#{session[:gold]} gp)' /></form>"
		else 
			h += "<form action='/pay/dept' method='post'><input type='submit' value='Pay off dept (#{session[:gold_owed]} gp)' /></form>"
		end
	else 
		h += "<form action='/town' method='post'><input type='submit' value='Start' /></form>"
	end
# 

	# h += "<p><strong>Your total gold lost</strong> #{session[:gold_lost]}</p>"
	h += "<p><strong>>>></strong> #{session[:explore]}</p>"
	#------------------------------------------------------------#
	# h += "<h1>session</h1>"
	# session.each do |k, v|
	# 	h += "<p><strong>#{k}</strong>: #{v.pretty_inspect}</p>"
	# end
	#------------------------------------------------------------#

	h += '</body></html>'

	h
	
end

post "/home" do
	session[:current_location] = :home
	session[:stamina] = 10
	session[:gold] = 0
	session[:gold_owed] = 0
	session[:drinks] = 0
	session[:drunk] = 0
	redirect to '/'
end
post "/self/stamina" do
	session[:stamina] ||= 10
	redirect to'/'
end

post "/town" do
	session[:current_location] = :town
	redirect to '/'
end

post "/tavern" do
	session[:current_location] = :tavern
	redirect to '/'
end

post "/gold/owed" do
	session[:gold_owed] ||=0
	redirect to '/'
end


post "/pay/dept" do
	if session[:gold_owed] >= session[:gold] # If user dept is equal to or higher than what user can pay
		session[:gold_owed] -= session[:gold] # Subtract total user gold from user dept
		session[:gold] -= session[:gold] # Subtract gold used to pay off dept
	else
		session[:gold_owed] < session[:gold] # If user dept is lower than user gold
		session[:gold] -= session[:gold_owed] # Subtract user dept from user gold
		session[:gold_owed] -= session[:gold_owed] # Subtract all dept
	end
	redirect to '/'
end

post "/tavern/drink" do
	if session[:gold] < 3
		redirect '/'
	end
	session[:gold] -= 3
	session[:drinks] ||= 0
	session[:drinks] += 1
	session[:drunk] ||= 0
	session[:drunk] += 1
	session[:stamina] ||= 10
	if session[:stamina] < 10
		session[:stamina] += 1
	end
	# session[:wasted] += 1
	redirect to '/'
end

post "/tavern/rest" do
	if session[:gold] < 5
		redirect '/'
	else
		session[:gold] -= 5
		session[:drunk] = 0
		session[:stamina] = 10
		redirect to '/'
	end
end

# def ithappened
# 	session[:passedout] = "<p><strong>>>></strong>You have passed out!/n 
# 	>>>You've lost all your gold despite your efforts to fight off pirates/n
# 	>>>Even in a drunken rage you stood no chance/n
# 	>>>You've lost all your gold!!</p>"
# end

get "/self/passedout" do
	session[:passedout] ||= 0
	session[:stamina] = 10
	session[:gold] = 0
	session[:drunk] = 0
	session[:gold_owed] ||= 0
	session[:gold_owed] += 5
	if session[:gold_owed] >= 50
		session[:explore] = "<body>You have reached a dept of 50 gold! The tavern owner has decided to kill you...</body>"
		session[:drinks] = 0
		session[:gold_owed] = 0
		exert
	end
	redirect to '/'

end

post "/search/gold" do
	session[:gold] ||= 0
	session[:gold] += 1
	exert
	redirect to '/'
end

post "/field" do
	session[:current_location] = :field
	redirect to '/'
end

post "/self/drunk" do
	session[:drunk] ||= 0
	redirect to '/'
end

def exert
	session[:stamina] ||=10

	if session[:stamina] > 1
		session[:stamina] -= 1
	else
		redirect to '/self/passedout'
	end
end

def explore_field(eventnumber)
	# eventnumber -= session[:wasted]
	if eventnumber > 94 # 5% chance
		robbed_amount = session[:gold] / 3
		session[:gold] -= robbed_amount
		session[:explore] = "<body>You've been robbed!! You lost #{robbed_amount} gp.</body>"
		if session[:drunk] > 10
			session[:stamina] = 0
		end
		# session[:wasted] = 0
	elsif eventnumber < 84 # 85% chance
		session[:explore] = "<body>You encounter nothing.</body>"
	else  # 10% chance
		found ||= 1 + rand(5)
		session[:explore] = "<body>You found #{found} gp!</body>"
		session[:gold] += found
	end
end

post "/field/explore" do
	session[:stamina] ||= 10
	event = 1 + rand(100) + session[:drunk] * 2
	explore_field(event)
	session[:explore]
	exert
	redirect to '/'
end
