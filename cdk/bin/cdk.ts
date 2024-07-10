#!/usr/bin/env node
import 'source-map-support/register';
import * as cdk from 'aws-cdk-lib';
import { MySQLStack } from '../lib/cdk-stack';

const app = new cdk.App();

const envVariables = {
	region: process.env["AWS_REGION"] ?? "",
	accountId: process.env["AWS_ACCOUNT_ID"] ?? "",
};

new MySQLStack(app, 'MySQLStack', {
  ...envVariables,
});