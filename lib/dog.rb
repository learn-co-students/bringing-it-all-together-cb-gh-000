class Dog
  attr_accessor :id, :name ,:breed
  def initialize(id:nil,name:,breed:)
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
    )
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
      INSERT INTO dogs (name,breed)
      VALUES (?,?)
      SQL
      DB[:conn].execute(sql, self.name, self.breed)
      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
      self
    end
  end

  def update
    sql = <<-SQL
    UPDATE dogs
    SET name = ? , breed = ?
    where id = ?
    SQL
    DB[:conn].execute(sql,self.name,self.breed,self.id)
  end
  def self.find_by_name(name)
    sql = <<-SQL
   SELECT *
   FROM dogs
   WHERE name = ?
   LIMIT 1
   SQL
   DB[:conn].execute(sql,name).map do |k|
     self.new_from_db(k)
   end.first
  end

  def self.new_from_db(row)
    doghash = {id: row[0], name: row[1], breed: row[2]}
   dog = self.new(doghash)
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
    dogdata = DB[:conn].execute(sql, row[:name], row[:breed])
    if dogdata.empty?
      dog = self.create(row)
    else
      doghash = {id:dogdata[0][0], name: dogdata[0][1], breed: dogdata[0][2]}
      dog = self.new(doghash)
    end
    dog
  end

end