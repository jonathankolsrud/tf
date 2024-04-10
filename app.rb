require 'sinatra'
require 'sinatra/reloader'
require 'slim'
require 'sqlite3'
require 'bcrypt'
require_relative 'model.rb'

enable :sessions

get('/') do
    no_login()
end

get('/register') do
    slim(:register)
end

get('/bodymaker') do
    no_login()
    slim(:bodymaker)
end

post('/bodymaker') do
    height = params[:height]
    weight = params[:weight]
    get_size(height, weight)
    redirect('/sizedone')
end

get('/sizedone') do
    slim(:sizedone)
end

post('/sizedone') do
    bodyname = params[:bodyname]
    save_size(bodyname)
    redirect('/bodies')
end

get('/bodies') do
    no_login()
    result = all_bodies_for_user()
    slim(:"/bodies",locals:{bodies:result})
end  

post('/bodies/:id/delete') do
    body_id = params[:id].to_i
    delete_body(body_id)
    redirect('/bodies')
end

get('/showlogin') do
    slim(:login)
end  

post('/users/new') do
    username = params[:username]
    password = params[:password]
    password_confirmed = params[:password_confirmed]
    register(username, password, password_confirmed)
end

post('/login') do
    username = params[:username]
    password = params[:password]
    login(username, password)
end

get('/logout') do
    session.clear
    redirect('/showlogin')
end