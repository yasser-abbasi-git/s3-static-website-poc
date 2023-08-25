import boto3
import time
import os

def s3_change_handler(event, context):
    
    # Create CloudFront client
    client = boto3.client('cloudfront')
    invalidation = client.create_invalidation(
        DistributionId = os.environ['CLOUDFRONT_DISTRIBUTION_ID'],
        InvalidationBatch={
            'Paths': {
                'Quantity': 1,
                'Items': [
                    '/*',
                ]
            },
            'CallerReference': str(time.time())
        }
    )