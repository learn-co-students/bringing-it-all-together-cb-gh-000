class Dog

  attr_accessor :name, :breed, :id

  def initialize(data)
    data.each { |key, value| self.send("#{key}=", value)}
  end

  def self.create_table
    sql = <<-SQL
      CREATE TABLE IF NOT EXISTS dogs (
        id INTEGER PRIMARY KEY,
        name TEXT,
        breed TEXT
      )
    SQL
    DB[:conn].execute(sql)
  end

  def self.drop_table
    DB[:conn].execute("DROP TABLE dogs")
  end

  def save
    if self.id
      self.update
    else
      DB[:conn].execute("INSERT INTO dogs (name, breed) VALUES (?, ?)", self.name, self.breed)
      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
    end
    self
  end

  def update
    DB[:conn].execute("UPDATE dogs SET name = ?, breed = ? WHERE id = ?", self.name, self.breed, self.id)
  end

  def self.create(data)
    dog = Dog.new(data)
    dog.save
    dog
  end

  def self.find_by_id(id)
    data = DB[:conn].execute("SELECT * FROM dogs WHERE id = ?", id).first
    Dog.new(name: data[1], breed: data[2], id: data[0])
  end

  def self.find_or_create_by(name:, breed:)
    data = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ?", name, breed)
    if !data.empty?
      self.new_from_db(data[0])
    else
      self.create(name: name, breed: breed)
    end
  end

  def self.new_from_db(row)
    Dog.new(id: row[0], name: row[1], breed: row[2])
  end

  def self.find_by_name(name)
    data = DB[:conn].execute("SELECT * FROM dogs WHERE name = ?", name).first
    self.new_from_db(data)
  end


end
