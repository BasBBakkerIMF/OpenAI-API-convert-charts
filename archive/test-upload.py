from pathlib import Path

from imf_openai_helper import get_client

client = get_client()

image_path = Path(r"c:\temp\fig.png")

with image_path.open("rb") as image_handle:
    uploaded = client.files.create(
        file=image_handle,
        purpose="assistants",
    )

print("Uploaded ID:", uploaded.id)

response = client.responses.create(
    model="gpt-5.5",
    input=[
        {
            "role": "user",
            "content": [
                {
                    "type": "input_text",
                    "text": "Describe the uploaded image.",
                },
                {
                    "type": "input_image",
                    "file_id": uploaded.id,
                    "detail": "high",
                },
            ],
        }
    ],
)

print(response.output_text)