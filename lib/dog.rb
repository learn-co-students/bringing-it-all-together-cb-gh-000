class Dog
  attr_accessor :name, :breed
  attr_reader :id

  def initialize(name: nil, breed: nil, id: nil)
    self.name  = name
    self.breed = breed
    @id        = id
  end

  def update
    DB[:conn].execute("UPDATE dogs SET name = ?, breed = ? WHERE id = ?;", self.name, self.breed, self.id)
  end
  def save
    if self.id
      self.update
    else
      sql = <<-SQL
              INSERT INTO dogs (name, breed) VALUES (?, ?);
            SQL
      DB[:conn].execute(sql, self.name, self.breed)
      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs;")[0][0]
    end
    self
  end

  def self.create_table
    sql = <<-SQL
            CREATE TABLE IF NOT EXISTS dogs(
              id    INTEGER PRIMARY KEY,
              name  TEXT,
              breed TEXT
            );
          SQL
    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql = <<-SQL
            DROP TABLE IF EXISTS dogs;
          SQL
    DB[:conn].execute(sql)
  end

  def self.create(info)
    self.new(info).save
  end

  def self.find_by_id(id)
    row = DB[:conn].execute("SELECT * FROM dogs WHERE id = ?", id)[0]
    self.new_from_db(row)
  end

  def self.find_or_create_by(name: nil, breed: nil)
    dog = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ?;", name, breed)
    if dog.empty?
      self.create(name: name, breed: breed)
    else
      id = dog[0][0]
      self.new(name: name, breed: breed, id: id)
    end
  end

  def self.new_from_db(row)
    id, name, breed = row
    self.new(name: name, breed: breed, id: id)
  end

  def self.find_by_name(name)
    row = DB[:conn].execute("SELECT * FROM dogs WHERE name = ?", name)[0]
    self.new_from_db(row)
  end
end
