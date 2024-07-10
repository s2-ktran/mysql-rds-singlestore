import * as cdk from 'aws-cdk-lib';
import { Construct } from 'constructs';

export interface MySQLStackProps extends cdk.StackProps {
	accountId: string;
	region: string;
}

export class MySQLStack extends cdk.Stack {
  constructor(scope: Construct, id: string, props?: MySQLStackProps) {
    super(scope, id, props);

    // VPC
    const vpc = new cdk.aws_ec2.Vpc(this, 'MyVpc', {
      maxAzs: 2,
      natGateways: 1
    });

    // Security Group
    const securityGroup = new cdk.aws_ec2.SecurityGroup(this, 'MySQLSecurityGroup', {
      vpc,
      description: 'Allow MySQL access',
      allowAllOutbound: true
    });
    securityGroup.addIngressRule(cdk.aws_ec2.Peer.anyIpv4(), cdk.aws_ec2.Port.tcp(3306), 'Allow MySQL traffic');


    // Database Parameter Group
    const parameterGroup = new cdk.aws_rds.ParameterGroup(this, 'MySQLParameterGroup', {
      engine: cdk.aws_rds.DatabaseInstanceEngine.mysql({
        version: cdk.aws_rds.MysqlEngineVersion.VER_8_0_31
      }),
      parameters: {
        time_zone: 'UTC',
      }
    });

    // Secret for RDS Credentials
    // This will include your pipeline configurations
    const credentials = cdk.aws_rds.Credentials.fromGeneratedSecret('admin'); // auto-generates a secret with username 'admin'

    // RDS MySQL Instance
    const dbInstance = new cdk.aws_rds.DatabaseInstance(this, 'MySqlRdsInstance', {
      engine: cdk.aws_rds.DatabaseInstanceEngine.mysql({
        version: cdk.aws_rds.MysqlEngineVersion.VER_8_0_31
      }),
      vpc,
      credentials,
      securityGroups: [securityGroup],
      parameterGroup,
      multiAz: false,
      allocatedStorage: 5,
      maxAllocatedStorage: 100,
      deletionProtection: false,
      publiclyAccessible: false,
      vpcSubnets: {
        subnetType: cdk.aws_ec2.SubnetType.PUBLIC,
      }
    });

    new cdk.CfnOutput(this, 'RdsEndpointExport', {
      value: dbInstance.instanceEndpoint.hostname,
      exportName: 'RdsEndpoint'
    });

    new cdk.CfnOutput(this, 'SecretArn', {
      value: credentials.secret?.secretArn ?? '',
      exportName: "SecretArn"
    })
  }
}
