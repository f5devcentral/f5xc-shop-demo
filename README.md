# F5XC Shop Demo Application

## Overview
This repository represents a deployment of the [GCP microservices demo](https://github.com/GoogleCloudPlatform/microservices-demo).
A deployment is self-contained and runs solely on F5 Distributed Cloud (F5xc) Regional Edges. No CSP resources are used.

The app consists of 11 microservices that talk to each other over gRPC.
![demo arch](https://github.com/GoogleCloudPlatform/microservices-demo/raw/main/docs/img/architecture-diagram.png)

Synthetic load generation is included.
Once deployed, F5xc Console will be populated with realistic data.
This allows the demonstration of key F5xc Console concept such as:
- traffic and application vizualizations
- HTTP request telemetry
- event monitoring
- WAAP and bot protection
- virtual kubernetes (vk8s) and edge workloads

## Getting Started
You may clone this repo, provide your own _tfvars_ an deploy in any F5xc tenant. Deploys for F5xc sales demos tenants are done through Terraform Cloud.

## Development
The ```main``` branch is protected. Pull Requests to ```main``` must come from ```staging``` after testing is complete and be approved by a repo administrator. Please submit PRs to ```dev``` for feature development. Use Github issues for feature requests.

## Support
For support, please open a GitHub issue.  Note, the code in this repository is community supported and is not supported by F5 Networks.  For a complete list of supported projects please reference [SUPPORT.md](SUPPORT.md).

## Community Code of Conduct
Please refer to the [F5 DevCentral Community Code of Conduct](code_of_conduct.md).


## License
[Apache License 2.0](LICENSE)

## Copyright
Copyright 2014-2022 F5 Networks Inc.


### F5 Networks Contributor License Agreement

Before you start contributing to any project sponsored by F5 Networks, Inc. (F5) on GitHub, you will need to sign a Contributor License Agreement (CLA).

If you are signing as an individual, we recommend that you talk to your employer (if applicable) before signing the CLA since some employment agreements may have restrictions on your contributions to other projects.
Otherwise by submitting a CLA you represent that you are legally entitled to grant the licenses recited therein.

If your employer has rights to intellectual property that you create, such as your contributions, you represent that you have received permission to make contributions on behalf of that employer, that your employer has waived such rights for your contributions, or that your employer has executed a separate CLA with F5.

If you are signing on behalf of a company, you represent that you are legally entitled to grant the license recited therein.
You represent further that each employee of the entity that submits contributions is authorized to submit such contributions on behalf of the entity pursuant to the CLA.
