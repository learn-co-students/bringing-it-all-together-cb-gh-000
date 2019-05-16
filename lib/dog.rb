require 'sqlite3'

DB = {:conn => SQLite3::Database.new("db/dogs.db")}

class Dog
  attr_accessor :name, :breed, :id

  def initialize(name:"Fido", breed:"Lab", id:nil)
    @name  = name
    @breed = breed
    @id    = id
  end

  def self.drop_table
    sql = "DROP TABLE IF EXISTS dogs;"
    DB[:conn].execute(sql)
  end

  def self.create_table
    Dog.drop_table
    sql = <<-SQL
    CREATE TABLE dogs (
      id INTEGER PRIMARY KEY,
      name TEXT,
      breed TEXT)
    SQL
    DB[:conn].execute(sql)
  end

  def to_s
    #puts "this Dog is named #{@name}, and it's a #{breed}. Good dog! (id=#{@id})"
  end

  def sql_insert
    sql_insert = "INSERT INTO dogs(name,breed) VALUES (?, ?)"
    DB[:conn].execute(sql_insert,@name,@breed)
  end

  def update
    sql_update = "UPDATE dogs SET name = ?, breed = ? WHERE id = ?"
    DB[:conn].execute(sql_update,@name,@breed,@id)
  end

  def save
    if self.id
      self.update
    else
      sql = <<-SQL
        INSERT INTO dogs (name, breed)
        VALUES (?, ?)
      SQL

      DB[:conn].execute(sql, self.name, self.breed)
      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
      self
    end
    # dog1 = Dog.find_by_name(@name)
    # if dog1 == []
    #   sql_insert
    #   sql_retrieve = "SELECT * FROM dogs WHERE NAME = ?"
    #   row = DB[:conn].execute(sql_retrieve,@name)
    #   @id = row[0][0]
    # else
    #   update
    # end
    # self
  end

  def self.create(name:,breed:)
    dog = Dog.new(name:name,breed:breed)
    dog.save
  end

  def self.new_from_db(row)
    id, name, breed = row
    dog = Dog.new(id:id,name:name,breed:breed)
  end

  def self.find_by_attr(attribute,value)
    sql_find_by_x = "SELECT * FROM dogs WHERE #{attribute}=?"
    rows = DB[:conn].execute(sql_find_by_x,value)
    if rows.empty?
      []
    else
      dog  = Dog.new_from_db(rows[0])
    end
  end

  #TODO: use metaprogramming here!

  def self.find_by_id(id)
    Dog.find_by_attr("id",id)
  end

  def self.find_by_name(name)
    Dog.find_by_attr("name",name)
  end

  def self.find_by_breed(breed)
    Dog.find_by_attr("breed",breed)
  end

  def self.find_or_create_by(name:,breed:)
    #puts "before starting find_or_create_by, we have these dogs:"
    #puts DB[:conn].execute("SELECT * FROM dogs")
    dog = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ?", name, breed)
    #puts dog and #puts "Is dog nil? #{dog.nil?}"
    if !dog.empty?
      #puts "we got dog #{dog}"
      dog_data = dog[0]
      dog = Dog.new_from_db(dog_data)
      #puts "reconstituted dog #{dog.name} of breed #{dog.breed} with id #{dog.id} (dog is of type #{dog.class})"
    else
      dog = self.create(name: name, breed: breed)
      #puts "created dog: #{dog.name}"
    end
    dog
  end

end
