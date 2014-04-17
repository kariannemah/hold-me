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
  @search_term = params[:book]

  def submit_search(search_term, search_url)
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

  def get_overdrive_holds(page)
      open_page = Nokogiri::HTML(open(page))
      /\d/.match(open_page.css('ul.copies-expand.tog-close.details-ul-exp').children[4].text).to_s
  end

  def get_overdrive_copies(page)
    open_page = Nokogiri::HTML(open(page))
    /\d/.match(open_page.css('ul.copies-expand.tog-close.details-ul-exp div.row.details-lib-copies').text).to_s
  end

  def get_axis_copies(page)
    open_page = Nokogiri::HTML(open(page))
    if open_page.css('div.DetailInfoHold.CopiesInfo').children[1].nil?
      /\d/.match(open_page.css('div.DetailInfo.CopiesInfo').children[1].text).to_s
    else
      /\d/.match(open_page.css('div.DetailInfoHold.CopiesInfo').children[1].text).to_s
    end
  end

  def get_axis_holds(page)
    open_page = Nokogiri::HTML(open(page))
    if open_page.css('div.DetailInfoHold.CopiesInfo').children[1].nil?
      '0'
    else
      /\d/.match(open_page.css('div.DetailInfoHold.CopiesInfo').children[6].text).to_s
    end
  end

  result = submit_search(@search_term,'http://sfpl.org')
  url = result.uri

  @link_plus_url = submit_search(@search_term, 'http://csul.iii.com/')

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
      ebook_platform_url = page.css('table.bibLinks tr td').children[1].attributes['href'].value
      value[:ebook] = {url: ebook_platform_url}

      if /overdrive/.match(ebook_platform_url)
        value[:ebook][:copies] = get_overdrive_copies(ebook_platform_url)
        value[:ebook][:holds] = get_overdrive_holds(ebook_platform_url)
      elsif /axis/.match(ebook_platform_url)
        value[:ebook][:copies] = get_axis_copies(ebook_platform_url)
        value[:ebook][:holds] = get_axis_holds(ebook_platform_url)
      else
        value[:ebook][:copies] = ''
        value[:ebook][:holds] = ''
      end
    end
  end

  threads.each { |thread| thread.join }

  erb :index
end
