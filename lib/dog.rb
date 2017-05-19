class Dog

  attr_accessor :name,:breed,:id

  def initialize(args)
    args.each{|key,value| self.send("#{key}=",value)}
  end

  def self.create_table
    query = <<-SQL
      CREATE TABLE dogs(
        id INTEGER PRIMARY KEY,
        name TEXT,
        breed TEXT
      )
    SQL
    self.drop_table
    DB[:conn].execute(query)
  end

  def self.drop_table
    query = <<-SQL
      DROP TABLE IF EXISTS dogs
    SQL

    DB[:conn].execute(query)
  end

  def save
    query = <<-SQL
      INSERT INTO dogs(name,breed) VALUES (?,?)
    SQL
    DB[:conn].execute(query,@name,@breed)
    @id = DB[:conn].last_insert_row_id
    self
  end

  def self.create(args)
    s = self.new(args)
    s.save
  end

  def self.find_or_create_by(name:, breed:)
     		dog = DB[:conn].execute('SELECT * FROM dogs WHERE name=? AND breed=?', name, breed)
     		if !dog.empty?
       			data = dog[0]
       			Dog.new(id: data[0], name: data[1], breed: data[2])
     		else
       			self.create(name: name, breed: breed)
     		end
   	end

   	def self.new_from_db(row)
     		self.new(id: row[0], name: row[1], breed: row[2])
   	end

   	def self.find_by_name(name)
     		res = DB[:conn].execute('SELECT * FROM dogs WHERE name=? LIMIT 1', name)
        self.new_from_db(res[0])
   	end

   	def self.find_by_id(id)
     		res = DB[:conn].execute('SELECT * FROM dogs WHERE id=? LIMIT 1', id)
       	self.new_from_db(res[0])
   	end

  	def update
     		sql = "UPDATE dogs SET name=?, breed=?  WHERE id=?"
     		DB[:conn].execute(sql, @name, @breed, @id)
   	end
end