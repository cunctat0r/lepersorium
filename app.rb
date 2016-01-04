#encoding: utf-8
require 'rubygems'
require 'sinatra'
require 'sinatra/reloader'
require 'sqlite3'

def init_db
	@db = SQLite3::Database.new 'lepersorium.db'
	@db.results_as_hash = true
end

before do
	init_db
end

configure do
	init_db
	@db.execute 'create table if not exists Posts 
	(
		id INTEGER PRIMARY KEY AUTOINCREMENT, 
		created_date DATE, 
		content TEXT,
		author TEXT
	)'
	@db.execute 'create table if not exists Comments 
	(
		id INTEGER PRIMARY KEY AUTOINCREMENT, 
		created_date DATE, 
		content TEXT,
		post_id INTEGER,
		author TEXT	
	)'
end


get '/' do
	# выбираем посты из базы

	@results = @db.execute 'select * from posts order by id desc'
	erb :index
end

get '/new' do
  erb :new
end

post '/new' do
	content = params[:content]
	author = params[:author]

	if content.length <= 0 
		@error = "Введите что-нибудь"
		return erb :new
	end

	if author.length <= 0 
		@error = "Представьтесь, пожалуйста"
		return erb :new
	end

	@db.execute "insert into Posts (content, created_date, author) values (?, datetime(), ?)", [content, author]

	redirect to '/'
end

def get_post_details
	post_id = params[:post_id]	

	results = @db.execute 'select * from Posts where id = ?', [post_id]
	@row = results[0]

	# выбираем комментарии для поста
	@comments = @db.execute 'select * from Comments where post_id = ? order by id', [post_id]
end

# вывод информации о посте
get '/details/:post_id' do
	get_post_details
	erb :details

end

# обработчик post-запроса
post '/details/:post_id' do
	post_id = params[:post_id]	
	content = params[:content]
	author = params[:author]

	if content.length <= 0 
		@error = "Введите что-нибудь"
		get_post_details
		return erb :details
	end

	if author.length <= 0 
		@error = "Представьтесь, пожалуйста"
		get_post_details
		return erb :details
	end
	
	@db.execute "insert into Comments 
		(
			content, created_date, post_id, author
		) 
			values 
		(
			?, 
			datetime(), 
			?,
			?
		)", [content, post_id, author]

	redirect to '/details/' + post_id	
	

	

end