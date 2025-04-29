import json
import base64

with open('animal.jpeg', "rb") as image_file:
    content_image = base64.b64encode(image_file.read()).decode('utf8')


def generate_message(bedrock_runtime, model_id, max_tokens, top_p, temp, messages=None):

    if messages is not None:
        messages = [
            {
                "role": "user",
                "content": [
                    {"type": "image", "source": {"type": "base64", "media_type": "image/jpeg", "data": content_image}},
                    {"type": "text", "text": "What is in this image?"}
                ]
            }
        ]

    body = json.dumps(
        {
            "anthropic_version": "bedrock-2023-05-31",
            "max_tokens": max_tokens,
            "messages": messages,
            "temperature": temp,
            "top_p": top_p
        }
    )

    response = bedrock_runtime.invoke_model(body=body, modelId=model_id)
    response_body = json.loads(response.get('body').read())

    return response_body
