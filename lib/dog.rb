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
      CREATE TABLE IF NOT EXISTS dogs (
        id INTEGER PRIMARY KEY,
        name TEXT,
        breed TEXT
      );
      SQL
    DB[:conn].execute(sql)
  end

  def self.drop_table
    DB[:conn].execute("DROP TABLE dogs;")
  end

  def save
    if self.id
      self.update
    else
      sql = <<-SQL
        INSERT INTO dogs (name, breed)
        VALUES (? , ?);
        SQL
      DB[:conn].execute(sql, self.name, self.breed)
      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs;")[0][0]
    end
    Dog.new(name: self.name, breed: self.breed, id: self.id)
  end

  def self.create(name:, breed:)
    obj = Dog.new(name: name, breed: breed)
    obj.save
    obj
  end

  def self.find_by_id(val)
    sql = <<-SQL
      SELECT * FROM dogs
      WHERE id = ?
      LIMIT 1
      SQL
    self.new_from_db(DB[:conn].execute(sql, val)[0])
  end

  def self.new_from_db(row)
    Dog.new(id: row[0], name:row[1], breed: row[2])
  end

  def self.find_or_create_by(name:, breed:)
    sql = <<-SQL
      SELECT * FROM dogs
      WHERE name = ? AND breed = ?
      SQL
    dg = DB[:conn].execute(sql, name, breed)
    if !dg.empty?
      data = dg[0]
      dg_new = Dog.new(id: data[0], name: data[1], breed: data[2])
    else
      dg_new = self.create(name: name, breed: breed)
    end
    dg_new
  end

  def self.find_by_name(name)
    sql = <<-SQL
      SELECT * FROM dogs
      WHERE name = ?
      LIMIT 1;
      SQL
    dg = DB[:conn].execute(sql, name)[0]
    Dog.new(id: dg[0], name: dg[1], breed: dg[2])
  end

  def update
    sql = <<-SQL
      UPDATE dogs
      SET name = ?, breed = ?
      SQL
    DB[:conn].execute(sql, self.name, self.breed)
  end

end
