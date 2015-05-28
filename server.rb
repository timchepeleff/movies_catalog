require "sinatra"
require "pg"
require "pry"

def db_connection
  begin
    connection = PG.connect(dbname: "movies")
    yield(connection)
  ensure
    connection.close
  end
end

def actors_names
  db_connection do |conn|
    conn.exec("SELECT name from actors")
  end
end

def actors_info
  db_connection do |conn|
    conn.exec_params("SELECT actors.name, movies.title, cast_members.character from actors
                          join cast_members on cast_members.actor_id = actors.id
                          join movies on cast_members.movie_id = movies.id
                          where actors.name is values($1)", params[:name])
  end
end

get "/" do
  redirect "/actors"
end

get "/actors" do
  erb :'actors/index', locals: {actors_names: actors_names}
end

get "/actors/:name" do
  erb :show, locals: { name: params[:name], actors_info: actors_info }
end

get "/movies" do
  erb :'movies/index'
end

get "/movies/:id" do
  erb :show, locals: { id: params[:id] }
end
