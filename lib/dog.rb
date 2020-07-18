class Dog

  attr_reader :id

  attr_accessor :name,:grade

  def initialize(name,breed,id=nil)
    @name=name
    @breed=breed
    @id=id
  end

  def self.create_table
    sql="CREATE TABLE dogs(
    id INTEGER PRIMARY KEY,
    name TEXT,
    breed TEXT
    );"
    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql="DROP TABLE dogs"
    DB[:conn].execute(sql)
  end

  def save(name,breed)
    sql="INSERT INTO dogs(name,breed) VALUES(?,?)"
    DB[:conn].execute(sql,name,breed)
    sql1="SELECTid FROM dogs ORDER BY id DESC LIMIT 1"
    @id=DB[:conn].execute(sql1)[0]
  end

  def self.create(name,breed)
    d=Dog.new(name,breed)
    save(name,breed)
    return d
  end

  def self.new_from_db(row)
    d=Dog.new(row[1],row[2])
    return d
  end

  def self.find_or_create_by(name,breed)

  end

end
