require 'pry'

class Dog
  attr_accessor :id, :name, :breed

  def initialize(id: nil, name: nil, breed: nil, attributes: nil)
    self.id = id
    self.name = name
    self.breed = breed
    self.attributes = attributes
  end

  # Instance Methods

  def save
    if self.id
      self.update
    else
      sql_insert = 'INSERT INTO dogs (name, breed) VALUES (?, ?)'
      DB[:conn].execute(sql_insert, @name, @breed)

      sql_select_last = 'SELECT last_insert_rowid() FROM dogs'
      self.id = DB[:conn].execute(sql_select_last)[0][0]
    end

    self
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

  def attributes=(attributes)
    return self if attributes.nil?

    attributes.each do |attribute, value|
      self.send("#{attribute}=", value)
    end

    self
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
  end

  def self.new_from_db(row)
    id = row[0]
    name = row[1]
    breed = row[2]

    self.new(id: id, name: name, breed: breed)
  end

  def self.find_by(name:, breed:)
    sql = <<-SQL
      SELECT id, name, breed FROM dogs
      WHERE name = ?
      AND breed = ?
      LIMIT 1
    SQL

    DB[:conn].execute(sql, name, breed).map do |row|
      self.new_from_db(row)
    end.first
  end

  def self.find_by_name(name)
    sql = <<-SQL
      SELECT id, name, breed FROM dogs
      WHERE name = ?
      LIMIT 1
    SQL

    DB[:conn].execute(sql, name).map do |row|
      self.new_from_db(row)
    end.first
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

  def self.find_or_create_by(attributes)
    name = attributes[:name]
    breed = attributes[:breed]

    dog = find_by(name: name, breed: breed)

    if dog.nil?
      self.create(attributes: attributes)
    else
      dog
    end
  end
end