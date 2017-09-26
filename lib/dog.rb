class Dog
    attr_accessor :id, :name, :breed

    def initialize(id: nil, name:, breed:)
        @id, @name, @breed = id, name, breed
    end

    def self.create_table
        sql = "CREATE TABLE IF NOT EXISTS dogs(id INTEGER PRIMARY KEY, name TEXT, breed TEXT)"
        DB[:conn].execute(sql)
    end

    def self.drop_table
        sql = "DROP TABLE dogs"
        DB[:conn].execute(sql)
    end

    def save
        sql = "INSERT INTO dogs (name, breed) VALUES (?, ?)"
        DB[:conn].execute(sql, self.name, self.breed)
        @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]

        self
    end

    def self.create(name:, breed:)
        dog = self.new(name: name, breed: breed)
        dog.save
    end

    def self.find_by_id(id)
        sql = "SELECT * FROM dogs WHERE id = ?"
        row = DB[:conn].execute(sql, id).flatten

        dog = self.new(id: id, name: row[1], breed: row[2])
        dog
    end

    def self.find_or_create_by(name:, breed:)
        sql = "SELECT * FROM dogs WHERE name = ? AND breed = ? LIMIT 1"
        row = DB[:conn].execute(sql, name, breed)

        if !row.empty?
            dog = self.create(name: row[0][1], breed: row[0][2])
            dog.id = row[0][0]
        else
            dog = self.create(name: name, breed: breed)
        end
        dog
    end

    def self.new_from_db(row)
        dog = self.create(name: row[1], breed: row[2])
        dog.id = row[0]
        dog
    end

    def self.find_by_name(name)
        sql = "SELECT * FROM dogs WHERE name = ? LIMIT 1"
        row = DB[:conn].execute(sql, name).flatten

        dog = self.new_from_db(row)
        dog
    end

    def update
        sql = "UPDATE dogs SET name=?, breed=? WHERE id=?"
        DB[:conn].execute(sql, self.name, self.breed, self.id)
    end
end
