require 'sinatra'
require 'sinatra/reloader'
require 'slim'
require 'sqlite3'
require 'bcrypt'

get('/') do
    
    slim(:home)
end

get('/bodymaker') do
    slim(:bodymaker)
end

post('/bodymaker') do
    height = params[:height]
    weight = params[:weight]
    p height
    p weight
    db = SQLite3::Database.new("db/db.db")
    height_id = db.execute("SELECT id FROM heights WHERE height = ?", height).first.first
    weight_id = db.execute("SELECT id FROM weights WHERE weight = ?", weight).first.first
    size = db.execute("SELECT size FROM heightweightsize WHERE height = ? AND weight = ?", height_id, weight_id).first.first
    slim(:"sizedone",locals:{size:size})
end

get('/sizedone') do
slim(:sizedone)
end