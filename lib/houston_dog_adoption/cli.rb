#CLI Controller
require_relative '../houston_dog_adoption.rb'
require 'pry'

class HoustonDogAdoption::CLI

  attr_accessor :by_gender_arr, :by_breed_arr

  def call
    make_dogs
    add_dog_details
    cli
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
  end


  def choose_gender
    gender_choice = nil
    until ['boy', 'girl', 'no preference'].include?(gender_choice)
      puts "Are you looking for a boy or girl? Type 'no preference' if you're not sure."
      gender_choice = gets.chomp.downcase

      case gender_choice
      when "boy"
        self.by_gender_arr = HoustonDogAdoption::Dog.all.select {|dog| dog.gender == "Male"}
        puts "Here are our #{by_gender_arr.length} #{gender_choice}s looking for a fur-ever home:"
      when "girl"
        self.by_gender_arr = by_gender = HoustonDogAdoption::Dog.all.select {|dog| dog.gender == "Female"}
        puts "Here are our #{by_gender_arr.length} #{gender_choice}s looking for a fur-ever home:"
      when 'no preference'
        self.by_gender_arr = HoustonDogAdoption::Dog.all
        puts "You have a total of #{by_gender_arr.length} dogs to choose from:"
      else
        puts "Oops! Make sure to type 'boy', 'girl', or 'no preference'!"
      end

    end

    by_gender_arr.each {|dog| puts "#{dog.name}: #{dog.gender.downcase}, #{dog.age} old, #{dog.color.downcase} #{dog.breed}"}
  end


  def choose_breed
    breed_choice = nil

    while breed_choice == nil
      puts "What breed are you looking for? Enter a breed or 'no preference'."
      breed_choice = gets.chomp.downcase

      if !by_gender_arr.any? {|dog| dog.breed.downcase.include?(breed_choice)}
        puts "Oops! Try typing something like 'labrador', 'poodle', or 'German shepherd'."
        breed_choice = nil
      elsif breed_choice == 'mix'
        puts "Here are some #{breed_choice}es you might be interested in:"
      else
        puts "Here are some #{breed_choice}s you might be interested in:"
      end

    end

    self.by_breed_arr = by_gender_arr.select {|dog| dog.breed.downcase.include?(breed_choice)}
    by_breed_arr.each {|dog| puts "#{dog.name}:  #{dog.gender.downcase}, #{dog.age} old, #{dog.color.downcase} #{dog.breed}"}
  end


  def narrow_search
    input = nil

    until ['age', 'color', 'size', 'none'].include?(input)
      puts "Would you like to narrow your search by age, color, size, or none?"
      input = gets.chomp.downcase

      case input
      when 'age'
        choose_age
      when 'color'
        choose_color
      when 'size'
        choose_size
      when 'none'
        choose_dog(by_breed_arr)
      else
        puts "Oops! Be sure to type 'age', 'color', 'size', or 'none'."
      end
    end

  end


  def choose_dog(dog_arr)
    dog_choice = nil
    while dog_choice == nil
      dog_arr.each {|dog| puts "#{dog.name}: #{dog.size.downcase}  #{dog.gender.downcase}, #{dog.age} old, #{dog.color.downcase} #{dog.breed}"}
      puts "Enter the name of the dog from the list above you would like to consider for adoption."
      dog_choice = gets.chomp
      if !dog_arr.any? {|dog| dog.name.downcase == dog_choice.downcase}
        puts "Oops! Be sure to type the name of a dog you're interested in from the above list."
        dog_choice = nil
      end
    end

    the_dog = dog_arr.find {|dog| dog.name.downcase == dog_choice.downcase}
    puts "You have chosen #{the_dog.name}, a #{the_dog.size}, #{the_dog.age}-old, #{the_dog.gender}, #{the_dog.color.downcase} #{the_dog.breed}."
    puts "Here is #{the_dog.name}'s bio: #{the_dog.bio}" if the_dog.bio != ""
    puts "Please contact us ASAP to set up a meet-and-greet with your dream pup!"
  end


  def choose_age
    age_choice = nil

    until (1..9).include?(age_choice.to_i)
      puts "Enter the maximum number of years of age you are hoping for in a dog."
      age_choice = gets.chomp
      if !(1..9).include?(age_choice.to_i)
        puts "Oops! Make sure to enter a number between 1 and 9."
      end
    end

      by_age_arr = by_breed_arr.select {|dog| dog.age_group == age_choice}
      choose_dog(by_age_arr)
  end


  def choose_color
    color_choice = nil

    until by_breed_arr.any? {|dog| dog.color.downcase.include?(color_choice)}
      puts "What coat color strikes your fancy?"
      color_choice = gets.chomp.downcase
      if !by_breed_arr.any? {|dog| dog.color.downcase.include?(color_choice)}
        puts "None of our pups are that color! Please enter a different color."
      end
    end

    by_color_arr = by_breed_arr.select {|dog| dog.color.downcase.include?(color_choice)}
    choose_dog(by_color_arr)

  end

  def choose_size
    size_choice = nil

    until by_breed_arr.any? {|dog| dog.size.downcase == size_choice}
      puts "Are you looking for a small, medium, or large dog?"
      size_choice = gets.chomp.downcase
      if !by_breed_arr.any? {|dog| dog.size.downcase == size_choice}
        puts "Oops! Make sure to enter one of the three sizes 'small', 'medium', or large'."
      end
    end

    by_size_arr = by_breed_arr.select {|dog| dog.size == size_choice}
    choose_dog(by_size_arr)
  end


  def cli
    puts "Thank you for your interest in adopting a dog! Let's try to identify your perfect fur-ever friend!"
    choose_gender
    choose_breed
    narrow_search
  end


end
