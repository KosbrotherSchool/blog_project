require 'net/http'

namespace :crawl_tv_time do

	task :crawl_recommend_tv => :environment do

		# action 動作科幻
		# comedy 喜劇
		# terrible 恐怖片
		# drama 劇情片
		# love 愛情
		# family 家庭
		# IMDB IMDB 推薦
		# HOT 本週熱門節目
		# Feature 強檔推薦
		contral_param = 0

		url = URI.parse('http://www.niotv.com/i_index.php?cont=mulity_promote')
		req = Net::HTTP::Get.new(url.to_s)
		res = Net::HTTP.start(url.host, url.port) {|http|
			http.request(req)
		}
		doc = Nokogiri::HTML(res.body, nil, 'utf-8')
		movies = doc.css("div.moviebox").css("table").css("tr td").css("table")

		movie_type_index = 1
		movies.each do |movie|

			title = movie.css("td.movietext b")[0].text
			pic_link = movie.css("td.pict a img")[0].attr("src")
			channel = movie.css("td.copy_movietext a")[0].text
			type_str = movie.css("td.copy_movietext")[1].text
			date = movie.css("td.copy_movietext")[2].children[0].text
			play_time = movie.css("td.copy_movietext")[2].children[2].text

			class_type = ""

			if contral_param == 0
				if title.index(".")
					contral_param = 1
				end

				if type_str.index("動作") || type_str.index("科幻")
					class_type = "動作科幻片"
				elsif type_str.index("喜劇")
					class_type = "喜劇片"
				elsif type_str.index("懸疑") || type_str.index("靈異") || type_str.index("驚悚")
					class_type = "恐怖片"
				elsif type_str.index("劇情")
					class_type = "劇情片"
				elsif type_str.index("愛情")
					class_type = "愛情片"
				elsif type_str.index("動畫") || type_str.index("家庭") || type_str.index("青春")
					class_type = "家庭片"
				end
			end
			
			if contral_param == 1
				if movie.css("td.movietext")[0].text.index("[") && movie.css("td.movietext")[0].text.index("]")
					contral_param = 2
				end
			end
			
			if contral_param == 2 && !movie.css("td.movietext")[0].text.index("[") && !movie.css("td.movietext")[0].text.index("]")
				contral_param = 3
			end

			if contral_param == 1
				class_type = "IMDB 推薦"
		 	elsif contral_param == 2
		 		class_type = "本週熱門節目"
		 	elsif contral_param == 3
		 		class_type = "強檔預告"
			end

			puts title
			puts pic_link
			puts channel
			puts type_str
			puts class_type
			puts date + " " + play_time

		end

	end

	task :crawl_taiwan_tv => :environment do

		puts "Enter the start date. ex:2015-08-15"
		start_date = STDIN.gets.chomp
		puts "Enter the end date. ex:2015-08-17"
		puts "start date 跟 end date 必須同一個月"
		end_date = STDIN.gets.chomp
		nums = end_date[8..9].to_i - start_date[8..9].to_i
		(0..nums).each do |num|

			str = ""
			plus_num = start_date[8..9].to_i + num
			if plus_num < 10
				str = "0" + plus_num.to_s
			else
				str = plus_num.to_s
			end

			current_date = start_date[0..7] + str

			puts current_date

			# http://tv.atmovies.com.tw/tv/attv.cfm?action=todaytime&group_id=M&tday=2015-08-16

			url = URI.parse('http://tv.atmovies.com.tw/tv/attv.cfm?action=todaytime&group_id=L'+"&tday="+current_date)
			req = Net::HTTP::Get.new(url.to_s)
			res = Net::HTTP.start(url.host, url.port) {|http|
				http.request(req)
			}
			doc = Nokogiri::HTML(res.body, nil, 'utf-8')
			programs = doc.css("table.at9")

			p_index = 1;
			programs.each do |program|

				title = ""
				case p_index
				when 1
					title = "LS TIME電影台"
				when 2
					title = "衛視電影台"
				when 3
					title = "東森電影台"
				when 4
					title = "緯來電影台"
				end
				puts title
				p_index = p_index + 1

				program.css("tr").first.remove
				program.css("tr").each do | pro_time |
					time = pro_time.css("td.at9")[0].children[0].to_s
					program_title = pro_time.css("font.at11")[0].children[0].to_s.gsub(" ","")
					puts time + " " + program_title
				end

			end

		end

	end

	task :crawl_western_tv => :environment do

		puts "Enter the start date. ex:2015-08-15"
		start_date = STDIN.gets.chomp
		puts "Enter the end date. ex:2015-08-17"
		puts "start date 跟 end date 必須同一個月"
		end_date = STDIN.gets.chomp
		nums = end_date[8..9].to_i - start_date[8..9].to_i
		(0..nums).each do |num|

			str = ""
			plus_num = start_date[8..9].to_i + num
			if plus_num < 10
				str = "0" + plus_num.to_s
			else
				str = plus_num.to_s
			end

			current_date = start_date[0..7] + str

			puts current_date

			# http://tv.atmovies.com.tw/tv/attv.cfm?action=todaytime&group_id=M&tday=2015-08-16

			url = URI.parse('http://tv.atmovies.com.tw/tv/attv.cfm?action=todaytime&group_id=M'+"&tday="+current_date)
			req = Net::HTTP::Get.new(url.to_s)
			res = Net::HTTP.start(url.host, url.port) {|http|
				http.request(req)
			}
			doc = Nokogiri::HTML(res.body, nil, 'utf-8')
			programs = doc.css("table.at9")

			p_index = 1;
			programs.each do |program|

				title = ""
				case p_index
				when 1
					title = "HBO電影台"
				when 2
					title = "東森洋片台"
				when 3
					title = "AXN動作台"
				when 4
					title = "STAR MOVIES"
				when 5
					title = "Cinemax"
				when 6
					title = "好萊塢電影台"
				when 7	
					title = "Star World "
				end
				puts title
				p_index = p_index + 1

				program.css("tr").first.remove
				program.css("tr").each do | pro_time |
					time = pro_time.css("td.at9")[0].children[0].to_s
					program_title = pro_time.css("font.at11")[0].children[0].to_s.gsub(" ","")
					puts time + " " + program_title
				end

			end

		end

	end
	
end
