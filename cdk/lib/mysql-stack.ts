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

    const user = {
      username: "testuser",
      password: "TestPassword123$"
    }

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

    // RDS MySQL Instance
    const dbInstance = new cdk.aws_rds.DatabaseInstance(this, 'MySqlRdsInstance', {
      engine: cdk.aws_rds.DatabaseInstanceEngine.mysql({
        version: cdk.aws_rds.MysqlEngineVersion.VER_8_0_31
      }),
      vpc,
      credentials: {
        username: user.username,
        password: cdk.SecretValue.unsafePlainText(user.password)
      },
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

    // TODO: Populating data automatically using cloud

    new cdk.CfnOutput(this, 'RdsEndpointExport', {
      value: dbInstance.instanceEndpoint.hostname,
      exportName: 'RdsEndpoint'
    });
  }
}
