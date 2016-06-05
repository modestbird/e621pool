require 'rest-client'
require 'json'

$links = []

def fetch(pool)
  puts 'Checking connection...'
  begin
    RestClient.get 'https://e621.net/post/index.json?limit=1'
  rescue
    puts 'Found connection troubles, setting up proxy'
    RestClient.proxy = 'https://proxy.antizapret.prostovpn.org:3128'
  end

  response = RestClient.get "https://e621.net/pool/show.json?id=#{pool}"
  response = JSON.parse(response.to_s)

  # Sanitizing folder name to fit filesystem requirements and to look good
  # Yeah, i know, code looks pretty bad, but works fine
  $poolname = response['name'].gsub(/[^\w\.]/, '_').tr('.', ' ').tr('_', ' ').split.join(' ')
  puts "Pool ##{pool}: #{$poolname}"

  if Dir.exist? $poolname
    puts "Folder \"#{$poolname}\" already exist, if you want to continue - press any key. If not, terminate script using Ctrl+C."
    STDIN.gets
  end

  pages = (response['post_count'].to_f / 24).ceil

  puts "Posts: #{response['post_count']}, pages: #{pages}"

  puts '===================================================='

  puts 'Fetching pages'
  pages.times do |i|
    get_imgs(pool, i + 1)
  end

  puts '===================================================='

  puts 'Downloading pictures...'
  download_pics

  puts '===================================================='

  puts 'Done!'
end

def get_imgs(pool, page)
  puts "Fetching page #{page} of pool ##{pool}"
  response = RestClient.get "https://e621.net/pool/show.json?id=#{pool}&page=#{page}"
  response = JSON.parse(response.to_s)
  response['posts'].each do |post|
    $links.push post['file_url']
  end
end

def download_pics
  dirname = ARGV[0] + ' - ' + $poolname
  Dir.mkdir dirname unless Dir.exist? $poolname
  $links.each_with_index do |item, index|
    name = dirname + '/' + (index + 1).to_s + File.extname(item)
    puts "Downloading #{item} to \"#{name}\""
    File.open(name, 'w') do |f|
      response = RestClient.get item do |str|
        f.write str
      end
    end
  end
end

fetch ARGV[0]
