import json
import boto3
from decimal import Decimal

class DecimalEncoder(json.JSONEncoder):
    def default(self, obj):
        if isinstance(obj, Decimal):
            return int(obj)
        return super(DecimalEncoder, self).default(obj)

dynamodb = boto3.resource('dynamodb')
table = dynamodb.Table('countdb')

def set_headers(response):
    response['headers'] = {
        'Access-Control-Allow-Origin': '*',
        'Access-Control-Allow-Methods': 'GET',
        'Access-Control-Allow-Headers': 'Content-Type',
        'Content-Type': 'application/json'
    }
    return response

def handler(event, context):
    try:
        response = table.get_item(Key={
            'id': '1'
        })
        
        item = response.get('Item', {'views': 0})
        current_views = item.get('views', 0)
        new_views = current_views + 1
        
        table.put_item(Item={
            'id': '1',  
            'views': new_views
        })
        
        response = {
            'statusCode': 200,
            'body': json.dumps({
                'views': new_views
            }, cls=DecimalEncoder)
        }
        return set_headers(response)
    
    except Exception as e:
        print(f"Error: {str(e)}")
        response = {
            'statusCode': 500,
            'body': json.dumps({
                'error': f'Internal Server Error: {str(e)}'
            })
        }
        return set_headers(response)