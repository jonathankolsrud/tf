require 'sinatra'
require 'sinatra/reloader'
require 'slim'
require 'sqlite3'
require 'bcrypt'
require_relative 'model.rb'
require 'sinatra/flash'

enable :sessions

get('/') do
    user()
end

get('/register') do
    slim(:register)
end


get('/bodies/new') do
    user()
    slim(:new)
end

post('/bodies/new') do
    height = params[:height]
    weight = params[:weight]
    get_size(height, weight)
    redirect('/bodies/create')
end

get('/bodies/create') do
    user()
    slim(:create)
end

post('/bodies/create') do
    bodyname = params[:bodyname]
    save_body(bodyname)
    redirect('/bodies/index')
end

get('/bodies/index') do
    user()
    result = all_bodies_for_user()
    slim(:"/index",locals:{bodies:result})
end  

get('/bodies/index_admin') do
    user()
    admin()
    result = all_bodies_for_everyone()
    slim(:"/index_admin",locals:{bodies:result})
end  

get('/bodies/:id/edit') do
    id = params[:id].to_i
    edit_body(id)
end

post('/bodies/:id/update') do
    if "admin"==session[:authority]
        new_id =  params[:admin_id].to_i
        new_user_id = params[:user_id].to_i
    else
        new_id =  params[:id].to_i
        new_user_id = session[:id].to_i
    end
    body_id = params[:id].to_i
    bodyname = params[:bodyname]
    size = params[:size]
    height = params[:height]
    weight = params[:weight]
    update_body(body_id, bodyname, size, height, weight, new_id, new_user_id)
end

post('/bodies/:id/delete') do
    body_id = params[:id].to_i
    delete_body(body_id)
    redirect('/bodies/index')
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