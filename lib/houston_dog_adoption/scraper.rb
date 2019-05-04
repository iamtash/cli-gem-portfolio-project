require 'pry'
require 'open-uri'
require 'nokogiri'
require_relative '../houston_dog_adoption.rb'

class HoustonDogAdoption::Scraper

  BASEURL = 'https://ws.petango.com/webservices/adoptablesearch/'

  def self.scrape_adoptables_page(adoptables_url)
    adoptables_page = Nokogiri::HTML(open(adoptables_url))
    cards = adoptables_page.css("td.list-item").select {|card| card.css("a").attribute("href")}

    cards.collect do |card|
      {
        name: card.css("div.list-animal-name").text,
        breed: card.css("div.list-animal-breed").text,
        gender: card.css("div.list-animal-sexSN").text.split('/').first,
        age: card.css("div.list-animal-age").text, 
        details_popup: BASEURL + card.css("a").attribute("href").value[/[']\S+[']/][1..-2]
      }

    end
  end

  def self.scrape_details(details_popup)
    details = Nokogiri::HTML(open(details_popup))
    {
      size: details.css('span#lblSize').text,
      color: details.css('span#lblColor').text,
      bio: details.css('span#lbDescription').text
    }
  end
end


#HoustonDogAdoption::Scraper.scrape_adoptables_page('https://ws.petango.com/webservices/adoptablesearch/wsAdoptableAnimals.aspx?species=Dog&sex=A&agegroup=All&location=&site=&onhold=A&orderby=Name&colnum=6&css=https://ws.petango.com/WebServices/adoptablesearch/css/styles.css&authkey=hxym4cn4tnbm0ys26jo20ebskdhb1t3wyfgabvt03wqup07vcd&recAmount=&detailsInPopup=Yes&featuredPet=Exclude&stageID=')
#binding.pry
