require_relative '../houston_dog_adoption.rb'

class HoustonDogAdoption::Dog

  attr_reader: :name, :breed, :gender, :age, :details_popup, :size, :color, :bio
  @@all = []

  def self.all
    @@all
  end

  def add_dog_attributes(dog_data_hash)
    dog_data_hash.each {|key, value| self.send(("#{key}="), value)}
  end

  def self.create_from_collection(dog_array_of_hashes)
    dog_array_of_hashes.each {|dog_data_hash| new(dog_data_hash)}
  end

  def initialize(dog_data)
    self.class.all << self
  end



end
