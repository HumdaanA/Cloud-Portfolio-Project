# CODE FOR LAMBDA FUNCTION FOR VISIOR COUNTER

import json
import boto3
from decimal import Decimal

dynamodb = boto3.resource('dynamodb')
table = dynamodb.Table('visitorCount')

def lambda_handler(event, context):
    # Get the current count
    response = table.get_item(Key={'id': 'visitor_count'})
    count = response.get('Item', {}).get('count', 0)

    # Convert from Decimal to int
    count = int(count)

    # Increment count
    count += 1
    table.put_item(Item={'id': 'visitor_count', 'count': count})

    return {
        'statusCode': 200,
        'headers': {
            'Content-Type': 'application/json',
            'Access-Control-Allow-Origin': '*'
        },
        'body': json.dumps({'count': count})
    }
