# FROM ruby
FROM ruby:2.3.8
RUN gem install bundler
RUN git clone https://github.com/bdavid/premailer-api.git /opt/premailer-api
WORKDIR /opt/premailer-api
RUN chmod u+x premailer-api.rb
RUN bundle install
RUN gem install nokogiri
EXPOSE 4567
CMD ["ruby", "premailer-api.rb", "-o", "0.0.0.0"]
