class Dog
  attr_accessor :id, :name, :breed

  def initialize(id: nil, name:, breed:, attributes: {})
    attributes.each do |attribute, value|
      self.send("#{attribute}=", value)
    end

    @id ||= id
    @name ||= name
    @breed ||= breed
  end

  # Instance Methods

  def save

  end

  # Class Methods

  def self.create_table

  end

  def self.drop_table

  end

  def self.create(attributes)
    dog = self.new(attributes)
    dog.save
    dog
  end

  def self.new_from_db(row)
    id = row[0]
    name = row[1]
    breed = row[2]
    self.new(id, name, breed)
  end

  def self.find_by_id(id)
    sql = <<-SQL
      SELECT name, breed FROM dogs
      WHERE id = ?
      LIMIT 1
    SQL

    DB[:conn].execute(sql, id).map do |row|
      self.new_from_db(row)
    end.first
  end
end