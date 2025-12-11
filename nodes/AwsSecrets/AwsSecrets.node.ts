import {
  IExecuteFunctions,
  INodeExecutionData,
  INodeType,
  INodeTypeDescription,
} from 'n8n-workflow';

import * as AWS from 'aws-sdk';

export class AwsSecrets implements INodeType {
  description: INodeTypeDescription = {
    displayName: 'AWS Secrets Manager',
    name: 'awsSecrets',
    icon: 'file:awsSecrets.svg',
    group: ['transform'],
    version: 1,
    subtitle: '={{$parameter["operation"] + ": " + $parameter["secretName"]}}',
    description: 'Get secrets from AWS Secrets Manager',
    defaults: {
      name: 'AWS Secrets',
    },
    inputs: ['main'],
    outputs: ['main'],
    credentials: [
      {
        name: 'awsSecretsApi',
        required: true,
      },
    ],
    properties: [
      {
        displayName: 'Operation',
        name: 'operation',
        type: 'options',
        options: [
          {
            name: 'Get Secret',
            value: 'getSecret',
            description: 'Retrieve a secret value',
          },
        ],
        default: 'getSecret',
      },
      {
        displayName: 'Secret Name',
        name: 'secretName',
        type: 'string',
        default: '',
        required: true,
        description: 'The name or ARN of the secret to retrieve',
        placeholder: 'datalake/sftp/credentials',
      },
      {
        displayName: 'Parse JSON',
        name: 'parseJson',
        type: 'boolean',
        default: true,
        description: 'Whether to parse the secret value as JSON',
      },
    ],
  };

  async execute(this: IExecuteFunctions): Promise<INodeExecutionData[][]> {
    const items = this.getInputData();
    const returnData: INodeExecutionData[] = [];

    // Get credentials
    const credentials = await this.getCredentials('awsSecretsApi');

    // Configure AWS SDK
    const secretsManager = new AWS.SecretsManager({
      region: credentials.region as string,
      accessKeyId: credentials.accessKeyId as string,
      secretAccessKey: credentials.secretAccessKey as string,
    });

    for (let i = 0; i < items.length; i++) {
      try {
        const operation = this.getNodeParameter('operation', i) as string;
        const secretName = this.getNodeParameter('secretName', i) as string;
        const parseJson = this.getNodeParameter('parseJson', i) as boolean;

        if (operation === 'getSecret') {
          const response = await secretsManager.getSecretValue({
            SecretId: secretName,
          }).promise();

          let secretValue: any = response.SecretString;

          // Parse JSON if requested
          if (parseJson && secretValue) {
            try {
              secretValue = JSON.parse(secretValue);
            } catch (e) {
              // If parse fails, return as string
            }
          }

          returnData.push({
            json: {
              secretName: secretName,
              secretValue: secretValue,
              versionId: response.VersionId,
              createdDate: response.CreatedDate,
              ...( typeof secretValue === 'object' ? secretValue : {} ),
            },
          });
        }
      } catch (error) {
        if (this.continueOnFail()) {
          returnData.push({
            json: {
              error: error.message,
            },
          });
          continue;
        }
        throw error;
      }
    }

    return [returnData];
  }
}
