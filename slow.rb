require 'curb'
require 'nokogiri'
require 'csv'
require 'xpath'
require "random_user_agent"

$user_agent = RandomUserAgent.randomize

puts "Please, enter URL:"
category_page = gets.chomp

puts "Please, enter file name:"
csv_name = gets.chomp

$csv_name = csv_name.to_s + ".csv"


def clear
	if Gem.win_platform?
		system 'cls'
	else
		system 'clear'
	end
end


def load_url(link)
	http = Curl.get(link) do |http|                   
		http.headers['User-Agent'] = $user_agent
	end
	doc = Nokogiri::HTML(http.body_str)
	return doc
end


page_count = 2
page_tmp = category_page
count = 1

page_doc = load_url(category_page)
$page_number = page_doc.xpath('//span[@class="heading-counter"]').text.strip.to_i
category_name = page_doc.xpath('/html/body/div[2]/div/div[1]/div/div/div[2]/h1/span').text.strip

$page_number+=1

all_products = Array.new

until count >= $page_number do
	page = load_url(category_page)
	page.xpath('//a[@class="product-name"]/@href').each do |page|
		show_product = "Getting product №" + count.to_s + " from category " + category_name.to_s + "..."
		puts show_product

		weight_product = Array.new
		price_product = Array.new
		name_string = Array.new

		product_link = load_url(page)
		product_name = product_link.xpath('//input[@name="product_name"]/@value')
		product_img = product_link.xpath('//*[@id="bigpic"]/@src') 

		product_weight = product_link.xpath('//span[@class="radio_label"]').each do |weight|
			weight_product<<weight.text.strip
		end

		product_price = product_link.xpath('//span[@class="price_comb"]').each do |price|
			price_product<<price.text.strip
		end

		i = 0 
		while i.to_i<(weight_product.length.to_i) do
			name_string[i] = product_name.to_s + " " + weight_product[i].to_s 
			all_products.push(name_string[i], price_product[i], product_img)
			i = i.to_i + 1
		end

		count = count.to_i + 1
		clear
	end 
	category_page = page_tmp
	category_page = category_page + "?p=" + page_count.to_s
	page_count = page_count.to_i + 1
end 


CSV.open($csv_name, "a+") do |csv|
	csv<<["Name", "Price", "Image"]
	all_products.each_slice(3) do |arr|
		csv<<arr
	end
end


path_to_csv = "CSV file: " + Dir.getwd.to_s + "/" + $csv_name.to_s
puts path_to_csv