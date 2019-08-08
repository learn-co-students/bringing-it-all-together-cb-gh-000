class Dog
  attr_accessor :id, :name, :breed

  def initialize(id: nil, name: nil, breed: nil)
    @id = id
    @name = name
    @breed = breed
  end

  def self.create_table
    sql = <<-SQL
      CREATE TABLE IF NOT EXISTS dogs (
        id INTEGER PRIMARY KEY,
        name TEXT,
        breed TEXT
      );
    SQL

    DB[:conn].execute(sql)
  end

  def self.drop_table
    DB[:conn].execute("DROP TABLE dogs")
  end

  def self.new_from_db(row)
    dog = Dog.new(id: row[0], name: row[1], breed: row[2])
  end

  def self.find_by_name(name)
    dogA = DB[:conn].execute("SELECT id, name, breed FROM dogs WHERE name = ?", name)[0]
    return Dog.new_from_db(dogA)
  end

  def update
    DB[:conn].execute("UPDATE dogs SET name = ?, breed = ? WHERE id = ?", @name, @breed, @id)
  end

  def save
    if self.id
      self.update
    else
      DB[:conn].execute("INSERT INTO dogs (name, breed) VALUES (?, ?)", @name, @breed)
      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
    end
    return self
  end

  def self.create(name: nil, breed: nil)
    dog = Dog.new(name: name, breed: breed)
    dog.save
    dog
  end

  def self.find_by_id(id)
    dogA = DB[:conn].execute("SELECT id, name, breed FROM dogs WHERE id = ?", id)[0]
    return Dog.new_from_db(dogA)
  end

  def self.find_or_create_by(name:, breed:)
    dogA = DB[:conn].execute("SELECT id, name, breed FROM dogs WHERE name = ? AND breed = ?", name, breed)[0]
    if dogA
      return Dog.new_from_db(dogA)
    else
      Dog.create(name: name, breed: breed)
    end
  end
end
