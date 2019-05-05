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
    until gender_choice == 'boy' || gender_choice == 'girl' || gender_choice == 'no preference'
      puts "Are you looking for a boy or girl? Type 'no preference' if you're not sure."
      gender_choice = gets.chomp.downcase

      case gender_choice
      when "boy"
        self.by_gender_arr = HoustonDogAdoption::Dog.all.select {|dog| dog.gender == "Male"}
      when "girl"
        self.by_gender_arr = by_gender = HoustonDogAdoption::Dog.all.select {|dog| dog.gender == "Female"}
      when 'no preference'
        self.by_gender_arr = HoustonDogAdoption::Dog.all
      else
        puts "Oops! Make sure to type 'boy' or 'girl', or 'no preference'!"
      end
    end

    if gender_choice == 'no preference'
      puts "You have a total of #{by_gender_arr.length} dogs to choose from:"
    else
      puts "Here are our #{by_gender_arr.length} #{gender_choice}s looking for a fur-ever home:"
    end

    by_gender_arr.each {|dog| puts "#{dog.name}:  #{dog.gender.downcase}, #{dog.age} old, #{dog.color} #{dog.breed}"}
  end

  def choose_breed
    puts "What breed are you looking for?"
    breed_choice = gets.chomp.downcase
    binding.pry
    by_gender_arr.select {|dog| dog.breed.downcase.include?(breed_choice)}
  end

  def cli
    puts "Thank you for your interest in adopting a dog! Let's try to identify your perfect fur-ever friend!"
    choose_gender
    choose_breed
  end


end
