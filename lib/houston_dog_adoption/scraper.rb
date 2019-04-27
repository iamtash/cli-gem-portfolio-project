require 'pry'
require 'open-uri'
require 'nokogiri'
require_relative '../houston_dog_adoption.rb'

class HoustonDogAdoption::Scraper

  def self.scrape_adoptables_page(adoptables_url)
    adoptables_page = Nokogiri::HTML(open(adoptables_url))
    dogs = adoptables_page.css("td.list-item")
    #adoptables url - https://ws.petango.com/webservices/adoptablesearch/wsAdoptableAnimals.aspx?species=Dog&sex=A&agegroup=All&location=&site=&onhold=A&orderby=Name&colnum=6&css=https://ws.petango.com/WebServices/adoptablesearch/css/styles.css&authkey=hxym4cn4tnbm0ys26jo20ebskdhb1t3wyfgabvt03wqup07vcd&recAmount=&detailsInPopup=Yes&featuredPet=Exclude&stageID=

    dogs.collect do |dog|
      {
        name: dog.css("div.list-animal-name").text
        breed: dog.css("div.list-animal-breed").text
        gender: dog.css("div.list-animal-sexSN").text.split('/').first
        age: dog.css("div.list-animal-age").text
        details_popup: dog.css("a").attribute("href").value
      }
    end
  end
end


HoustonDogAdoption::Scraper.scrape_adoptables_page("https://www.houstonhumane.org/adopt-a-pet/dog-adoptables")
binding.pry
