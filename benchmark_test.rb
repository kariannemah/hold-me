require 'rubygems'
require 'nokogiri'
require 'mechanize'
require 'open-uri'
require 'benchmark'

if ARGV[0] == 'threads'
  require 'thread'

  total_time = Benchmark.realtime do
    @search_term = 'infinite jest'

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

    def get_hold_info(platform, page, dom_element)
      if platform == 'overdrive'
        element = 'ul.copies-expand.tog-close.details-ul-exp'
      else
        element = 'div.ActionPanelInfo'
      end
      /\d/.match(page.css(element).children[dom_element].text).to_s
    end

    result = search_submitter(@search_term,'http://sfpl.org')
    url = result.uri

    @link_plus_url = search_submitter(@search_term, 'http://csul.iii.com/')

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
          value[:ebook][:copies] = get_hold_info('overdrive', ebook_page, 2)
          value[:ebook][:holds] = get_hold_info('overdrive', ebook_page, 4)
        elsif /axis/.match(ebook_platform_url)
          value[:ebook][:copies] = get_hold_info('axis', ebook_page, 1)
          (get_hold_info('axis', ebook_page, 5) == '') ?
            value[:ebook][:holds] = '0' :
            value[:ebook][:holds] = get_hold_info('axis', ebook_page, 5)
        else
          # other ebook platforms
          value[:ebook][:holds] = ''
          value[:ebook][:copies] = ''
        end
      end
    end

    threads.each { |thread| thread.join }

  end

  puts "\nParsed in #{total_time} seconds"
  puts @books

else
  total_time = Benchmark.realtime do
    @book = 'infinite jest'

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
      result.links.keep_if { |link| link.text.include? 'Is it available?' }.map do |link|
        url = 'http://sflib1.sfpl.org' + link.href + '/'
        get_holds(url)
      end
    else
      get_holds(url)
    end

    @books.each do |key,value|
      if key.to_s.split.include?('[electronic') || key.to_s.split.include?('(Online)')
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
  end
  puts "\nParsed in #{total_time} seconds"
end
