#!/usr/bin/env ruby

require 'sinatra'
require 'sinatra/streaming'
require 'premailer'
require 'json'
require 'redis'

REDIS_HTML_EXPIRY = 600

REDIS_HOST = ENV['REDIS_HOST']
REDIS_PORT = ENV['REDIS_PORT']
REDIS_DB = ENV['REDIS_DB']
if REDIS_HOST.nil? || REDIS_PORT.nil? || REDIS_DB.nil?
  puts "Environment variables REDIS_HOST, REDIS_PORT, REDIS_DB and REDIS_PASSWORD are required."
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
  redis = Redis.new(:host => REDIS_HOST, :port => REDIS_PORT, :db => REDIS_DB, :password => REDIS_PASSWORD)
  redis.setex(htmlFilename, REDIS_HTML_EXPIRY, htmlContent)

  htmlPath = "html/#{htmlFilename}"
  content_type :json
  { :documents => { :html => "#{url(htmlPath)}" } }.to_json
end

get '/html/:filename' do |filename|
  redis = Redis.new(:host => REDIS_HOST, :port => REDIS_PORT, :db => REDIS_DB, :password => REDIS_PASSWORD)
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
