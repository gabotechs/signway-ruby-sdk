# Signway Ruby SDK

Generate signed urls for [Signway](https://github.com/gabotechs/signway), so that they can be
used in client-side code.

# Install

```shell
gem install signway_sdk
```

# Usage

```shell
from signway_sdk import sign_url

sign_url(
    id="my-id",
    secret="my-secret",
    host="https://api.signway.io",
    proxy_url="https://api.openai.com/v1/chat/completions",
    expiry=10,
    method="POST"
)
```
