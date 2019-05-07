#CLI Controller
require_relative '../houston_dog_adoption.rb'
require 'pry'

class HoustonDogAdoption::CLI

  attr_accessor :gender_choice, :by_gender_arr, :breed_choice, :by_breed_arr

  def call
    make_dogs
    add_dog_details
    puts "Thank you for your interest in adopting a dog! Let's try to identify your perfect fur-ever friend!"
    choose_gender
    choose_breed
    narrow_search
  end


  def make_dogs
    dogs_array = HoustonDogAdoption::Scraper.scrape_adoptables_page('https://ws.petango.com/webservices/adoptablesearch/wsAdoptableAnimals.aspx?species=Dog&sex=A&agegroup=All&location=&site=&onhold=A&orderby=Name&colnum=6&css=https://ws.petango.com/WebServices/adoptablesearch/css/styles.css&authkey=hxym4cn4tnbm0ys26jo20ebskdhb1t3wyfgabvt03wqup07vcd&recAmount=&detailsInPopup=Yes&featuredPet=Exclude&stageID=')
    HoustonDogAdoption::Dog.create_from_collection(dogs_array)
  end


  def add_dog_details
    HoustonDogAdoption::Dog.all.each do |dog|
      details = HoustonDogAdoption::Scraper.scrape_details(dog.details_popup)
      dog.add_dog_attributes(details)
    end
    HoustonDogAdoption::Dog.age_groups
  end


  def choose_gender
    self.gender_choice = nil
    until ['male', 'female', ''].include?(gender_choice)
      puts "Are you looking for a male or female? Hit the 'Enter' key if you're not sure."
      self.gender_choice = gets.chomp.downcase

      case gender_choice
      when 'male', 'female'
        self.by_gender_arr = HoustonDogAdoption::Dog.all.select {|dog| dog.gender.downcase == gender_choice}
        puts "Here are our #{by_gender_arr.length} #{gender_choice}s looking for a fur-ever home:"
      when ""
        self.by_gender_arr = HoustonDogAdoption::Dog.all
        puts "You have a total of #{by_gender_arr.length} dogs to choose from:"
      else
        puts "Oops! Make sure to type 'male', 'female', or hit 'Enter'!"
      end

    end

    by_gender_arr.each {|dog| puts "#{dog.name}: #{dog.gender.downcase}, #{dog.age} old, #{dog.color.downcase} #{dog.breed}"}
  end


  def choose_breed
    self.breed_choice = 'nil'

    until by_gender_arr.any? {|dog| dog.breed.downcase.include?(breed_choice)} || breed_choice == ''
      puts "Type a breed you are hoping for or hit 'Enter' if you don't have a preference."
      self.breed_choice = gets.chomp.downcase

      if !by_gender_arr.any? {|dog| dog.breed.downcase.include?(breed_choice)}
        if breed_choice == ''
          puts "Here are some dogs you might be interested in:"
          self.by_breed_arr = by_gender_arr
        else
          puts "Oops! Try typing a different breed."
        end
      elsif breed_choice == 'mix'
        puts "Here are some #{breed_choice}es you might be interested in:"
        self.by_breed_arr = by_gender_arr.select {|dog| dog.breed.downcase.include?(breed_choice)}
      else
        puts "Here are some #{breed_choice}s you might be interested in:"
        self.by_breed_arr = by_gender_arr.select {|dog| dog.breed.downcase.include?(breed_choice)}
      end

    end

    self.breed_choice = 'dog' if breed_choice == ''
    by_breed_arr.each {|dog| puts "#{dog.name}:  #{dog.gender.downcase}, #{dog.age} old, #{dog.color.downcase} #{dog.breed}"}
    one_match?(by_breed_arr)
  end


  def narrow_search
    input = nil

    until ['age', 'color', 'size', 'none'].include?(input)
      puts "Would you like to narrow your search by age, color, size, or none?"
      input = gets.chomp.downcase

      case input
      when 'age'
        self.choose_age(by_breed_arr)
      when 'color'
        self.choose_color(by_breed_arr)
      when 'size'
        self.choose_size(by_breed_arr)
      when 'none'
        self.choose_dog(by_breed_arr)
      else
        puts "Oops! Be sure to type 'age', 'color', 'size', or 'none'."
      end
    end

  end


  def choose_dog(dog_arr)
    dog_choice = nil

    until dog_arr.any? {|dog| dog.name.downcase == dog_choice}
      dog_arr.each {|dog| puts "#{dog.name}: #{dog.size.downcase}  #{dog.gender.downcase}, #{dog.age} old, #{dog.color.downcase} #{dog.breed}"}
      puts "Enter the name of the dog from the list above you would like to consider for adoption."
      dog_choice = gets.chomp.downcase
      if !dog_arr.any? {|dog| dog.name.downcase == dog_choice}
        puts "Oops! Be sure to type the name of a dog you're interested in from the above list."
      end
    end

    the_dog = dog_arr.find {|dog| dog.name.downcase == dog_choice.downcase}
    report_match(the_dog)
  end

  def report_match(dog)
    if dog.gender == 'Male'
      puts "You have chosen #{dog.name}! He is a #{dog.size.downcase.strip}, #{report_age(dog)}-old #{dog.color.downcase} #{dog.breed}."
    else
      puts "You have chosen #{dog.name}! She is a #{dog.size.downcase.strip}, #{report_age(dog)}-old #{dog.color.downcase} #{dog.breed}."
    end
    puts "Here is #{dog.name}'s bio: #{dog.bio}" if dog.bio != ""
    puts "Please contact us ASAP to set up a meet-and-greet with your dream pup!"
    exit
  end

  def report_age(dog)
    dog.age[-1] == 's' ? dog.age[0..-2] : dog.age
  end


  def choose_age(dog_arr)
    age_choice = nil

    until dog_arr.any? {|dog| dog.age_group == age_choice}
      puts "Enter the maximum number of years of age you are hoping for in a dog."
      age_choice = gets.chomp
      if !dog_arr.any? {|dog| dog.age_group == age_choice}
        if !(1..12).include?(age_choice.to_i)
          puts "Oops! Make sure to enter a number between 1 and 12."
        else
          puts "Sorry! We don't have any #{gender_choice} #{breed_choice}s that meet that criteria. Please enter a different age."
        end
      end
    end

      by_age_arr = dog_arr.select {|dog| dog.age_group == age_choice}
      one_match?(by_age_arr)
      choose_dog(by_age_arr)
  end


  def choose_color(dog_arr)
    color_choice = 'nil'

    until dog_arr.any? {|dog| dog.color.downcase.include?(color_choice)}
      puts "What coat color strikes your fancy?"
      color_choice = gets.chomp.downcase
      if !dog_arr.any? {|dog| dog.color.downcase.include?(color_choice)}
        puts "Sorry, none of our #{gender_choice} #{breed_choice}s are that color! Please enter a different color."
      end
    end

    by_color_arr = dog_arr.select {|dog| dog.color.downcase.include?(color_choice)}
    one_match?(by_color_arr)
    choose_dog(by_color_arr)

  end

  def choose_size(dog_arr)
    size_choice = nil

    until dog_arr.any? {|dog| dog.size.downcase == size_choice}
      puts "Are you looking for a small, medium, or large dog?"
      size_choice = gets.chomp.downcase
      if !dog_arr.any? {|dog| dog.size.downcase == size_choice}
        if ['small', 'medium', 'large'].include?(size_choice)
          puts "Sorry, we don't have any #{size_choice} #{gender_choice} #{breed_choice}s. Please enter a different size."
        else
          puts "Oops! Make sure to enter one of the three sizes 'small', 'medium', or 'large'."
        end
      end
    end

    by_size_arr = dog_arr.select {|dog| dog.size.downcase == size_choice}
    one_match?(by_size_arr)
    choose_dog(by_size_arr)
  end


  def one_match?(dog_arr)
    if dog_arr.length == 1
      puts "You have one match!"
      report_match(dog_arr.first)
    end
  end

end
