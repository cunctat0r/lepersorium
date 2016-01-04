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
		content TEXT
	)'
	@db.execute 'create table if not exists Comments 
	(
		id INTEGER PRIMARY KEY AUTOINCREMENT, 
		created_date DATE, 
		content TEXT,
		post_id INTEGER
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

	if content.length <= 0 
		@error = "Введите что-нибудь"
		return erb :new
	end

	@db.execute "insert into Posts (content, created_date) values (?, datetime())", [content]

	redirect to '/'
end

# вывод информации о посте
get '/details/:post_id' do
	post_id = params[:post_id]	

	results = @db.execute 'select * from posts where id = ?', [post_id]
	@row = results[0]

	erb :details

end

# обработчик post-запроса
post '/details/:post_id' do
	post_id = params[:post_id]	
	content = params[:content]

	erb "You typed comment #{content} for post #{post_id}"

end