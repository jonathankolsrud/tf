#User

def connect_to_db(path)
    db = SQLite3::Database.new(path)
end

def owns_body?(body_id)
    db = connect_to_db('db/db.db')
    user_id = db.execute("SELECT user_id FROM bodies WHERE id = ?", body_id).first.first
    if user_id == session[:id]
        return true
    else
        return false
    end
end



#register
def register(username, password)
    pwdigest = BCrypt::Password.create(password)
    db = connect_to_db('db/db.db')
    db.execute('INSERT INTO users (username,pwdigest,authority) VALUES (?,?,?)',username,pwdigest,"user")
end

#validering
def field_empty?(username, password)
    p username && password
    return username && password == ""
end

def user_exist?(username)
    db = connect_to_db('db/db.db')
    return db.execute("SELECT * FROM users WHERE username = ?", username).first != nil
end

def comparepassword(password, password_confirmed)
    return (password == password_confirmed)
end

def lengthvalidation(username, password)
    return username.length >= 4 && password.length >= 6
end

def passwordvalidation(username, password)
    db = connect_to_db('db/db.db')
    db.results_as_hash = true
    result = db.execute("SELECT * FROM users WHERE username = ?",username).first
    pwdigest = result["pwdigest"]
    return BCrypt::Password.new(pwdigest) == password
end

def login(username)
    db = connect_to_db('db/db.db')
    db.results_as_hash = true
    result = db.execute("SELECT * FROM users WHERE username = ?",username).first
    session[:id] = result["id"]
    session[:authority] = result["authority"]
    session[:username] = result["username"]
end


#Size
def get_size(height, weight)
    db = connect_to_db('db/db.db')
    height_id = db.execute("SELECT id FROM heights WHERE height = ?", height).first.first
    weight_id = db.execute("SELECT id FROM weights WHERE weight = ?", weight).first.first
    session[:size] = db.execute("SELECT size FROM heightweightsize WHERE height = ? AND weight = ?", height_id, weight_id).first.first
    session[:height] = height
    session[:weight] = weight
end

#Bodies
def save_body(bodyname)
    db = connect_to_db('db/db.db')
    user_id = session[:id].to_i
    topsize = session[:size]
    height = session[:height]
    weight = session[:weight] 
    db.execute('INSERT INTO bodies (bodyname,user_id,size,height,weight) VALUES (?,?,?,?,?)',bodyname,user_id,topsize,height,weight)
end

def edit_body(id)
    db = connect_to_db('db/db.db')
    db.results_as_hash = true
    result = db.execute("SELECT * FROM bodies WHERE id = ?",id)
    p result
    slim(:"/edit",locals:{bodies:result})
end

def update_body(body_id, bodyname, size, height, weight, new_user_id)
    db = connect_to_db('db/db.db')
    db.execute("UPDATE bodies SET bodyname=?,height=?,weight=?,size=?,user_id=? WHERE id = ?", bodyname,height,weight,size,new_user_id,body_id)
end

def delete_body(body_id)
    db = connect_to_db('db/db.db')
    user_id = db.execute("SELECT user_id FROM bodies WHERE id = ?",body_id).first.first
    bodies = db.execute("DELETE FROM bodies WHERE id = ?",body_id)
end

def all_bodies_for_user()
    db = connect_to_db('db/db.db')
    id = session[:id].to_i
    db.results_as_hash = true
    db.execute("SELECT * FROM bodies WHERE user_id = ?",id)
end

def all_bodies_for_everyone()
    db = connect_to_db('db/db.db')
    db.results_as_hash = true
    db.execute("SELECT * FROM bodies")
end

