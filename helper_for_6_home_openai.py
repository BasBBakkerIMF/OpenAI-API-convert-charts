import os

from dotenv import load_dotenv
from openai import OpenAI, api_key
import truststore
truststore.inject_into_ssl()

def get_client() -> OpenAI:
    load_dotenv(override=True)

    api_key = os.getenv("OPENAI_API_KEY")
    print(api_key)
    if not api_key:
        raise ValueError(
            "OPENAI_API_KEY was not found. "
            "Add it to the .env file."
        )

    return OpenAI(api_key=api_key)

