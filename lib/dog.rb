require 'pry'
class Dog

  def self.create_table
    sql=<<-SQL
      CREATE TABLE IF NOT EXISTS dogs (
        id INTEGER PRIMARY KEY,
        name TEXT,
        breed TEXT
      )
    SQL
    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql = "DROP TABLE IF EXISTS dogs"
    DB[:conn].execute(sql)
  end

  def self.create **args
    dog = Dog.new **args
    dog.save
    dog
  end

  def self.find_by_id id
    sql = <<-SQL
      SELECT * FROM dogs
      WHERE id = ?
    SQL
    dog = DB[:conn].execute(sql,id)[0]
    new_from_db dog
  end

  def self.find_by_name name
    sql = <<-SQL
      SELECT * FROM dogs
      WHERE name = ?
    SQL
    DB[:conn].execute(sql,name).map do |dog|
      new_from_db dog
    end[0]
  end

  def self.find_or_create_by **args
    sql = "SELECT * FROM dogs WHERE name = ? AND breed = ?"
    result = DB[:conn].execute(sql,args[:name],args[:breed])[0]
    if result
      dog = new_from_db result
    else
      dog = create args
    end
    #binding.pry
    dog
  end

  def self.new_from_db dog
    Dog.new(name: dog[1], breed: dog[2], id: dog[0])
  end

  attr_accessor :name, :breed
  attr_reader :id

  def initialize name: name,breed: breed, id: nil
    @id = id
    @name = name
    @breed = breed
  end

  def save
    return self.update if @id
    sql=<<-SQL
      INSERT INTO dogs (name,breed) VALUES (?,?)
    SQL
    DB[:conn].execute(sql,self.name,self.breed)
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
    self
  end

  def update
    sql=<<-SQL
      UPDATE dogs SET name = ?, breed = ? WHERE id = ?
    SQL
    DB[:conn].execute(sql,self.name,self.breed,self.id)
    self
  end

end
