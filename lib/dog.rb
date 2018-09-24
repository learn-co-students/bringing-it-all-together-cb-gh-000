class Dog
  attr_accessor :name, :breed
  attr_reader :id

  def initialize(id: nil, name:, breed:)
    @id, @name, @breed = id, name, breed
  end

  def self.create_table
    sql = <<-SQL
      CREATE TABLE  IF NOT EXISTS dogs(
        id INTEGER PRIMART KEY,
        name TEXT,
        breed TEXT
      );
      SQL
    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql = <<-SQL
      DROP TABLE dogs;
      SQL
    DB[:conn].execute(sql)
  end

  def save
    unless self.id
      sql = <<-SQL
        INSERT INTO dogs(name, breed)
        VALUES (?, ?);
        SQL
      DB[:conn].execute(sql, self.name, self.breed)

      @id = DB[:conn].execute("SELECT id FROM dogs WHERE name = ? AND breed = ?", self.name, self.breed)[0][0]
    else
      self.update
    end
    self
  end

  def self.create(row)
    dog = self.new(row)
    dog.save
    dog
  end

  def self.find_by_id(id)
    sql = <<-SQL
      SELECT * FROM dogs WHERE id = ?;
      SQL
    DB[:conn].execute(sql, id).map do |row|
       self.new_from_db(row)
    end.first
  end

  def self.find_or_create_by(row)
    sql = <<-SQL
        SELECT * FROM dogs WHERE name = ? AND breed = ?;
        SQL
    dog_data = DB[:conn].execute(sql, row[:name], row[:breed])
    if dog_data.empty?
      dog = self.create(row)
    else
      dog_data_hash = {id:dog_data[0][0], name: dog_data[0][1], breed: dog_data[0][2]}
      dog = self.new(dog_data_hash)
    end
    dog
  end

  def self.new_from_db(row)
    dog_data_hash = {id: row[0], name: row[1], breed: row[2]}
    dog = self.new(dog_data_hash)
  end

  def self.find_by_name(name)
    sql = <<-SQL
        SELECT * FROM dogs WHERE name = ? ;
        SQL
    DB[:conn].execute(sql, name).map do |row|
       self.new_from_db(row)
    end.first
  end

  def update
    sql = <<-SQL
      UPDATE dogs SET id = ?, name = ?, breed = ?;
      SQL
    DB[:conn].execute(sql, self.id, self.name, self.breed)
  end




end
