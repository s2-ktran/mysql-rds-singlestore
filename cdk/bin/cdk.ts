#!/usr/bin/env node
import 'source-map-support/register';
import * as cdk from 'aws-cdk-lib';
import { MySQLStack } from '../lib/mysql-stack';

const app = new cdk.App();

const envVariables = {
	projectName: "s2mysql",
	region: process.env["AWS_REGION"] ?? "",
	accountId: process.env["AWS_ACCOUNT_ID"] ?? "",
	ipAddress: process.env["IP_ADDRESS"] ?? "",
};

new MySQLStack(app, 'MySQLStack', {
  ...envVariables,
});