include dev/.env
export
export PATH := $(shell pwd)/tmp:$(PATH)

.ONESHELL .PHONY: up update-box destroy-box remove-tmp clean example
.DEFAULT_GOAL := up

#### Pre requisites ####
install:
	 mkdir -p tmp;(cd tmp; git clone --depth=1 https://github.com/fredrikhgrelland/vagrant-hashistack.git; cd vagrant-hashistack; make install); rm -rf tmp/vagrant-hashistack

check_for_consul_binary:
ifeq (, $(shell which consul))
	$(error "No consul binary in $(PATH), download the consul binary from here :\n https://www.consul.io/downloads\n\n' && exit 2")
endif

#### Development ####
# start commands
dev: update-box
	SSL_CERT_FILE=${SSL_CERT_FILE} CURL_CA_BUNDLE=${CURL_CA_BUNDLE} ANSIBLE_ARGS='--skip-tags "test"' vagrant up --provision

custom_ca:
ifdef CUSTOM_CA
	cp -f ${CUSTOM_CA} docker/conf/certificates/
endif

up: update-box custom_ca
ifdef CI # CI is set in Github Actions
	SSL_CERT_FILE=${SSL_CERT_FILE} CURL_CA_BUNDLE=${CURL_CA_BUNDLE} vagrant up --provision
else
	SSL_CERT_FILE=${SSL_CERT_FILE} CURL_CA_BUNDLE=${CURL_CA_BUNDLE} CUSTOM_CA=${CUSTOM_CA} ANSIBLE_ARGS='--extra-vars "local_test=true"' vagrant up --provision
endif

test: clean up

template-example: update-box custom_ca
ifdef CI # CI is set in Github Actions
	cd template_example; SSL_CERT_FILE=${SSL_CERT_FILE} CURL_CA_BUNDLE=${CURL_CA_BUNDLE} vagrant up --provision
else
	if [ -f "docker/conf/certificates/*.crt" ]; then cp -f docker/conf/certificates/*.crt template_example/docker/conf/certificates; fi
	cd template_example; SSL_CERT_FILE=${SSL_CERT_FILE} CURL_CA_BUNDLE=${CURL_CA_BUNDLE} CUSTOM_CA=${CUSTOM_CA} ANSIBLE_ARGS='--extra-vars "local_test=true"' vagrant up --provision
endif

# clean commands
destroy-box:
	vagrant destroy -f

remove-tmp:
	rm -rf ./tmp

clean: destroy-box remove-tmp

# helper commands
update-box:
	@SSL_CERT_FILE=${SSL_CERT_FILE} CURL_CA_BUNDLE=${CURL_CA_BUNDLE} vagrant box update || (echo '\n\nIf you get an SSL error you might be behind a transparent proxy. \nMore info https://github.com/fredrikhgrelland/vagrant-hashistack/blob/master/README.md#proxy\n\n' && exit 2)

proxy-redash: check_for_consul_binary
	consul connect proxy -service=proxy-to-redash -upstream=redash-server-service:7070 -log-level=TRACE

proxy-presto: check_for_consul_binary
	consul connect proxy -service=proxy-to-presto -upstream=presto:8080 -log-level=TRACE

proxy-minio: check_for_consul_binary
	consul connect proxy -service=proxy-to-minio -upstream=minio:9090 -log-level=TRACE

OS = $(shell uname)
PWD = $(shell pwd)
connect-to-all:
ifeq ($(OS), Linux)
	gnome-terminal -- make proxy-redash
	gnome-terminal -- make proxy-presto
	gnome-terminal -- make proxy-minio
endif
ifeq ($(OS), Darwin)
	osascript -e 'tell application "Terminal" to do script "cd $(PWD); make proxy-redash"'
	osascript -e 'tell application "Terminal" to do script "cd $(PWD); make proxy-presto"'
	osascript -e 'tell application "Terminal" to do script "cd $(PWD); make proxy-minio"'
endif
ifeq ($(OS),)
	@echo "You are not on a Linux or Mac. You will need to run the proxies separately:\n  make proxy-redash\n  make proxy-presto\n  make proxy-minio"
endif

template_init:
	#
	@echo "${RED}\nWarning! This will clean your template. Do you want to continue? [y/n]${RESET}" ; \
	read answer; \
	if [ "$$answer" != "y" ]; then \
		echo "Aborting!" ; \
		exit 1 ; \
	fi

	@echo "\nStarting to clean your template!"

	@for folder in "template_example" "example/vagrant_box_example" "CHANGELOG.md" ; do \
		echo "Deleting: $$folder " ; \
		rm -rf $$folder && echo "${GREEN}Success${RESET}" || echo "${RED}Failed${RESET}" ; \
	done

	@echo -n "\nMoving README.md to .github/template_specific as old_README.md "
	mv README.md .github/template_specific/old_README.md && echo "${GREEN}Success${RESET}" || echo "${RED}Failed${RESET}"

	@echo -n "Moving GETTING_STARTED/ to .github/template_specific/GETTING_STARTED "
	mv GETTING_STARTED .github/template_specific/ && echo "${GREEN}Success${RESET}" || echo "${RED}Failed${RESET}"

	@echo -n "\nCreating a clean README.md "
	cat .github/template_specific/README_template.md >> README.md && echo "${GREEN}Success${RESET}" || echo "${RED}Failed${RESET}"

	@echo -n "Creating a clean CHANGELOG.md "
	echo "# Changelog\n\n## 0.0.1 [UNRELEASED]\n\n###Added\n\n###Changed\n\n###Fixed\n" >> CHANGELOG.md && echo "${GREEN}Success${RESET}" || echo "${RED}Failed${RESET}"

	@echo "${BLUE}\nDone! You are all set to start developing!${RESET}"
	@echo "${YELLOW}\nPS! If you want to keep a deleted folder, you can undo by running:\n  git reset HEAD <file/folder>\n  git checkout -- <file/folder>${RESET}"