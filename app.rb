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
  homepage = 'http://sflib1.sfpl.org'

  @books = {}

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
      @books[title] = {:sfpl_url => url}
      @books[title][:holds] = page.css('span.bibHolds').text
    end
  else
    title = page.css('td.bibInfoData').text.split("\n")[1].to_sym
    @books[title] = {:sfpl_url => url}
    @books[title][:holds] = page.css('span.bibHolds').text
  end

  link_agent = Mechanize.new
  link_page = link_agent.get('http://csul.iii.com/')
  link_page.forms[0].fields[1].value = @book
  link_result = link_page.forms[0].submit
  @link_plus_url = link_result.uri

  @books.each do |key,value|
    if value.is_a? Hash
      if key.to_s.split.include?('[electronic') || key.to_s.split.include?('(Online)')
        ebook_page = Nokogiri::HTML(open(value[:sfpl_url]))
        platform_url = ebook_page.css('table.bibLinks').first.children[1].children[0].children[1].attributes['href'].value
        value[:ebook] = {:url => platform_url }
        third_party_page =  Nokogiri::HTML(open(platform_url))

          if ! /overdrive/.match(platform_url).nil?
            # overdrive
            value[:ebook][:copies] = /\d/.match(third_party_page.css('ul.copies-expand.tog-close.details-ul-exp').children[2].text).to_s
            value[:ebook][:holds] = /\d/.match(third_party_page.css('ul.copies-expand.tog-close.details-ul-exp').children[4].text).to_s
          elsif ! /axis/.match(platform_url).nil?
            # axis 360
            value[:ebook][:copies] = /\d/.match(third_party_page.css('div.ActionPanelInfo').children[1].text).to_s
            if /\d/.match(third_party_page.css('div.ActionPanelInfo').children[5].text).to_s == ''
              value[:ebook][:holds] = '0'
            else
              value[:ebook][:holds] = /\d/.match(third_party_page.css('div.ActionPanelInfo').children[5].text).to_s
            end
          else
            # other ebook platforms
            value[:ebook][:holds] = ''
            value[:ebook][:copies] = ''
          end
      end
    end
  end

  erb :index
end