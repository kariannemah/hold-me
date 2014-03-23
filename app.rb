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

  if page.css('span.bibHolds').text == ''
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

  @ebook_urls = {}
  @urls.each do |key,value|
    if key.to_s.split.include?('[electronic') || key.to_s.split.include?('(Online)')
      @ebook_urls[key] = value
    end
  end

  unless @ebook_urls == {}
    @ebook_urls.each do |key, value|
      ebook_page = Nokogiri::HTML(open(value))
      @ebook_urls[key] = ebook_page.css('table.bibLinks').first.children[1].children[0].children[1].attributes['href'].value
    end

    ebook_holds = @ebook_urls

    @eholds = {}

    ebook_holds.each do |key, value|
      third_party_page =  Nokogiri::HTML(open(value))
      if ! /overdrive/.match(value).nil?
        # overdrive
        @copies = /\d/.match(third_party_page.css('ul.copies-expand.tog-close.details-ul-exp').children[2].text).to_s
        @holds = /\d/.match(third_party_page.css('ul.copies-expand.tog-close.details-ul-exp').children[4].text).to_s
      elsif ! /axis/.match(value).nil?
        # axis 360
        @copies = /\d/.match(third_party_page.css('div.ActionPanelInfo').children[1].text).to_s
        if /\d/.match(third_party_page.css('div.ActionPanelInfo').children[5].text).to_s == ''
          @holds = '0'
        else
          @holds = /\d/.match(third_party_page.css('div.ActionPanelInfo').children[5].text).to_s
        end
      else
        # other ebook platforms
        @holds = ''
        @copies = ''
      end
      @eholds[value] = [@holds, @copies]
    end
  end

  erb :index
end