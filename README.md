# CourseApp

## Getting started
```
rvm use 3.3.4
bundle install
cp config/database.yml.example config/database.yml
vim config/database.yml # setup username, password for database
bin/rails db:create db:migrate db:seed
bin/rails s
```
