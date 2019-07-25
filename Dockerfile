FROM ruby
RUN gem install bundler
RUN git clone https://github.com/bdavid/premailer-api.git /opt/premailer-api
WORKDIR /opt/premailer-api
RUN bundle install
EXPOSE 4567
CMD ["./premailer-api.rb", "-o", "0.0.0.0"]
