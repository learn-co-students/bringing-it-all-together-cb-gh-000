class Dog
  attr_accessor :id, :name, :breed

  def initialize(id: nil, name: nil, breed: nil, attributes: {})
    attributes.each do |attribute, value|
      self.send("#{attribute}=", value)
    end

    @id ||= id
    @name ||= name
    @breed ||= breed
  end

  # Instance Methods

  def save
    if self.id
      self.update
    else
      sql_insert = 'INSERT INTO dogs (name, breed) VALUES (?, ?)'
      DB[:conn].execute(sql_insert, @name, @breed)

      sql_select_last = 'SELECT last_insert_rowid() FROM dogs'
      @id = DB[:conn].execute(sql_select_last)[0][0]
    end

    self
  end

  def update

  end

  # Class Methods

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

  def self.create(attributes)
    dog = self.new(attributes: attributes)
    dog.save
    dog
  end

  def self.new_from_db(row)
    id = row[0]
    name = row[1]
    breed = row[2]

    self.new(id: id, name: name, breed: breed)
  end

  def self.find_by_id(id)
    sql = <<-SQL
      SELECT id, name, breed FROM dogs
      WHERE id = ?
      LIMIT 1
    SQL

    DB[:conn].execute(sql, id).map do |row|
      self.new_from_db(row)
    end.first
  end
end