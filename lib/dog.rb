class Dog

  attr_accessor :name, :breed
  attr_reader :id

  def initialize(name:, breed:, id: nil)
    @name = name
    @breed = breed
    @id = id
  end

  def self.create_table
    sql = <<-SQL
      CREATE TABLE IF NOT EXISTS dogs(
        id INTEGER PRIMARY KEY,
        name TEXT,
        breed TEXT
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
    if !self.id
      sql = <<-SQL
        INSERT INTO dogs (name, breed) VALUES (?, ?)
      SQL
      DB[:conn].execute(sql, self.name, self.breed)
      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
    end
    self
  end

  def self.create(name:, breed:)
    self.new(name: name, breed: breed).tap { |dog| dog.save }
  end

  def self.find_by_id(id)
    sql = <<-SQL
      SELECT dogs.name, dogs.breed, dogs.id
      FROM dogs 
      WHERE dogs.id = ?
    SQL
    dog_row = DB[:conn].execute(sql, id)[0]
    self.new(name: dog_row[0], breed: dog_row[1], id: dog_row[2])
  end

  def self.find_or_create_by(name:, breed:)
    sql = <<-SQL
      SELECT dogs.name, dogs.breed, dogs.id
      FROM dogs 
      WHERE dogs.name = ? AND dogs.breed = ?
    SQL
    dog = DB[:conn].execute(sql, name, breed)
    if !dog.empty?
      dog_row = dog[0]
      dog = self.new(name: dog_row[0], breed: dog_row[1], id: dog_row[2])
    else
      dog = self.create(name: name, breed: breed)
    end
    dog
  end

  def self.new_from_db(row)
    self.new(id: row[0], name: row[1], breed: row[2])
  end

  def self.find_by_name(name)
    sql = <<-SQL
      SELECT *
      FROM dogs 
      WHERE dogs.name = ?
    SQL
    self.new_from_db(DB[:conn].execute(sql, name)[0])
  end

  def update
    sql = <<-SQL
      UPDATE dogs
      SET name = ?, breed = ?
      WHERE id = ?
    SQL
    DB[:conn].execute(sql, self.name, self.breed, self.id)
  end
end