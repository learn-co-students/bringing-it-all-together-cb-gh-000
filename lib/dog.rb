class Dog
  attr_accessor :id, :name, :breed

  def initialize(id: nil, name:, breed:, attributes: {})
    if valid_attributes?(attributes)
      @id = attributes[:id]
      @name = attributes[:name]
      @breed = attributes[:breed]
    else
      @id = id
      @name = name
      @breed = breed
    end
  end

  # Instance Methods

  def valid_attributes?(attributes)
    case attributes
      when !attributes.has_key?(id)
        false
      when !attributes.has_key?(name)
        false
      when !attributes.has_key?(breed)
        false
      else
        true
    end
  end

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

  def self.find_by_id(id)

  end
end