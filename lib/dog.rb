class Dog 
  attr_accessor :name, :breed, :id 
  
  def initialize(args)
    @name = args[:name]
    @breed = args[:breed]
  end
  
  def self.create_table
    sql = <<-SQL 
      CREATE TABLE dogs (
        id INTEGER PRIMARY KEY,
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
    if self.id
      self.update
    else
      sql = <<-SQL 
        INSERT INTO dogs(name, breed) VALUES (?, ?);
      SQL
      DB[:conn].execute(sql, self.name, self.breed)
      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
      self
    end
  end
  
  def self.create(args)
    dog = self.new(args)
    dog.save
    dog
  end
  
  def self.find_by_id(id)
    sql = <<-SQL 
      SELECT * FROM dogs WHERE id = ?
    SQL
    res = DB[:conn].execute(sql, id)
    if !res.empty?
      dog = self.new({
        :name => res[0][1],
        :breed => res[0][2]
      })
      dog.id = res[0][0]
      dog
    end
  end
  
  def self.find_or_create_by(args)
    sql = <<-SQL 
      SELECT * FROM dogs WHERE name = ?
    SQL
    res = DB[:conn].execute(sql, args[:name])
    if res.empty?
      self.create(args)
    else
      # dog = Dog.new(args)
      if res[0][2] == args[:breed]
        dog = Dog.new({:name => args[:name],
          :breed => args[:breed]
        })
        dog.id = res[0][0]
        dog
      else
        self.create(args)
      end
      
    end
  end
  
  def self.new_from_db(row)
    dog = Dog.new({:name => row[1], :breed => row[2]})
    dog.id = row[0]
    dog
  end
  
  def self.find_by_name(name)
    sql = <<-SQL 
      SELECT * FROM dogs WHERE name = ?
    SQL
    res = DB[:conn].execute(sql, name)
    dog = self.new({:name => res[0][1], :breed => res[0][2]})
    dog.id= res[0][0]
    dog
  end
  
  def update
    sql = <<-SQL 
      UPDATE dogs SET name = ?, breed = ? WHERE id = ?
    SQL
    DB[:conn].execute(sql, self.name, self.breed, self.id)
  end
end