reset:
	rm -rf apps/*
	git checkout hof.settings.json

build:
	./create-service.rb Wibble

rebuild:
	make reset
	make build && npm run start:dev
