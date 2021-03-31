require 'sinatra'
require 'sinatra/streaming'
require 'premailer'
require 'json'
require 'redis'

REDIS_HTML_EXPIRY = 600

REDIS_URL = ENV['REDIS_URL']
REDIS_DB = ENV['REDIS_DB']
if REDIS_URL.nil? || REDIS_DB.nil?
  puts "Environment variables REDIS_URL and REDIS_DB are required."
  exit
end

configure do
  set :environment, 'production'
end

post '/api/0.1/documents' do
  url = params['url']
  html = params['html']
  
  if url.nil?
    premailer = Premailer.new(html, :with_html_string => true)
  else
    premailer = Premailer.new(url)
  end
  
  Dir.mkdir('html') unless File.exists?('html')
  
  # Write the HTML output to Redis
  htmlFilename = "#{SecureRandom.uuid}.html"
  htmlContent = premailer.to_inline_css
  redis = Redis.new(url: REDIS_URL, db: REDIS_DB)
  redis.setex(htmlFilename, REDIS_HTML_EXPIRY, htmlContent)

  htmlPath = "html/#{htmlFilename}"
  content_type :json
  { :documents => { :html => "#{url(htmlPath)}" } }.to_json
end

get '/html/:filename' do |filename|
  redis = Redis.new(url: REDIS_URL, db: REDIS_DB)
  content = redis.get(filename)

  if content.nil?
    status 404
  else
    content
  end
end

error do
  logger.error env['sinatra.error'].message
  status 500
end
