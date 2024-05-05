#User
def user()
    if nil == session[:id]
        redirect('/showlogin')
    end
end

def admin()
    if "admin" != session[:authority]
       return true
    else
       return false
    end
end

def connect_to_db(path)
    db = SQLite3::Database.new(path)
end

def check_authority_for_body(body_id)
    db = connect_to_db('db/db.db')
    user_id = db.execute("SELECT user_id FROM bodies WHERE id = ?",body_id).first.first
    if session[:id] == user_id || admin()
        return true
    else
        flash[:notice] = "Du har inte behörighet att göra detta!"
        return false
    end
end

def register(username, password, password_confirmed)
    db = connect_to_db('db/db.db')
    if (password == password_confirmed)
        password_digest = BCrypt::Password.create(password)
        db.execute('INSERT INTO users (username,pwdigest,authority) VALUES (?,?,?)',username,password_digest,"user")
        redirect('/bodies/new')
    else
        "lösenorden matchade inte"
    end
end

def login(username, password)
    db = connect_to_db('db/db.db')
    db.results_as_hash = true
    result = db.execute("SELECT * FROM users WHERE username = ?",username).first
    pwdigest = result["pwdigest"]
    if BCrypt::Password.new(pwdigest) == password
        session[:id] = result["id"]
        session[:authority] = result["authority"]
        session[:username] = result["username"]
        redirect('/bodies/new')
    else
        "FEL LÖSEN HAHA!"
    end
    p session[:authority]
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

def update_body(body_id, bodyname, size, height, weight, new_id, new_user_id)
    db = connect_to_db('db/db.db')
    if check_authority_for_body(body_id)
        db.execute("UPDATE bodies SET bodyname=?,height=?,weight=?,size=?,user_id=?,id=? WHERE id = ?", bodyname,height,weight,size,new_user_id,new_id,body_id)
    end
    redirect('/bodies/index')
end

def delete_body(body_id)
    db = connect_to_db('db/db.db')
    if check_authority_for_body(body_id)
        bodies = db.execute("DELETE FROM bodies WHERE id = ?",body_id)
    end
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

