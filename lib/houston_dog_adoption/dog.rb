require_relative '../houston_dog_adoption.rb'
require 'pry'

class HoustonDogAdoption::Dog

  attr_accessor :name, :breed, :gender, :age, :details_popup, :size, :color, :bio, :months_old, :age_group, :valid_breeds, :valid_colors
  @@all = []

  def self.all
    @@all
  end

  def add_dog_attributes(dog_data_hash)
    dog_data_hash.each {|key, value| self.send(("#{key}="), value)}
  end

  def initialize(dog_data)
    add_dog_attributes(dog_data)
    self.class.all << self
  end

  def self.create_from_collection(dog_array_of_hashes)
    dog_array_of_hashes.each {|dog_data_hash| new(dog_data_hash)}
  end

  def self.age_groups
    HoustonDogAdoption::Dog.all.each do |dog|
      if dog.age.include?('years')
        if dog.age.include?('month')
          years, months = dog.age.split(' years ')
        else
          years = dog.age
        end
      elsif dog.age.include?('year ')
        if dog.age.include?('month')
          years, months = dog.age.split(' year ')
        else
          years = dog.age
        end
      elsif dog.age[/\syear\z/]
        years = dog.age
      else
        years = 0
        months = dog.age
      end
      dog.months_old = years.to_i*12 + months.to_i
    end

  #grammatical possibilities
  # 1 year
  # 2 years
  # 10 years
  # 1 year 1 month
  # 1 year 2 months
  # 2 years 1 month
  # 10 years 1 month
  # 2 years 2 months
  # 10 years 2 months

    HoustonDogAdoption::Dog.all.each do |dog|
      dog.age_group = '1' if (1..12).include?(dog.months_old)
      dog.age_group = '2' if (13..24).include?(dog.months_old)
      dog.age_group = '3' if (25..36).include?(dog.months_old)
      dog.age_group = '4' if (37..48).include?(dog.months_old)
      dog.age_group = '5' if (49..60).include?(dog.months_old)
      dog.age_group = '6' if (61..72).include?(dog.months_old)
      dog.age_group = '7' if (73..84).include?(dog.months_old)
      dog.age_group = '8' if (85..96).include?(dog.months_old)
      dog.age_group = '9' if (97..108).include?(dog.months_old)
      dog.age_group = '10' if (109..120).include?(dog.months_old)
      dog.age_group = '11' if (121..132).include?(dog.months_old)
      dog.age_group = '12' if (133..144).include?(dog.months_old)
    end

  end

  def self.valid_breeds
    HoustonDogAdoption::Dog.all.each {|dog| dog.valid_breeds = dog.breed.split(/[,\/]/).map {|breed| breed.strip}}
  end

  def self.all_valid_breeds(dog_arr)
    dog_arr.map {|dog| dog.valid_breeds}.flatten.uniq
  end

  def self.valid_colors
    HoustonDogAdoption::Dog.all.each {|dog| dog.valid_colors = dog.color.split('/')}
  end

  def self.all_valid_colors(dog_arr)
    dog_arr.map {|dog| dog.valid_colors}.flatten.uniq
  end


end
