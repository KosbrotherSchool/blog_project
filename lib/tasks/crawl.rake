require 'net/http'


namespace :crawl do

	task :crawl_comic_books => :environment do

		# test
		# test test

		url = URI.parse('http://www.99comic.com/lists/1/')
		req = Net::HTTP::Get.new(url.to_s)
		res = Net::HTTP.start(url.host, url.port) {|http|
			http.request(req)
		}
		content = res.body
		doc = Nokogiri::HTML(content)

		doc.css(".TopList_11 li").each do |comic|

			puts "Title"
			puts comic.children[0].attr("title")

			puts "Pic_Link"
			puts comic.children[0].children[0].attr("src")

			puts "Alias"
			puts comic.children[1].children[0].attr("title")

			puts "Comic Link"
			puts comic.children[1].children[0].attr("href")

			puts "Current State"
			puts comic.children[2].children[0].children[0].to_s

			puts "Update_date"
			puts comic.children[2].children[1].to_s

		end

	end

	task :crawl_comic_one_book => :environment do

		url = URI.parse('http://www.99comic.com/comic/99168/')
		req = Net::HTTP::Get.new(url.to_s)
		res = Net::HTTP.start(url.host, url.port) {|http|
			http.request(req)
		}
		content = res.body
		doc = Nokogiri::HTML(content)

		puts "Author"
		puts doc.css(".en_info").children[1].children[1].children[0].to_s

		puts "Type"
		puts doc.css(".en_info").children[3].children[1].children[0].to_s

		puts "Value"
		puts doc.css(".en_info").children[5].children[2].children[0].to_s

		puts "Value Nums"
		puts doc.css(".en_info").children[5].children[4].children[0].to_s

		puts "Current State"
		puts doc.css(".en_info").children[7].children[1].children[0].to_s

		puts "Visit Times"
		puts doc.css(".en_info").children[9].children[1].children[0].to_s

		puts "Upload Date"
		puts doc.css(".en_info").children[11].children[1].to_s

		puts "latest"
		puts doc.css(".en_info").children[13].children[1].children[0].to_s

		puts "Update date"
		puts doc.css(".en_info").children[15].children[1].to_s

		puts "Info"
		puts doc.css(".cCon").children.to_s.gsub(" ","")

		puts "Manga List"
		doc.css(".cVolList").children.each do |episode|
			
			puts "link"
			puts episode.children[0].attr("href")

			puts "title"
			puts episode.children[0].children.to_s

		end 

	end

	task :crawl_comic_pic => :environment do
		
		include Capybara::DSL
  	Capybara.current_driver = :selenium_chrome
  	Capybara.app_host = 'http://www.99comic.com'
  	page.visit '/comics/168o207051/'
  	page_no = Nokogiri::HTML(page.html)
  	puts page_no.css("#imgCurr")[0].attr('src')

	end 

	task :crawl_data => :environment do

		# crawl mangafox 
		url = URI.parse('http://mangafox.me/manga/naruto_gaiden_the_seventh_hokage/v01/c010.1/12.html')
		req = Net::HTTP::Get.new(url.to_s)
		res = Net::HTTP.start(url.host, url.port) {|http|
			http.request(req)
		}
		content = res.body
		doc = Nokogiri::HTML(content)
		pic_link = doc.css("#viewer img")[0].first[1]

	end


end