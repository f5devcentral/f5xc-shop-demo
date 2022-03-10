# Loadgen-Container

## About the load generator

[k6.io](https://k6.io/) is used to generate load. This tool is an open source JS based traffic generator that offers great flexibility.
This container attempts to take a modular approach so that additional flavors of traffic can easily be added:

- helpers.js -- Functions common to all requests
- crawler.js -- Hits ``/`` and then crawls all ``a`` refs. This generates a baseline of traffic.
- exploit.js -- A work in progress of requests that will generate security events.


## About the User Agent lib
The library of user agents was extracted from the [user-agents](https://github.com/intoli/user-agents) NPM package.