class Dog
  attr_accessor :name, :breed
  attr_reader :id

  def initialize(name:, breed:, id: id = nil)
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
      )
    SQL
    DB[:conn].execute(sql)
  end

  def self.drop_table
    DB[:conn].execute("DROP TABLE IF EXISTS dogs")
  end

  def self.new_from_db(row)
    new(name: row[1], breed: row[2], id:row[0])
  end

  def self.find_by_name(name)
    DB[:conn].execute("SELECT * FROM dogs WHERE name = ?", name).collect do |row|
      new_from_db(row)
    end.first
  end

  def self.find_by_id(id)
    DB[:conn].execute("SELECT * FROM dogs WHERE id = ?", id).collect do |row|
      new_from_db(row)
    end.first
  end

  def self.find_or_create_by(name:, breed:)
    sql = <<-SQL
    SELECT *
    FROM dogs
    WHERE name = ? AND breed = ?
    SQL

    dog = DB[:conn].execute(sql, name, breed)
    if dog.empty?
      create(name: name, breed: breed)
    else
      new(name: dog[0][1], breed: dog[0][2], id: dog[0][0])
    end
  end

  def self.create(name:, breed:)
    new(name: name, breed: breed).tap{|o| o.save}
  end

  def update
    sql = <<-SQL
    UPDATE dogs
    SET name = ?, breed = ?
    WHERE id = ?
    SQL

    DB[:conn].execute(sql, @name, @breed, @id)
    self
  end

  def save
    if @id
      update
    else
      sql = <<-SQL
      INSERT INTO dogs(name, breed)
      VALUES (?, ?)
      SQL
      DB[:conn].execute(sql, [@name, @breed])
      sql = "SELECT last_insert_rowid() FROM dogs"
      @id = DB[:conn].execute(sql)[0][0]
      self
    end
  end
end
