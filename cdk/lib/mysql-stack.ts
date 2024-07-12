import * as cdk from 'aws-cdk-lib';
import { Construct } from 'constructs';

export interface MySQLStackProps extends cdk.StackProps {
  projectName: string;
	accountId: string;
	region: string;
}

export class MySQLStack extends cdk.Stack {
  constructor(scope: Construct, id: string, props: MySQLStackProps) {
    super(scope, id, props);

    const { projectName, accountId } = props;

    const name = `${projectName}-${accountId}`;

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
        version: cdk.aws_rds.MysqlEngineVersion.VER_8_0_36
      }),
      name: `${name}-pg`,
      parameters: {
        time_zone: 'UTC',
      }
    });

    // RDS MySQL Instance
    const dbInstance = new cdk.aws_rds.DatabaseInstance(this, 'MySqlRdsInstance', {
      engine: cdk.aws_rds.DatabaseInstanceEngine.mysql({
        version: cdk.aws_rds.MysqlEngineVersion.VER_8_0_36
      }),
      instanceIdentifier: name,
      vpc,
      instanceType: cdk.aws_ec2.InstanceType.of(cdk.aws_ec2.InstanceClass.T3, cdk.aws_ec2.InstanceSize.MICRO),
      credentials: {
        username: user.username,
        password: cdk.SecretValue.unsafePlainText(user.password)
      },
      securityGroups: [securityGroup],
      parameterGroup,
      multiAz: false,
      allocatedStorage: 5,
      maxAllocatedStorage: 50,
      deletionProtection: false,
      publiclyAccessible: true,
      vpcSubnets: {
        subnetType: cdk.aws_ec2.SubnetType.PUBLIC,
      }
    });

    new cdk.CfnOutput(this, 'RdsEndpointExport', {
      value: dbInstance.instanceEndpoint.hostname,
      exportName: 'RdsEndpoint'
    });

    new cdk.CfnOutput(this, 'RdsInstanceIdentifier', {
      value: dbInstance.instanceIdentifier,
      exportName: 'RdsIdentifier',
    })

    new cdk.CfnOutput(this, 'RdsParameterGroupName', {
      value: `${name}-pg`,
      exportName: "RdsParameterGroupName",
    })

    new cdk.CfnOutput(this, 'RdsSecurityGroup', {
      value: securityGroup.securityGroupId,
      exportName: "RdsSecurityGroupId",
    })
  }
}
