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
end