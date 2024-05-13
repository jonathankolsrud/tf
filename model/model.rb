module Model

    # Returns database items from specified table
    #
    # @param [String] path Path to database
    def connect_to_db(path)
        db = SQLite3::Database.new(path)
    end

    # Checks if user owns body
    #
    # @param [Integer] body_id The body's id
    #
    # @return [Bolean] true The user owns the body
    # @return [Bolean] false The user does not own the body
    def owns_body?(body_id)
        db = connect_to_db('db/db.db')
        user_id = db.execute("SELECT user_id FROM bodies WHERE id = ?", body_id).first.first
        if user_id == session[:id]
            return true
        else
            return false
        end
    end

    # Registers user
    # 
    # @param [String] username The users username
    # @param [String] password The users password
    def register(username, password)
        pwdigest = BCrypt::Password.create(password)
        db = connect_to_db('db/db.db')
        db.execute('INSERT INTO users (username,pwdigest,authority) VALUES (?,?,?)',username,pwdigest,"user")
    end

    # Returns whether username or password field is empty
    #
    # @param [String] username The users username
    # @param [String] password The users password
    #
    # @return [Bolean] true One of the fields are empty
    # @return [Bolean] false None of the field are empty
    def field_empty?(username, password)
        p username && password
        return username && password == ""
    end


    # Returns whether user exists
    #
    # @param [String] username The users username
    #
    # @return [Bolean] true The user exists
    # @return [Bolean] false The user does not exist
    def user_exist?(username)
        db = connect_to_db('db/db.db')
        return db.execute("SELECT * FROM users WHERE username = ?", username).first != nil
    end

    # Returns whether passwords match
    #
    # @param [String] password The users password
    #
    # @return [Bolean] true The passwords match
    # @return [Bolean] false The password do not match
    def comparepassword(password, password_confirmed)
        return (password == password_confirmed)
    end

    # Returns whether length of either username or password is too short
    #
    # @param [String] password The users password
    # @param [String] username The users username
    #
    # @return [Bolean] true The username & password are not too short
    # @return [Bolean] false The username or password are too short
    def lengthvalidation(username, password)
        return username.length >= 4 && password.length >= 6
    end

    # Returns whether password is correct
    #
    # @param [String] password The users password
    # @param [String] username The users username
    #
    # @return [Bolean] true The password is correct
    # @return [Bolean] false The password is not correct
    def passwordvalidation(username, password)
        db = connect_to_db('db/db.db')
        db.results_as_hash = true
        result = db.execute("SELECT * FROM users WHERE username = ?",username).first
        pwdigest = result["pwdigest"]
        return BCrypt::Password.new(pwdigest) == password
    end

    # Logins user by updating the sessions
    #
    # @param [String] username The users username
    def login(username)
        db = connect_to_db('db/db.db')
        db.results_as_hash = true
        result = db.execute("SELECT * FROM users WHERE username = ?",username).first
        session[:id] = result["id"]
        session[:authority] = result["authority"]
        session[:username] = result["username"]
    end

    # Deletes the user and their bodies
    #
    # @param [Integer] id The users id
    def delete_user(id)
        db = connect_to_db('db/db.db')
        db.execute("DELETE FROM bodies WHERE user_id = ?",id)
        db.execute("DELETE FROM users WHERE id = ?",id)
    end

    # Gets size from table and updates the sessions
    #
    # @param [Integer] height The body's height
    # @param [Integer] weight The body's weight
    def get_size(height, weight)
        db = connect_to_db('db/db.db')
        height_id = db.execute("SELECT id FROM heights WHERE height = ?", height).first.first
        weight_id = db.execute("SELECT id FROM weights WHERE weight = ?", weight).first.first
        session[:size] = db.execute("SELECT size FROM heightweightsize WHERE height = ? AND weight = ?", height_id, weight_id).first.first
        session[:height] = height
        session[:weight] = weight
    end

    # Saves body with the bodyname, user_id, size, height and weight
    #
    # @param [String] bodyname The body's name
    def save_body(bodyname)
        db = connect_to_db('db/db.db')
        user_id = session[:id].to_i
        size = session[:size]
        height = session[:height]
        weight = session[:weight] 
        db.execute('INSERT INTO bodies (bodyname,user_id,size,height,weight) VALUES (?,?,?,?,?)',bodyname,user_id,size,height,weight)
    end

    # Gets info about specific body
    #
    # @param [Integer] id The body's id
    def edit_body(id)
        db = connect_to_db('db/db.db')
        db.results_as_hash = true
        result = db.execute("SELECT * FROM bodies WHERE id = ?",id)
        slim(:"/edit",locals:{bodies:result})
    end

    # Updates the body 
    #
    # @param [Integer] new_user_id, New users id
    # @param [Integer] body_id New body's id
    # @param [String] bodyname New body's name
    # @param [String] :size New body's size
    # @param [Integer] :height New body's height
    # @param [Integer] :weight New body's weight
    def update_body(body_id, bodyname, size, height, weight, new_user_id)
        db = connect_to_db('db/db.db')
        db.execute("UPDATE bodies SET bodyname=?,height=?,weight=?,size=?,user_id=? WHERE id = ?", bodyname,height,weight,size,new_user_id,body_id)
    end

    # Deletes body
    #
    # @param [Integer] body_id The body's id
    def delete_body(body_id)
        db = connect_to_db('db/db.db')
        user_id = db.execute("SELECT user_id FROM bodies WHERE id = ?",body_id).first.first
        bodies = db.execute("DELETE FROM bodies WHERE id = ?",body_id)
    end

    # Returns all bodies for user
    #
    def all_bodies_for_user()
        db = connect_to_db('db/db.db')
        id = session[:id].to_i
        db.results_as_hash = true
        return db.execute("SELECT * FROM bodies WHERE user_id = ?",id)
    end

    # Returns all bodies for everyone
    #
    def all_bodies_for_everyone()
        db = connect_to_db('db/db.db')
        db.results_as_hash = true
        return db.execute("SELECT * FROM bodies")
    end

end
