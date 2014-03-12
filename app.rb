require 'rubygems'
require 'sinatra'
require 'nokogiri'
require 'open-uri'
require 'mechanize'

get '/' do
  erb :index
end


post '/' do
  @book = params[:book]

  agent = Mechanize.new
  page = agent.get('http://sfpl.org')

  agent.page.forms[0].fields[1].value = @book

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

  @books = {}
  book_links.each do |url|
    page = Nokogiri::HTML(open(url))
    if ! page.css('span.bibHolds').text.empty?
      @books[page.css('td.bibInfoData').text.split("\n")[1]] = page.css('span.bibHolds').text
    end
  end

  erb :index
end