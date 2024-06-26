require 'sinatra'
require 'sinatra/reloader'
require 'slim'
require 'sqlite3'
require 'bcrypt'
require_relative 'model/model.rb'
require 'sinatra/flash'

include Model


enable :sessions

# Before block
#
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


# Displays the Landing Page
#
get('/') do
    redirect('/user/bodies/index')
end


# Displays a page for calculating a new body
#
get('/user/bodies/new') do
    slim(:"/bodies/new")
end

# Calculates the new body
#
# @param [Integer] :height, the body's height
# @param [Integer] :weight, the body's weight
#
# @see Model#get_size
post('/user/bodies/new') do
    height = params[:height]
    weight = params[:weight]
    get_size(height, weight)
    redirect('/user/bodies')
end

# Displays page for saving the new body
#
get('/user/bodies') do
    slim(:"/bodies/create")
end

# Saves the new body and redirects to '/user/bodies/index'
#
# @param [String] :bodyname, the body's name
#
# @see Model#save_body
post('/user/bodies') do
    bodyname = params[:bodyname]
    save_body(bodyname)
    redirect('/user/bodies/index')
end

# Displays page for showing all your bodies
#
# @see Model#all_bodies_for_user
get('/user/bodies/index') do
    result = all_bodies_for_user()
    slim(:"/bodies/index",locals:{bodies:result, bodiesadmin:nil})
end  

#Displays page for showing everyones bodies
#
# @see Model#all_bodies_for_everyone
get('/admin/bodies/index') do
    resultadmin = all_bodies_for_everyone()
    slim(:"/bodies/index",locals:{bodiesadmin:resultadmin})
end  

# Displays page for editing body
#
# @param [Integer] :id, the body's id
#
# @see Model#edit_body
get('/user/bodies/:id/edit') do
    id = params[:id].to_i
    edit_body(id)
end

# Updates body and redirects to '/user/bodies/index'
#
# @param [Integer] :user_id, the users id
# @param [Integer] :id, the body's id
# @param [String] :bodyname, the body's name
# @param [String] :size, the body's size
# @param [Integer] :height, the body's height
# @param [Integer] :weight, the body's weight
#
# @see Model#update_body
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

# Deletes body and redirects to '/user/bodies/index'
#
# @param [Integer] :id, the body's id
#
# @see Model#delete_body
post('/user/bodies/:id/delete') do
    body_id = params[:id].to_i
    delete_body(body_id)
    redirect('/user/bodies/index')
end

# Displays page for login
#
get('/showlogin') do
    slim(:login)
end  

# Attempts login and redirects to '/user/bodies/new'
#
# @param [String] :username, the users username
# @param [String] :password, the users password
#
# @see Model#login
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

# Displays page for register
#
get('/register') do
    slim(:register)
end

#Attempts registers and redirects to '/showlogin'
#
# @param [String] :username, the users username
# @param [String] :password, the users password
# @param [String] :password_confirmed, the users password
#
# @see Model#register
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

#Logouts user, clears the session and redirects to '/showlogin'
#
get('/logout') do
    session.clear
    redirect('/showlogin')
end

#Deletes the user, clears the session and redirects to '/showlogin'
#
get('/user/delete_user') do
    id = session[:id]
    
    delete_user(id)
    session.clear
    redirect('/showlogin')
end