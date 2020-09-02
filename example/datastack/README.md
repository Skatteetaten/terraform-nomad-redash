<!-- markdownlint-disable MD041 -->
<!-- markdownlint-disable MD028 -->
<p align="center"><img width="100px" src="https://www.svgrepo.com/show/12675/bar-chart.svg" align="center" alt="Vagrant-hashistack" /><h2 align="center">Datastack with Redash</h2></p>

## Content
1. [Introduction](#introduction)
2. [Requirements](#requirements)
3. [Starting Datastack](#starting-datastack)
4. [A note about MinIO](#a-note-about-minio)
5. [Access Redash, MinIO and Presto](#access-redash-minio-and-presto)
6. [Consul Connect and Proxies](#consul-connect-and-proxies)

## Introduction
This example provisions a full datastack.

Provisioned stack:
- [MinIO](https://min.io/) (storage)
- [Presto](https://prestodb.io/) (SQL-engine)
- [Redash](https://redash.io/) (Interface for writing SQL to Presto)

## Requirements
See [prerequisites](../../template_README.md#install-prerequisites)

### Starting Datastack
Run
```makefile
make up
```
in your terminal to provision the datastack.

### A note about MinIO
This example will set up _two_ MinIOs. There is one bundled with the vagrant-box that is used by the developers of this repository for _development_. In addition to this, this example sets up another MinIO that is intended to be used together with Redash and Presto. Read [Access Redash, MinIO and Presto](#access-redash-minio-and-presto) on how to connect to the latter.


### Access Redash, MinIO and Presto
When provisioning of the example is finished you can then open up access to Redash, Presto, and MinIO by running
```makefile
make connect-to-all
```

> :warning: [gnome-terminal](https://help.gnome.org/users/gnome-terminal/stable/) is required for the command above. If you do not have gnome-terminal you can run `make proxy-redash`, `make proxy-presto`, and `make proxy-presto` in three separate terminal windows to achieve the same as `make connect-to-all`.

You will now have access to Redash, Presto, and MinIO on the addresses below:

|Service|Address|
|:--|:--|
|Redash|[localhost:7070](localhost:7070)|
|Presto|[localhost:8080](localhost:8080)|
|MinIO|[localhost:9090](localhost:9090)|

Read [Consul Connect and Proxies](#consul-connect-and-proxies) if you want to know more about why you have to run `make connect-to-all`.

### Consul Connect and Proxies
All services set up via this example utilise a feature called [Consul Connect](https://www.consul.io/docs/connect). The services are segregated and are placed in their own bubbles. The only way to channelise the flow of information in and out of these bubbles is by using consul-connect integrated proxies. When all the information travels in and out through one feature that we control (our consul-connect enabled proxies), it is a lot easier to secure the communication between services.

> :bulb: We use the [Envoy proxy](https://www.envoyproxy.io/), which is natively supported by consul-connect.

In order to access any of these "service-bubbles" from our machine we need to start proxies that can send information from our computer to the proxies within the "service-bubbles". This is what `make proxy-redash`, `make proxy-presto`, and `make proxy-minio` all do. Each one opens a proxy from our machine to the respective service. `make connect-to-all` opens all three with one command.
