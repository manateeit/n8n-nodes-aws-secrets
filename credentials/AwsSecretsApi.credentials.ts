import {
  ICredentialType,
  INodeProperties,
} from 'n8n-workflow';

export class AwsSecretsApi implements ICredentialType {
  name = 'awsSecretsApi';
  displayName = 'AWS Secrets Manager API';
  documentationUrl = 'https://docs.aws.amazon.com/secretsmanager/';

  properties: INodeProperties[] = [
    {
      displayName: 'Region',
      name: 'region',
      type: 'string',
      default: 'us-east-1',
      required: true,
      description: 'AWS Region (e.g., us-east-1, us-west-2)',
    },
    {
      displayName: 'Access Key ID',
      name: 'accessKeyId',
      type: 'string',
      default: '',
      required: true,
    },
    {
      displayName: 'Secret Access Key',
      name: 'secretAccessKey',
      type: 'string',
      typeOptions: {
        password: true,
      },
      default: '',
      required: true,
    },
  ];
}
