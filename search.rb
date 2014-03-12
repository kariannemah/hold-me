require 'rubygems'
require 'nokogiri'
require 'open-uri'
require 'mechanize'

# search by call number?

agent = Mechanize.new
agent.user_agent_alias = 'Mac Safari'

page = agent.get('http://sfpl.org')

print "Look for a book: "
title = gets.chomp

agent.page.forms[0].fields[1].value = title

result = agent.page.forms[0].submit
homepage = "http://sflib1.sfpl.org"

book_links = []
result.links.each do |link|
  if link.text.include? 'Is it available?'
   substring = link.href
   url = homepage + substring
   book_links << url
  end
end

books = []
book_links.each do |url|
  page = Nokogiri::HTML(open(url))
  if ! page.css('span.bibHolds').text.empty?
    books << page.css('td.bibInfoData').text.split("\n")[1] + page.css('span.bibHolds').text
  end
end

p books
