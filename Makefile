init:
	bundle install
	cp .env.dist .env

go:
	ruby main.rb