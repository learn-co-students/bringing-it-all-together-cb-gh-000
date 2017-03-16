class Dog
  attr_accessor :breed, :name
  attr_reader :id

  def self.create(breed:, name:)
    Dog.new(breed: breed, name: name).tap { |dog| dog.save }
  end

  def self.create_table
    DB[:conn].execute("CREATE TABLE IF NOT EXISTS dogs (id INTEGER PRIMARY KEY, breed VARCHAR(255), name VARCHAR(255))")
  end

  def self.drop_table
    DB[:conn].execute("DROP TABLE IF EXISTS dogs")
  end

  def self.find_by_id(id)
    DB[:conn].execute("SELECT * FROM dogs WHERE id = ? LIMIT 1", id).tap do |response|
      return new_from_db(response[0])
    end
  end

  def self.find_by_name(name)
    DB[:conn].execute("SELECT * FROM dogs WHERE name = ? LIMIT 1", name).tap do |response|
      return new_from_db(response[0])
    end
  end

  def self.find_or_create_by(breed:, name:)
    dog = DB[:conn].execute("SELECT * FROM dogs WHERE breed = ? AND name = ?", breed, name)

    if !dog.empty?
      data = dog[0]
      new(id: data[0], breed: data[1], name: data[2])
    else
      create(breed: breed, name: name)
    end
  end

  def self.new_from_db(row)
    new(id: row[0], breed: row[2], name: row[1])
  end

  def initialize(breed:, id: nil, name:)
    @breed = breed
    @id = id
    @name = name
  end

  def save
    if @id
      update
    else
      DB[:conn].execute("INSERT INTO dogs (breed, name) VALUES (?, ?)", @breed, @name)
      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
    end

    self
  end

  def update
    DB[:conn].execute("UPDATE dogs SET breed = ?, name = ? WHERE id = ?", @breed, @name, @id)
  end
end
