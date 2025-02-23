init:
	bundle install
	cp .env.dist .env

go:
	ruby main.rb

build:
	docker build -t artifactmmo .

run:
	docker run -it --rm \
	--env-file=.env \
	-v ${PWD}/services:/app/services \
	-v ${PWD}/models:/app/models \
	-v ${PWD}/models:/app/models \
	-v ${PWD}/main.rb:/app/main.rb \
	artifactmmo