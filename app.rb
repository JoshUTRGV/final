require "sinatra"
require 'sinatra/flash'
require_relative "authentication.rb"
# require_relative "item.rb"
# require_relative "transaction.rb"


# authenticate! will make sure that the user is signed in, if they are not they will be redirected to the login page
# if the user is signed in, current_user will refer to the signed in user object.
# if they are not signed in, current_user will be nil

get "/" do
	erb :index
end

get "/dashboard" do
	authenticate!
	erb :dashboard
end

################################################### Creation, Deletion, Update
# //////////// POST CREATE
# DISPLAYS ALL ITEMSS
get "/items" do
	@items = Item.all
	erb :"posts/posts"
end

get "/posts/my_posts" do
	@item = Item.select{ |thing| thing.owner_id == current_user }
	erb :"posts/posts"
end

# If Reloaded Redirect to the Create page
get "/item/create" do
	authenticate!
	erb :"posts/post_create"
end

# Create Item
post "/item/create" do
    i = Item.new
	i.name = params[:name]
	i.description = params[:descripiton]
	i.cost_Day = params[:cost_per_day]
	i.cost_Week = params[:cost_per_week]

	i.owner_id = current_user.id
	i.available = true

	i.save

	@cur_user = User.find { current_user }
	@cur_user.rented_out = i.id

	redirect "/dashboard"
end

# //////////// POST UPDATE
# If Reloaded Redirect to the Update page
# Update the thing
get "/post/update/:id" do
	if current_user.id == Item.get(params[:id]).owner_id ################## MAKE SURE ONLY THE OWNER CAN DO THIS
		@item =  Item.get(params[:id])
		erb :"/posts/posts_update"
	else
		redirect "/"
	end
end

# Update the thing
post "/post/update/:id" do
    @item = Item.get(params[:id])
	@item.name = params[:name]
	@item.description = params[:description]
	@item.save
	redirect "/items"
end

# //////////// POST DELETION
# delete individual items by id
post '/remove/:id' do
	if current_user.id == Item.get(params[:id]).owner_id ################## MAKE SURE ONLY THE OWNER CAN DO THIS
 		Item.get(params[:id]).destroy
		redirect "/dashboard"
	else
		redirect "/"
	end
end

# ////////////////////////////////////////////// PROFILE UPDATE
# If Reloaded Redirect to the User Update Page
get "/profile/update/:id" do
	if current_user == User.get(params[:id]) ################## MAKE SURE ONLY THE OWNER CAN DO THIS
		@profile = current_user
		erb :"user/profile_update"
	else
		redirect "/"
	end
end

post "/profile/update/:id" do
    @profile = current_user
	@profile.first_name = params[:first_name]
	@profile.last_name = params[:last_name]
	@profile.save
	redirect "/dashboard"
end

# //////////////////////////////////////////////
get "/become_pro" do
	authenticate!
	erb :"payment/become_pro"
end

post "/become_pro" do
	current_user.pro = true
	current_user.save
	redirect "/"
end

################################################### POSTS && VIEWS
# Search Bar Item
post "/search" do
	# @item = Item.select { |thing| thing.name.include? params[:search].to_s }
	@item = Item.all? { |e| e.name.include? params[:search] }
	erb :"posts/posts"
end

post "/rent_out/:id" do
	authenticate!
	if Transaction.find { |e| e.item_id == params[:id] } == false # NOT WORKING
		@t = Transaction.new
		@t.renters_id = current_user
		@t.item_id = params[:id]
		@t.owner_id = Item.get(params[:id]).owner_id
		@t.renter_confirmation = 1
		@t.save

		# notify owner
		@L = Messege.new
		@L.to_id = @t.owner_id
		@L.statment = "Someone wants what your renting"
		@L.save

		@K = Messege.new
		@K.to_id = @t.renters_id
		@K.statment = "Someone wants what your renting"
		@K.save

		redirect "/dashboard"
	else
		redirect "/"
	end
end

post "/rent_confirm/:id" do
	authenticate!
	@t = Transaction.select{ |e| e.item_id == params[:id] }

	if Transaction.find { |e| e.item_id == params[:id] } == nil # NOT WORKING
		if @t.owner_id == current_user
			if @t.owner_confirmation == 0 #the owner is agreeing to rent it out to the renter
				@t.owner_confirmation = 1
				@t.save

				@i = Item.select {|e| e.id == @t.item_id}

				# notify the renter
				@M = Messege.new
				@M.to_id = @t.renters_id
				@M.statment = "The owner has agreed to your request, Confirm you gain possesion of the the item"
				@M.save

				redirect "/dashboard"
			elsif @t.owner_confirmation == 2 #owner comfirms return of item
				@dt = time1.inspect - @t.DateTime

		 		#CHARGE THIS MANY DAYS
		 		@days = @td.days + @td.month*30
		 		# @itm = Item.select {|e| e.id == @t.item_id}
		 		# @charge = @itm.cost_day * @days
		 		# @HiC = @charge * 0.05 ### if pro charge less
		 		# @LoC = @charge * 0.07 ### if not pro charge more
		 		#
		 		# check if owner is pro,
		 		# => if pro pay @charge - @LoC
		 		#else
		 		# => pay @charge - @HiC
		 		#
		 		# check if renter is pro,
		 		# => if pro charge @charge + @LoC
		 		#else
		 		# => charge @charge + @HiC

		 		@t.destroy

				@M = Messege.new
				@M.to_id = @t.renters_id
				@M.statment = "Thank-you for renting with us, you wher charged (price)"
				@M.save

				@M = Messege.new
				@M.to_id = @t.owner_id
				@M.statment = "Thank-you for renting with us, you where payed (price)"
				@M.save

				redirect "/dashboard"

			end
		elsif current_user == @t.renter_id
			if @t.renter_confirmation == 1# The renter is confirming his possetion of the item
				@t.owner_confirmation = 2
				@t.renter_confirmation = 2

				@t.created_at = DateTime
				@t.renter_confirmation = 2
				@t.owner_confirmation = 2

				@t.save
				redirect "/dashboard"
			end
		end
	else
		redirect "/"
	end
end

get "/mess&alerts" do
	@messeges = Messege.select{ |mess| mess.to_id == current_user.id }
	erb :"messages/messeges"
end
