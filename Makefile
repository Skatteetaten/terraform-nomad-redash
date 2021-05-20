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

# Builds the vagrant box and the example/redash_one_node
up-redash-one-node: update-box custom_ca
ifeq ($(GITHUB_ACTIONS),true) # Always set to true when GitHub Actions is running the workflow. You can use this variable to differentiate when tests are being run locally or by GitHub Actions.
	SSL_CERT_FILE=${SSL_CERT_FILE} CURL_CA_BUNDLE=${CURL_CA_BUNDLE} ANSIBLE_ARGS='--extra-vars "\"ci_test=true mode=redash_one_node\""' vagrant up --provision
else
	SSL_CERT_FILE=${SSL_CERT_FILE} CURL_CA_BUNDLE=${CURL_CA_BUNDLE} CUSTOM_CA=${CUSTOM_CA} ANSIBLE_ARGS='--extra-vars "\"mode=redash_one_node\""' vagrant up --provision
endif

# Builds the vagrant box and the example/redash_trino_cluster
up-redash-trino: update-box custom_ca
ifeq ($(GITHUB_ACTIONS),true) # Always set to true when GitHub Actions is running the workflow. You can use this variable to differentiate when tests are being run locally or by GitHub Actions.
	SSL_CERT_FILE=${SSL_CERT_FILE} CURL_CA_BUNDLE=${CURL_CA_BUNDLE} ANSIBLE_ARGS='--extra-vars "\"ci_test=true mode=redash_trino_cluster\""' vagrant up --provision
else
	SSL_CERT_FILE=${SSL_CERT_FILE} CURL_CA_BUNDLE=${CURL_CA_BUNDLE} CUSTOM_CA=${CUSTOM_CA} ANSIBLE_ARGS='--extra-vars "\"mode=redash_trino_cluster\""' vagrant up --provision
endif

#up: update-box custom_ca
#ifdef CI # CI is set in Github Actions
#	SSL_CERT_FILE=${SSL_CERT_FILE} CURL_CA_BUNDLE=${CURL_CA_BUNDLE} vagrant up --provision
#else
#	SSL_CERT_FILE=${SSL_CERT_FILE} CURL_CA_BUNDLE=${CURL_CA_BUNDLE} CUSTOM_CA=${CUSTOM_CA} ANSIBLE_ARGS='--extra-vars "local_test=true"' vagrant up --provision
#endif

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

proxy-redash:
	consul intention create -token=master redash-local redash
	consul connect proxy -token master -service redash-local -upstream redash-server:5000 -log-level debug

proxy-trino:
	consul intention create -token=master trino-local trino
	consul connect proxy -token master -service trino-local -upstream trino:8080 -log-level debug

trino-cli:
	CID=$$(docker run --rm -d --network host consul:1.8 connect proxy -token master -service trino-local -upstream trino:8080)
	docker run --rm -it --network host trinodb/trino:${TRINO_VERSION} trino --server localhost:8080 --http-proxy localhost:8080 --catalog hive --schema default --user trino --debug
	docker rm -f $$CID

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
