FROM ruby
RUN bundle version
RUN bundle update --bundler
RUN bundle config --global frozen 1
RUN git clone https://github.com/bdavid/premailer-api.git /opt/premailer-api
WORKDIR /opt/premailer-api
RUN bundle install
EXPOSE 4567
CMD ["premailer-api.rb", "-o", "0.0.0.0"]
