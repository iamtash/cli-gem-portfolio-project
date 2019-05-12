#CLI Controller
require_relative '../houston_dog_adoption.rb'
require 'pry'

class HoustonDogAdoption::CLI

  attr_accessor :size_choice, :selection, :breed_choice, :age_choice, :color_choice, :gender_choice, :dog_choice

  def call
    make_dogs
    add_dog_details
    puts '********************************************'
    puts "Thank you for your interest in adopting a dog! Let's try to identify your perfect fur-ever friend!"
    puts '********************************************'
    search
  end

  def search
    choose_size(HoustonDogAdoption::Dog.all)
    choose_breed(selection)
    one_match?(selection)
    narrow_search(selection)
    pick_a_dog
  end

  def pick_a_dog
    one_match?(selection)
    choose_dog(selection)
    report_match(dog_choice)
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
    HoustonDogAdoption::Dog.valid_breeds
    HoustonDogAdoption::Dog.valid_colors
  end


  def choose_size(dog_arr)
    self.size_choice = 'nil'
    until dog_arr.any? {|dog| dog.size.downcase == size_choice} || size_choice == ''
      puts ''
      puts "Are you looking for a small, medium, or large dog? Hit the 'Enter' key if you're not sure."
      puts ''
      self.size_choice = gets.chomp.downcase
      if !dog_arr.any? {|dog| dog.size.downcase == size_choice}
        if ['small', 'medium', 'large'].include?(size_choice)
          puts ''
          puts "Sorry, we don't have any #{size_choice} #{gender_choice} #{breed_choice}s. Please enter a different size."
          puts ''
        elsif size_choice == ''
          self.selection = dog_arr
          puts "We have #{selection.length} dogs looking for fur-ever homes!"
        else
          puts ''
          puts "Oops! Make sure to enter one of the three sizes 'small', 'medium', or 'large'."
        end
      else
        self.selection = dog_arr.select {|dog| dog.size.downcase == size_choice}
        puts ''
        puts "We have #{selection.length} #{size_choice} adoptable dogs!"
        puts ''
        puts '--------------------------------------------'
      end
    end
  end


  def choose_breed(dog_arr)
    self.breed_choice = 'nil'
    until HoustonDogAdoption::Dog.all_valid_breeds(dog_arr).map {|breed| breed.downcase}.include?(breed_choice) || breed_choice == ''
      puts ''
      puts "Type a breed you want or hit 'Enter' if you don't have a preference.\nType 'breeds' if you want to see what we have."
      puts ''
      self.breed_choice = gets.chomp.downcase

      if breed_choice == ''
        puts "You still have #{dog_arr.length} dogs to choose from!"
      elsif !HoustonDogAdoption::Dog.all_valid_breeds(dog_arr).map {|breed| breed.downcase}.include?(breed_choice)
        if breed_choice == 'breeds'
          puts ''
          puts HoustonDogAdoption::Dog.all_valid_breeds(HoustonDogAdoption::Dog.all).sort
        else
          puts ''
          puts "Oops! Try typing a different breed."
        end
      else
        self.selection = dog_arr.select {|dog| dog.valid_breeds.map {|breed| breed.downcase}.include?(breed_choice)}
        puts ''
        if size_choice == ''
          if selection.length == 1
            puts "We have #{selection.length} #{breed_choice} available for adoption!"
          else
            puts "We have #{selection.length} #{self.breed_choice_plural} available for adoption!"
          end
        else
          if selection.length == 1
            puts "We have #{selection.length} #{size_choice} #{breed_choice} available for adoption!"
          else
            puts "We have #{selection.length} #{size_choice} #{self.breed_choice_plural} available for adoption!"
          end
        end

      end
      puts ''
      puts '--------------------------------------------'

    end

    self.breed_choice = 'dog' if breed_choice == ''

  end

  def breed_choice_plural
    if breed_choice.end_with?('x', 's')
      breed_choice + 'es'
    elsif %w(Large (over 44 lbs fully grown), Medium (up to 44 lbs fully grown), Standard Smooth Haired, Silky).include?(breed_choice)
      breed_choice + 'dogs'
    elsif breed_choice.end_with?('y')
      breed_choice.chomp('y') + 'ies'
    else
      breed_choice + 's'
    end
  end


  def narrow_search(dog_arr)
    input = nil

    until ['age', 'color', 'gender', 'none'].include?(input)
      puts ''
      puts "Would you like to narrow your search by age, color, gender, or none?"
      puts ''
      input = gets.chomp.downcase

      case input
      when 'age'
        self.choose_age(dog_arr)
      when 'color'
        self.choose_color(dog_arr)
      when 'gender'
        self.choose_gender(dog_arr)
      when 'none'
        self.pick_a_dog
      else
        puts ''
        puts "Oops! Be sure to type 'age', 'color', 'gender', or 'none'."
      end
    end

  end

  def narrow_search_again?
    input = nil
    until ['yes', 'no'].include?(input)
      puts ''
      puts "Would you like to filter your search further?"
      puts ''
      input = gets.chomp.downcase
      if input == 'yes'
        narrow_search(selection)
        pick_a_dog
      elsif input != 'no'
        puts ''
        puts "Type 'yes' if you want to refine your search or 'no' if not."
      end
    end
  end


  def choose_age(dog_arr)
    self.age_choice = 'nil'

    until dog_arr.any? {|dog| dog.age_group == age_choice}
      puts ''
      puts "Enter the age in years you are looking for in a dog."
      puts ''
      self.age_choice = gets.chomp

      if !dog_arr.any? {|dog| dog.age_group == age_choice}
        if (1..12).include?(age_choice.to_i)
          puts ''
          if age_choice == '1'
            puts "Sorry! We don't have any #{size_choice} #{self.breed_choice_plural} that are #{age_choice} year old or younger. Please enter a different age."
          else
            puts "Sorry! We don't have any #{size_choice} #{self.breed_choice_plural} that are #{age_choice} years old. Please enter a different age."
          end
        else
          puts ''
          puts "Oops! Make sure to enter a number between 1 and 12."
        end
      end
    end

    self.selection = dog_arr.select {|dog| dog.age_group == age_choice}
  end


  def choose_color(dog_arr)
    self.color_choice = 'nil'
    until HoustonDogAdoption::Dog.all_valid_colors(dog_arr).map {|color| color.downcase}.include?(color_choice)
      puts ''
      puts "What coat color strikes your fancy?"
      puts ''
      self.color_choice = gets.chomp.downcase
      if !HoustonDogAdoption::Dog.all_valid_colors(dog_arr).map {|color| color.downcase}.include?(color_choice)
        puts ''
        puts "Sorry, none of our #{gender_choice} #{self.breed_choice_plural} are that color! Please enter a different color."
      end
    end

    self.selection = dog_arr.select {|dog| dog.valid_colors.map {|color| color.downcase}.include?(color_choice)}
  end

  def choose_gender(dog_arr)
    self.gender_choice = 'nil'
    until ['male', 'female', ''].include?(gender_choice)
      puts ''
      puts "Are you looking for a male or female?"
      puts ''
      self.gender_choice = gets.chomp.downcase

      case gender_choice
      when 'male', 'female'
        self.selection = dog_arr.select {|dog| dog.gender.downcase == gender_choice}
      else
        puts "Oops! Make sure to type 'male' or 'female'!"
      end

    end
  end


  def one_match?(dog_arr)
    if dog_arr.length == 1
      puts ''
      puts "You have one match!"
      report_match(dog_arr.first)
    end
  end


  def choose_dog(dog_arr)
    puts ''
    puts "We have #{selection.length} adoptable dogs that meet your desired criteria:"
    puts ''
    dog_arr.each {|dog| puts "#{dog.name}: #{dog.size.downcase.strip} #{dog.gender.downcase.strip}, #{dog.age} old, #{dog.color.downcase} #{dog.breed}"}
    puts ''
    puts '--------------------------------------------'

    self.narrow_search_again?

    dog_choice = nil

    until dog_arr.any? {|dog| dog.name.downcase == dog_choice}
      puts ''
      puts "Enter the name of the dog from the list above you would like to consider for adoption."
      puts ''
      dog_choice = gets.chomp.downcase
      if !dog_arr.any? {|dog| dog.name.downcase == dog_choice}
        puts ''
        puts "Oops! Be sure to type the name of a dog you're interested in from the above list."
        puts ''
      end
    end

    self.dog_choice = dog_arr.find {|dog| dog.name.downcase == dog_choice.downcase}

  end

  def report_match(dog)
    puts ''
    puts '============================================'

    if dog.gender == 'Male'
      puts ''
      puts "You have chosen #{dog.name}! He is a #{dog.size.downcase}, #{dog.age.delete('s')}-old #{dog.color.downcase} #{dog.breed}."
    else
      puts ''
      puts "You have chosen #{dog.name}! She is a #{dog.size.downcase}, #{dog.age.delete('s')}-old #{dog.color.downcase} #{dog.breed}."
    end

    if dog.bio != ''
      puts ''
      puts "Here is #{dog.name}'s bio:"
      puts ''
      puts "#{dog.bio}"
    end
    puts ''
    puts "Please contact us ASAP to set up a meet-and-greet with your dream pup!"
    puts ''
    puts '============================================'
    pick_another_dog?
  end


  def pick_another_dog?
    input = 'nil'
    until ['yes','no'].include?(input)
      puts ''
      puts 'Would you like help finding another adoptable dog?'
      puts ''
      input = gets.chomp.downcase

      case input
      when 'yes'
        self.search
      when 'no'
        puts ''
        puts '********************************************'
        puts 'Thank you for choosing to adopt! Have a wonderful day!'
        puts '********************************************'
        exit
      else
        puts ''
        puts "Oops! Make sure to type 'yes' or 'no'."
      end
    end
  end

end
