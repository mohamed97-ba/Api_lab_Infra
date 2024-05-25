# -*- coding: utf-8 -*-
import boto3, os, json, base64
from requests_toolbelt.multipart import decoder
import logging
s3_client = boto3.client('s3')
bucket_name = os.environ['BUCKET_NAME']
logger = logging.getLogger()
logger.setLevel(logging.INFO)

def push_to_s3(data, event_client):
    try:
        message_id = data['body'].get('messageId', 'default')
        s3_key = f"{event_client}/event_{message_id}.json" 
        logger.info(f"Uploading to S3 with key: {s3_key}")
        s3_client.put_object(Bucket=bucket_name, Key=s3_key, Body=json.dumps(data))
            
    except Exception as e:
        logger.error(f"Failed to upload data to S3: {e}")

        return {
            'statusCode': 500,
            'body': json.dumps({'error': 'Failed to save data to S3'})
    }
def process_multipart_data(body, content_type):
    """Process multipart/form-data."""
    
    multipart_data = decoder.MultipartDecoder(body, content_type)
    data = {}
    for part in multipart_data.parts:
        content_type_part = part.headers.get(b'Content-Type', b'').decode()
        if 'application/json' in content_type_part:
            return json.loads(part.text)
        raise ValueError("No JSON part found in multipart data")

    return data
    

def process_event(event):
        """Process incoming event and validate headers."""
        headers = event.get('headers', {})
        client_name = headers.get('x-settings')
        if not client_name:
            return {
                'statusCode': 400,  
                'body': json.dumps({'error': 'x-settings header is missing'})
            }
        content_type = headers.get('Content-Type')
        body = base64.b64decode(event['body']) if event.get('isBase64Encoded') else event['body']
            
        try:
            data = process_multipart_data(body, content_type)
            logger.info(f"Processed data: {json.dumps(data)}")
            return  push_to_s3(data, client_name)
        except Exception as e:
            logger.error(f"Failed to process event: {e}")
            return {
            'statusCode': 500,
            'body': json.dumps({'error': "Failed to process event"})
        }
       
def lambda_handler(event, context):
    try:
        response = process_event(event)
        return response
    except Exception as e:
        logger.error(f"Unhandled exception: {e}")
        return {
            'statusCode': 500,
            'body': json.dumps({'error': 'Internal server error'})
        }