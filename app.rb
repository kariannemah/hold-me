require 'rubygems'
require 'sinatra'
require 'mechanize'
require 'nokogiri'
require 'open-uri'
require 'thread'


get '/' do
  erb :index
end

post '/' do
  @book = params[:book]

  def search_submitter(search_term, search_url)
    agent = Mechanize.new
    page = agent.get(search_url)
    page.forms[0].fields[1].value = search_term
    page.forms[0].submit
  end

  def get_holds(url)
    page = Nokogiri::HTML(open(url))
    title = page.css('td.bibInfoData').text.split("\n")[1].to_sym
    @books[title] = {sfpl_url: url}
    @books[title][:holds] = page.css('span.bibHolds').text
  end

  def overdrive_hold_info(page, dom_element)
    /\d/.match(page.css('ul.copies-expand.tog-close.details-ul-exp').children[dom_element].text).to_s
  end

  def axis_hold_info(page, dom_element)
    /\d/.match(page.css('div.ActionPanelInfo').children[dom_element].text).to_s
  end

  result = search_submitter(@book,'http://sfpl.org')
  url = result.uri

  @link_plus_url = search_submitter(@book, 'http://csul.iii.com/')

  page = Nokogiri::HTML(open(url))
  @books = {}

  if page.css('span.bibHolds').text == ''
    links = result.links.keep_if { |link| link.text.include? 'Is it available?' }
    threads = links.map do |link|
      Thread.new do
        url = 'http://sflib1.sfpl.org' + link.href + '/'
        get_holds(url)
      end
    end
    threads.each { |thread| thread.join }
  else
    get_holds(url)
  end

  threads = @books.select {|key, value| key.to_s.split.include?('[electronic') || key.to_s.split.include?('(Online)') }.map do |key,value|
    Thread.new do
      page = Nokogiri::HTML(open(value[:sfpl_url]))
      ebook_platform_url = page.css('table.bibLinks').first.children[1].children[0].children[1].attributes['href'].value
      value[:ebook] = {url: ebook_platform_url}
      ebook_page =  Nokogiri::HTML(open(ebook_platform_url))

      if /overdrive/.match(ebook_platform_url)
        value[:ebook][:copies] = overdrive_hold_info(ebook_page, 2)
        value[:ebook][:holds] = overdrive_hold_info(ebook_page, 4)
      elsif /axis/.match(ebook_platform_url)
        value[:ebook][:copies] = axis_hold_info(ebook_page, 1)
        (axis_hold_info(ebook_page, 5) == '') ?
          value[:ebook][:holds] = '0' :
          value[:ebook][:holds] = axis_hold_info(ebook_page, 5)
      else
        # other ebook platforms
        value[:ebook][:holds] = ''
        value[:ebook][:copies] = ''
      end
    end
  end

  threads.each { |thread| thread.join }

  erb :index
end
