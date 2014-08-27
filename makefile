SHELL = /bin/bash
BROWSERIFY = ./node_modules/.bin/browserify
LESSC = ./node_modules/.bin/lessc
NODEMON = ./node_modules/.bin/nodemon
TARGET = -e ./lib/index.js -t partialify -o ./build/index.js

JSCS = ./node_modules/.bin/jscs --reporter=inline
JSHINT = ./node_modules/.bin/jshint
MOCHA = ./node_modules/.bin/mocha
MOCHAPHANTOMJS = ./node_modules/.bin/mocha-phantomjs
PHANTOMJS = ./node_modules/.bin/phantomjs

BUILDLOCALE = ./build-i18n.js

# ------------------------------------------------------------------------------

build:
	@make clean
	$(BUILDLOCALE) ./locale > ./lib/langs.js
	$(BROWSERIFY) $(TARGET)
	rm -rf ./lib/langs.js
	cp -av ./static/. ./build/
	cat `find ./views -name "*.less"` > ./build/styles/views.less
	cat `find ./components -name "*.less"` > ./build/styles/components.less
	cat `find ./blocks -name "*.less"` > ./build/styles/blocks.less
	$(LESSC) -x ./build/styles/common.less ./build/styles/common.css
	node_modules/node-appcache-generator/bin/node-appcache \
		--manifest ./build/manifest.appcache \
		--directory ./build/ \
		--fallback "/ fallback.html" \
		--network "*,http://*,https://*"

clean:
	rm -rf ./build
	mkdir build

dev:
	$(NODEMON) -x "make build -f" makefile -e "js,less,html,json" --ignore "build/*"

serve:
	node ./test/fixtures/server.js

# ------------------------------------------------------------------------------

lint:
	$(JSHINT) ./lib/*.js
	$(JSHINT) ./blocks/**/*.js
	$(JSHINT) ./components/**/*.js
	$(JSHINT) ./views/**/*.js
	$(JSHINT) ./test/integration/*.js
	$(JSHINT) ./test/unit/*.js

	$(JSCS) ./lib/*.js
	$(JSCS) ./blocks/**/*.js
	$(JSCS) ./components/**/*.js
	$(JSCS) ./views/**/*.js
	$(JSCS) ./test/integration/*.js
	$(JSCS) ./test/unit/*.js

unit:
	$(MOCHA) -R spec ./test/unit/*.js

integration:
	$(MOCHAPHANTOMJS) -p $(PHANTOMJS) -R spec ./test/fixtures/runner.html

test:
	@make lint
	@make unit
	@make integration

# ------------------------------------------------------------------------------

.PHONY: build i18n clean dev serve lint unit integration test