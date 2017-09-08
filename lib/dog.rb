require_relative "../config/environment.rb"

class Dog

  # Remember, you can access your database connection anywhere in this class
  #  with DB[:conn]
	attr_accessor :name, :breed
	attr_reader :id
	def initialize(hash)
		@name = hash[:name]
		@breed = hash[:breed]
		@id = hash[:id]? hash[:id] : nil
	end

	def self.create_table
		sql = <<-SQL
			CREATE TABLE IF NOT EXISTS dogs (
				id INTEGER PRIMARY key,
				name TEXT,
				breed INTEGER
			);
		SQL
		DB[:conn].execute(sql)
	end

	def self.drop_table
		sql = <<-SQL
			DROP TABLE dogs
		SQL
		DB[:conn].execute(sql)
	end

	def save
		if self.id
			self.update
		else
			sql = <<-SQL
				INSERT INTO dogs (name, breed) VALUES
				(?, ?)
			SQL

			DB[:conn].execute(sql, @name, @breed)
			@id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
		end
		self
	end

	def self.create(hash)
		dog = new(hash)
		dog.save
		dog
	end

	def self.new_from_db(row)
		dog = Dog.new(name: row[1],breed: row[2],id: row[0])
	end

	def self.find_by_id(id)
		sql = <<-SQL
			SELECT * FROM dogs WHERE id = ?
		SQL

		DB[:conn].execute(sql, id).map {|row| self.new_from_db(row)}[0]
	end

	def self.find_by_name(name)
		sql = <<-SQL
			SELECT * FROM dogs WHERE name = ?
		SQL

		data = DB[:conn].execute(sql, name)[0]
		dog = Dog.new(name: data[1],breed: data[2],id: data[0])
	end

	def update
		sql = <<-SQL
			UPDATE dogs SET name = ?, breed = ? WHERE id = ?
		SQL
		DB[:conn].execute(sql, @name, @breed, @id)
	end

	def self.find_or_create_by(name:, breed:)
    dog = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ?", name, breed)
    if !dog.empty?
      dog_data = dog[0]
      dog = Dog.new(id: dog_data[0],name: dog_data[1],breed: dog_data[2])
    else
      dog = self.create(name: name, breed: breed)
    end
    dog
  end
end
