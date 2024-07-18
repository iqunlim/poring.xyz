import boto3 
import json
import os
import random
import string

def lambda_handler(event, context):
	MAX_SIZE = int(os.environ.get("MAX_SIZE", 20)) 
	S3_BUCKET = os.environ.get('S3_BUCKET', '')
	return_data = {
		'data':'',
		'url':'',
		'error':''
	}
	# Obtain file prefix for same-named items
	while True:
		prefix = ''.join(random.choices(string.ascii_uppercase + string.digits, k=12))
		filenamefull = f'{prefix}/{event["fileName"]}'
		try:
			s3.head_object(Bucket = S3_BUCKET, Key = filenamefull)
		except:
			break
	#TODO: make this a conditional with the generated presigned post url? content-length-range maybe?
	if int(event['t']) >= MAX_SIZE * 1024 * 1024:
		return_data['error'] = f"The requested file size was too large! The max size is {MAX_SIZE} MB"

	elif "image/" not in event['fileType']:
		return_data['error'] = "The requested type was not an image!"

	elif S3_BUCKET == '':
		return_data['error'] = "The specified target for the file upload does not exist!"

	else:  
		s3 = boto3.client('s3')
		try:
			return_data['data'] = s3.generate_presigned_post(
				Bucket = S3_BUCKET,
				Key = filenamefull,
				Fields = { 
              		"Content-Type": event['fileType'],
              	},
				Conditions = [
					{ "Content-Type": event['fileType'] }
				],
				ExpiresIn = 3600
			)

			return_data['url'] = f'https://{S3_BUCKET}/{filenamefull}'

		except TypeError:
			return_data['error'] = 'Failed to authenticate file'
		except Exception:
			return_data['error'] = 'Undefined error in getting file upload url'

	return json.dumps(return_data)