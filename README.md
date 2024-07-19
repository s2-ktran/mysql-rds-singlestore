# MySQL RDS Data Integration into SingleStore

Data integration from one database to another is a cumbersome task. There are many considerations such as data integrity and consistency, downtime and performance impact, and schema differences. 

SingleStore is a fast, distributed, cloud SQL database designed to power modern data-intensive applications, delivering maximum performance for both transactional (OLTP) and analytical (OLAP) workloads in a single unified engine. Singlestore recently announced [native data integration services](https://www.singlestore.com/blog/introducing-native-data-integration-services/) including [connection links](https://docs.singlestore.com/db/v8.7/security/authentication/configuring-and-using-connection-links/). These links automatically detect table schemas and provision pipelines supporting high-speed consistent data ingestion.

A common use case with customers is to migrate from MySQL to SingleStore for increased scale and performance. [6sense](https://www.youtube.com/watch?v=i_8cBFeaL48) reaped these benefits and had 5x lower TCO, faster performance, and faster time to market with SingleStore for its real-time analytics use cases.

This blog post walks you through a migration from an Amazon MySQL RDS instance to a SingleStore cluster using this method. 

Don’t have a SingleStore account yet? Sign up [here](https://www.singlestore.com/cloud-trial/?utm_source=kevin-tran).
Don’t have an AWS account? Sign up [here](https://signin.aws.amazon.com/signup?request_type=register).

By the end of this tutorial, you will understand what configurations are needed for conducting this data integration.

![Architecture Diagram](architecture-diagram.png)

For the full walkthrough of the code, navigate to <blog_name>.

## Launch Configurations

### Prerequisites

- git
- aws-cli
- aws-cdk >= 2.128.0
- node >= 21.6.1
- npm >= 10.4.0
- jq >= 1.7.1
- mysql >= 11.4.2

### Deployment

Run the following command to build and deploy the application. Be sure to setup your AWS account using `aws configure`.

```bash
./scripts/deploy.sh
```

### Teardown

Once you are finished using the project, use the following command to delete the associated resources.

```bash
./scripts/teardown.sh
```

## Architecture Overview

### Code Layout

| Path                 | Description                                                    |
| :------------------- | :------------------------------------------------------------- |
| cdk/                 | AWS CDK source code.                                           |
| data/                | RDS data.                                                      |
| scripts/             | shell scripts to build, deploy, and interact with the project. |
| assets/              | supporting pics and diagrams for documentation.                |
