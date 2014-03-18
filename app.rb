require 'rubygems'
require 'sinatra'
require 'nokogiri'
require 'mechanize'
require 'open-uri'

get '/' do
  erb :index
end


post '/' do
  @book = params[:book]

  agent = Mechanize.new
  page = agent.get('http://sfpl.org')
  page.forms[0].fields[1].value = @book
  result = page.forms[0].submit
  homepage = "http://sflib1.sfpl.org"

  @books = {}
  @urls = {}

  url = result.uri
  page = Nokogiri::HTML(open(url))

  if page.css('span.bibHolds').text == ""
    book_links = []
    result.links.each do |link|
      if link.text.include? 'Is it available?'
        substring = link.href
        url = homepage + substring + '/'
        book_links << url
      end
    end

    book_links.each do |url|
      page = Nokogiri::HTML(open(url))
      title = page.css('td.bibInfoData').text.split("\n")[1].to_sym
      @books[title] = page.css('span.bibHolds').text
      @urls[title] = url
    end
  else
    title = page.css('td.bibInfoData').text.split("\n")[1].to_sym
    @books[title] = page.css('span.bibHolds').text
    @urls[title] = url
  end

  link_agent = Mechanize.new
  link_page = link_agent.get('http://csul.iii.com/')
  link_page.forms[0].fields[1].value = @book
  link_result = link_page.forms[0].submit
  @link_url = link_result.uri

  erb :index
end