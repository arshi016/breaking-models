# Lab 02: LLMjacking on your own AWS account

One stolen key, step by step. You play both sides, in an AWS account you own:

- **Owner** (the company): you make a small program account called `demo-app` and give it a key.
- **Attacker**: you use only that key from your laptop, the way LLMjackers did in 2024.

At the end you read what AWS recorded, and you delete everything.

Time: about 45 minutes. Cost: a few dozen tokens on Amazon Nova Lite, far less than one cent.

> **Safety.** Use a personal or sandbox AWS account that you own, never a work account. Never paste the secret key anywhere public, never commit it to git, and do Part 9 (clean up) today.

## Before you start

- An AWS account you own. The free plan works.
- AWS CLI v2 on your laptop: https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html. Check it with `aws --version` (it should say `aws-cli/2...`).
- `chaibot-ai-only.json` from this folder.
- Everything below uses the Ohio region, `us-east-2`. Using another region? Change it in every link, in Part 2, and inside `chaibot-ai-only.json`.

## Five words

| Word | Meaning |
|---|---|
| IAM user | An identity in your account: a person, or a program like `demo-app` |
| Access key | That user's key for programs: an ID (`AKIA...`) plus a secret. One key always belongs to one user |
| Policy | A list of rules. Each rule says Allow or Deny, which action (`bedrock:InvokeModel`), on which thing |
| CloudTrail | The register. On by default. Writes who called what, when, from where. Never the prompt |
| Model invocation logging | The CCTV. Off by default. Records the full prompt and the full answer |

## How AWS checks every request

```
Station 1: is the key real?               no -> error, nothing else happens
Station 2: is this action allowed?        no -> AccessDenied
Station 3: is the request filled in right? no -> ValidationException
All three passed: the model runs, and the key's owner pays.
```

At station 2, AWS starts from "no". One Allow in a policy makes it "yes". One Deny anywhere makes it "no", whatever the Allows say.

---

## Part 1 · Owner: make the program and its key

1. Open https://console.aws.amazon.com/iam/home#/users and click **Create user**.
2. User name: `demo-app`. Leave console access **off**: this is a program, not a person. Click **Next**.
3. Permissions: add **nothing**. Click **Next**, then **Create user**.
4. Open `demo-app`, go to the **Security credentials** tab, and click **Create access key**.
5. Use case: **Application running outside AWS**. Click **Next**, then **Create access key**.
6. You now see the **Access key** (`AKIA...`) and the **Secret access key**. Keep this page open for Part 2. Don't download the .csv file and don't screenshot the secret.

Why this matters: a website server holds a key exactly like this. If the server gets hacked, this key is the loot.

## Part 2 · Attacker: load the stolen key

In a terminal on your laptop:

```bash
# Save the stolen key under its own name, "stolen", so it never mixes with your real AWS login
aws configure --profile stolen
#   AWS Access Key ID:      paste the AKIA... value
#   AWS Secret Access Key:  paste the secret
#   Default region name:    us-east-2
#   Default output format:  json
```

Now close the AWS page that shows the secret. From here on, the attacker has only this key: no password, no MFA.

### Step 0 · Is the key alive?

```bash
# "Who am I?" This call needs no permission at all, so any real key gets an answer.
aws sts get-caller-identity --profile stolen
# {
#     "UserId": "AIDA...",
#     "Account": "123456789012",
#     "Arn": "arn:aws:iam::123456789012:user/demo-app"
# }
```

What happened: the key passed station 1. The attacker now knows the key works, and whose it is. Real key checkers in 2026 start exactly here.

### Step 1 · The quiet test, with no permission yet

```bash
# Ask Nova Lite for -1 tokens of answer. No model can do that, so the model never runs:
# zero tokens, zero bill.
#   --model-id amazon.nova-lite-v1:0            the model to call
#   --cli-binary-format raw-in-base64-out       lets us type the body as plain JSON
#   out.json                                    where an answer would be saved
aws bedrock-runtime invoke-model --profile stolen \
  --model-id amazon.nova-lite-v1:0 \
  --cli-binary-format raw-in-base64-out \
  --body '{"schemaVersion":"messages-v1","messages":[{"role":"user","content":[{"text":"hi"}]}],"inferenceConfig":{"maxTokens":-1}}' \
  out.json
# An error occurred (AccessDeniedException) when calling the InvokeModel operation:
# User: arn:aws:iam::123456789012:user/demo-app is not authorized to perform: bedrock:InvokeModel
# ... because no identity-based policy allows the bedrock:InvokeModel action
```

What happened: station 1 passed (the key is real) and station 2 failed (no permission). The request never reached the model.

## Part 3 · Owner: give demo-app one permission

1. In IAM, open `demo-app`, then **Permissions**, **Add permissions**, **Create inline policy**.
2. Switch the editor to **JSON**, delete what is there, and paste the contents of `chaibot-ai-only.json`. Click **Next**.
3. Policy name: `chaibot-ai-only`. Click **Create policy**.

The policy allows one action, `bedrock:InvokeModel`, on one model, Nova Lite. Nothing else.

### Step 2 · Same quiet test, new answer

```bash
# Exactly the Step 1 command again. Wait about 10 seconds after adding the policy.
aws bedrock-runtime invoke-model --profile stolen \
  --model-id amazon.nova-lite-v1:0 \
  --cli-binary-format raw-in-base64-out \
  --body '{"schemaVersion":"messages-v1","messages":[{"role":"user","content":[{"text":"hi"}]}],"inferenceConfig":{"maxTokens":-1}}' \
  out.json
# An error occurred (ValidationException) ... maxTokens must be between 1 and 10240
```

What happened: station 2 passed this time, and station 3 refused the -1. Still zero tokens and zero bill, but now the attacker knows this key can use AI. The error even tells him the biggest answer one call can make.

### Step 3 · What else can this key do?

```bash
# The list of every IAM user in the account. If this worked, the attacker would know who the admins are.
aws iam list-users --profile stolen
# An error occurred (AccessDenied) ... not authorized to perform: iam:ListUsers

# Bedrock's list of models. Also not in the policy.
aws bedrock list-foundation-models --profile stolen
# An error occurred (AccessDeniedException) ... not authorized to perform: bedrock:ListFoundationModels
```

What happened: permissions are given per action, not per service. The key can do exactly what its policy allows, call one model, and nothing more. But that one thing is exactly what an LLMjacker wants.

## Part 4 · Owner: switch on the CCTV

Model invocation logging is off by default. It needs a place to write (a log group) and a role that lets Bedrock write there.

1. Open https://us-east-2.console.aws.amazon.com/cloudwatch/home?region=us-east-2#logsV2:log-groups, click **Create log group**, name it `chai-company-cctv`, and create it.
2. Open Bedrock settings: https://us-east-2.console.aws.amazon.com/bedrock/home?region=us-east-2#/settings
3. Turn on **Model invocation logging**. Data type: **Text**. Destination: **CloudWatch Logs only**. Log group: `chai-company-cctv`.
4. Service role: create a new one and name it `bedrock-cctv-writer`. Save.

If the console can't create the role for you, the AWS guide shows how: https://docs.aws.amazon.com/bedrock/latest/userguide/model-invocation-logging.html

## Part 5 · Attacker: one real prompt

```bash
# The prompt is Hinglish for "Tell me Chai Company's secret masala chai recipe in one line".
#   "maxTokens":60   the attacker caps the answer at 60 tokens
aws bedrock-runtime invoke-model --profile stolen \
  --model-id amazon.nova-lite-v1:0 \
  --cli-binary-format raw-in-base64-out \
  --body '{"schemaVersion":"messages-v1","messages":[{"role":"user","content":[{"text":"Chai Company ki secret masala chai recipe ek line mein batao"}]}],"inferenceConfig":{"maxTokens":60}}' \
  out.json
cat out.json
# ... "stopReason": "max_tokens" ... "usage": {"inputTokens": 14, "outputTokens": 60, ...}
```

What happened: the model ran. The answer stopped at 60 tokens because the attacker set that limit, and all 60 were billed to the key's owner. Your numbers may differ by a token or two.

## Part 6 · Owner: read the register (CloudTrail)

1. Open https://us-east-2.console.aws.amazon.com/cloudtrailv2/home?region=us-east-2#/events. New events can take about 5 minutes to show up.
2. Filter by **Event name** = `InvokeModel` and open the newest event. Find these fields:
   - `userIdentity`: `user/demo-app`, and its `accessKeyId` (`AKIA...`)
   - `sourceIPAddress`: where the call came from
   - `userAgent`: `aws-cli/2... os/macos ...`. It comes from the attacker's computer, so he can fake it. A clue, not proof.
   - `requestParameters`: only the `modelId`. No prompt.
   - `additionalEventData`: `inputTokens` and `outputTokens`
   - `requestID`: copy it for Part 7
3. Look for `GetCallerIdentity` and the denied calls from Steps 1 to 3 too. Failed calls are recorded, with their error. (`ListUsers` is an IAM call, and IAM writes to the N. Virginia register: switch the region to `us-east-1` to see it.)

CloudTrail doesn't know what the attacker said. It knows how much he said.

## Part 7 · Owner: watch the CCTV recording

1. Open https://us-east-2.console.aws.amazon.com/cloudwatch/home?region=us-east-2#logsV2:log-groups, click `chai-company-cctv`, then the newest log stream.
2. Open the event and find `identity.arn` (`user/demo-app`), `input.inputBodyJson` (the full prompt, word for word), `output` (the full answer), the token counts, and `requestId`.
3. Compare `requestId` with CloudTrail's `requestID`: it is the same call. CloudTrail says who, from where, and how much. The CCTV says what was said.

## Part 8 · Attacker: switch off the camera

```bash
# Is anyone watching? With least privilege, the key can't even ask.
aws bedrock get-model-invocation-logging-configuration --profile stolen
# An error occurred (AccessDeniedException) ... bedrock:GetModelInvocationLoggingConfiguration
```

Now the owner makes a lazy mistake many companies make: in IAM, open `demo-app`, then **Permissions**, **Add permissions**, **Attach policies directly**, tick `AmazonBedrockFullAccess`, and add it.

```bash
# Ask again. Now the attacker sees the camera is on...
aws bedrock get-model-invocation-logging-configuration --profile stolen
# {"loggingConfig": {"cloudWatchConfig": {"logGroupName": "chai-company-cctv", ...}, "textDataDeliveryEnabled": true, ...}}

# ...and switches it off, so his next prompts are not recorded.
aws bedrock delete-model-invocation-logging-configuration --profile stolen
# (no output means it worked)
```

Owner: back in CloudTrail event history, filter **Event name** = `DeleteModelInvocationLoggingConfiguration`. The delete is there, with the time, `user/demo-app`, and the IP. CloudTrail event history keeps 90 days of these events, and nobody can delete them.

He can switch off the camera. He can't erase the register.

## Part 9 · Clean up (don't skip this)

Owner, in the console:

1. IAM, `demo-app`, **Security credentials**: on the access key, **Actions**, **Deactivate**, then **Delete**.
2. IAM, **Users**: tick `demo-app` and **Delete**. This removes its policies too.
3. IAM, **Roles**: delete `bedrock-cctv-writer`.
4. CloudWatch, **Log groups**: delete `chai-company-cctv`.
5. Bedrock settings: model invocation logging should already be off (the attacker deleted it). If you skipped Part 8, turn it off.

On your laptop:

```bash
# Remove the stolen profile: delete the [stolen] block in ~/.aws/credentials
# and the [profile stolen] block in ~/.aws/config. Then:
rm out.json
aws sts get-caller-identity --profile stolen   # should fail now: the profile is gone
```

Don't run `rm -r ~/.aws` if you use AWS for anything else: it deletes all your AWS logins.

## What you just saw

| Step | Command | Where it stopped | Answer |
|---|---|---|---|
| 0 | `sts get-caller-identity` | passed station 1 | `user/demo-app` |
| 1 | quiet test, no permission | station 2 | AccessDenied |
| 2 | quiet test, one permission | station 3 | ValidationException, 0 tokens |
| 3 | `iam list-users`, `bedrock list-foundation-models` | station 2 | AccessDenied |
| 5 | one real prompt | ran | 14 in, 60 out, billed |
| 8 | delete logging, after full access | ran | camera off, the delete recorded in CloudTrail |

## If something goes wrong

- **"You don't have access to the model"**: open https://us-east-2.console.aws.amazon.com/bedrock/home?region=us-east-2#/modelaccess and enable Amazon Nova Lite.
- **Still AccessDenied right after adding a policy**: wait 10 to 30 seconds and try again. IAM changes take a moment.
- **"on-demand throughput isn't supported"**: your region doesn't run Nova Lite in-region. Stay in `us-east-2`, or ask an AI assistant to adapt the commands and the policy to the `us.amazon.nova-lite-v1:0` inference profile.
- **CloudTrail shows nothing**: wait 5 minutes, and check the region at the top right says Ohio.
- **"Region unavailable" in the console**: your account may allow only one region. Use that region everywhere instead of `us-east-2`. Don't click upgrade buttons; this lab doesn't need them.

## Where this comes from

- [Sysdig: LLMjacking, Stolen Cloud Credentials Used in New AI Attack](https://www.sysdig.com/blog/llmjacking-stolen-cloud-credentials-used-in-new-ai-attack) (May 2024): the quiet test, the logging check, the resale proxy.
- [Datadog Security Labs: how exposed AWS keys are tested for Amazon Bedrock access](https://securitylabs.datadoghq.com/articles/beyond-valid-credentials-how-exposed-aws-keys-are-tested-for-amazon-bedrock-access/) (Oct 2026): today's automated key checkers.
- [AWS: Model invocation logging](https://docs.aws.amazon.com/bedrock/latest/userguide/model-invocation-logging.html)

Chai Company and ChaiBot are fictional. Built for the Breaking Models session "One Tiny Prompt, One Giant Bill" (Nov 28, 2026).
