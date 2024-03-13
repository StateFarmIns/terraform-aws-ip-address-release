import boto3
import botocore.exceptions
import logging

client = boto3.client('ec2')
logger = logging.getLogger()
logger.setLevel(logging.INFO)


def lambda_handler(event, context):
    paginator = client.get_paginator('describe_network_interfaces')

    interfaces = paginator.paginate(
        Filters=[
            {
                'Name': 'status',
                'Values': ['available']
            }
        ]
    ).build_full_result()

    count = len(interfaces['NetworkInterfaces'])

    x = 1
    for interface in interfaces['NetworkInterfaces']:
        description = interface.get('Description', '')
        if 'datasync client for' in description:
            logger.info(f"{x}/{count} ENI attached to DataSync task. Skipping Deletion for {interface['NetworkInterfaceId']} {interface['AvailabilityZone']} {interface['PrivateIpAddress']}")
        else:
            logger.info(f"{x}/{count} Deleting network interface {interface['NetworkInterfaceId']} {interface['AvailabilityZone']} {interface['PrivateIpAddress']}")
            logger.info(f"Description: {interface['Description']}")

            try:
                response = client.delete_network_interface(NetworkInterfaceId=interface['NetworkInterfaceId'])
                logger.info(f"Response: {response}")
            except botocore.exceptions.ClientError as error:
                logger.warn(f"Delete failed: {error}")

        x += 1
