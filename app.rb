require 'sinatra'
require 'sinatra/reloader'
require 'slim'
require 'sqlite3'
require 'bcrypt'
require_relative 'model.rb'
require 'sinatra/flash'


enable :sessions

before('/user/*') do
    if nil == session[:id]
        redirect('/showlogin')
    end
end

before('/user/bodies/:id/*') do
    body_id = params[:id].to_i
    if owns_body?(body_id) || session[:authority] == 'admin'
        return
    else
        flash[:notice] = "Du har inte tillåtelse att göra detta!"
        redirect('/user/bodies/index')
    end
end

before('/admin/*') do
    if session[:authority] == 'admin'
        return 
    else
        flash[:notice] = "Du har inte tillåtelse att göra detta!"
        redirect('/') 
    end
end

get('/') do
    redirect('/showlogin')
end

get('/user/bodies/new') do
    slim(:"/bodies/new")
end

post('/user/bodies/new') do
    height = params[:height]
    weight = params[:weight]
    get_size(height, weight)
    redirect('/user/bodies')
end

get('/user/bodies') do
    slim(:"/bodies/create")
end

post('/user/bodies') do
    bodyname = params[:bodyname]
    save_body(bodyname)
    redirect('/user/bodies/index')
end

get('/user/bodies/index') do
    result = all_bodies_for_user()
    slim(:"/bodies/index",locals:{bodies:result, bodiesadmin:nil})
end  

get('/admin/bodies/index') do
    resultadmin = all_bodies_for_everyone()
    slim(:"/bodies/index",locals:{bodiesadmin:resultadmin})
end  

get('/user/bodies/:id/edit') do
    id = params[:id].to_i
    edit_body(id)
end

post('/user/bodies/:id/update') do
    if "admin"==session[:authority]
        new_user_id = params[:user_id].to_i
    else
        new_user_id = session[:id].to_i
    end
    body_id = params[:id].to_i
    bodyname = params[:bodyname]
    size = params[:size]
    height = params[:height]
    weight = params[:weight]
    update_body(body_id, bodyname, size, height, weight, new_user_id)
    redirect('/user/bodies/index')
end

post('/user/bodies/:id/delete') do
    body_id = params[:id].to_i
    delete_body(body_id)
    redirect('/user/bodies/index')
end

get('/showlogin') do
    slim(:login)
end  

get('/register') do
    slim(:register)
end

post('/register') do
    username = params[:username]
    password = params[:password]
    password_confirmed = params[:password_confirmed]
    if !field_empty?(username, password)
        if !user_exist?(username)
            if comparepassword(password, password_confirmed)
                if lengthvalidation(username, password)
                    register(username, password)
                    flash[:notice] = "Registeringen lyckades!"
                    redirect('/showlogin')
                else
                    flash[:notice] = "Lösenordet eller Användernamnet var för kort!"
                    redirect('/register')
                end
            else
                flash[:notice] = "Lösenorden matchar inte!"
                redirect('/register')
            end
        else
            flash[:notice] = "Denna användare finns redan!"
            redirect('/register')
        end
    else
        flash[:notice] = "Ett av fälten lämnades tomt!"
        redirect('/register')
    end
end

post('/login') do
    username = params[:username]
    password = params[:password]
    if !field_empty?(username, password)
        if user_exist?(username) && passwordvalidation(username, password)
                login(username)
                flash[:notice] = "Inloggningen lyckades!"
                redirect('/user/bodies/new')
        else
            flash[:notice] = "Användaren finns inte eller så stämmer inte Lösenordet!"
            redirect('/showlogin')
        end
    else
        flash[:notice] = "Ett av fälten lämnades tomt!"
        redirect('/showlogin')
    end
end

get('/logout') do
    session.clear
    redirect('/showlogin')
end

