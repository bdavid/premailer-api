FROM ruby
RUN gem install bundler
RUN git clone https://github.com/bdavid/premailer-api.git /opt/premailer-api
WORKDIR /opt/premailer-api
RUN bundle config --global frozen 1
RUN bundle install
RUN cat Gemfile.lock
EXPOSE 4567
CMD ["premailer-api.rb", "-o", "0.0.0.0"]
