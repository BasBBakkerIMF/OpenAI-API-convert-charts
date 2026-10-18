"""
Example user script 

 File structure

U:\
├── .env                    # API_KEY, CLIENT_ID, TENANT_ID
├── imf_openai_helper.py    # Helper module (don't modify)
└── my_script.py            # User scripts 

"""
from helper_for_4_imf_openai_helper import get_client

# Get authenticated client (handles all auth/caching automatically)
client = get_client()

# Choose your model
model = "gpt-5-nano"

# =========================
# Responses API
# =========================
resp = client.responses.create(
    model=model,
    input="Who were the founders of Microsoft?",
)
print(resp.output_text)

# =========================
# Chat Completions
# =========================
chat = client.chat.completions.create(
    model=model,
    messages=[{"role": "user", "content": "Who were the founders of Microsoft?"}],
)
print(chat.choices[0].message.content)

# =========================
# Loop example
# =========================
prompts = ["USA", "China", "France"]
unformatted_prompt = "Who is the president of {country}"
answers = []

for country in prompts:
    final_prompt = unformatted_prompt.format(country=country)
    resp = client.responses.create(
        model=model,
        input=final_prompt,
    )
    answers.append(resp.output_text)

print(answers)

