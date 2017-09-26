class Dog

	attr_accessor :name, :breed

	attr_reader :id

	def initialize(id: nil, name:, breed:)
		@name = name
		@breed = breed
		@id = id
	end

	def self.create_table
		DB[:conn].execute('CREATE TABLE IF NOT EXISTS dogs(id INTEGER PRIMARY KEY, name TEXT, breed TEXT)')
	end

	def self.drop_table
		DB[:conn].execute('DROP TABLE dogs')
	end

	def save
     		if @id
			self.update
		else
       			DB[:conn].execute('INSERT INTO dogs (name, breed) VALUES (?, ?)', self.name, self.breed)
       			@id = DB[:conn].execute('SELECT last_insert_rowid() FROM dogs')[0][0]
     		end
     		self
   	end

   	def self.create(name:, breed:)
     		Dog.new(name: name, breed: breed).tap { |dog| dog.save }
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
     		DB[:conn].execute('SELECT * FROM dogs WHERE name=? LIMIT 1', name).tap do |rs|
       			return self.new_from_db(rs[0])
     		end
   	end

   	def self.find_by_id(id)
     		DB[:conn].execute('SELECT * FROM dogs WHERE id=? LIMIT 1', id).tap do |rs|
       			return self.new_from_db(rs[0])
     		end
   	end

  	def update
     		sql = "UPDATE dogs SET name=?, breed=?  WHERE id=?"
     		DB[:conn].execute(sql, @name, @breed, @id)
   	end

end
