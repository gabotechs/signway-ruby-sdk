# Signway Ruby SDK

Generate signed urls for [Signway](https://github.com/gabotechs/signway), so that they can be
used in client-side code.

# Install

```shell
gem install signway_sdk
```

# Usage

```rb
require 'signway_sdk'

puts SignwaySdk.sign_url(
  id: ENV.fetch('SW_ID'),
  secret: ENV.fetch('SW_SECRET'),
  host: 'https://api.signway.io',
  proxy_url: 'https://api.openai.com/v1/completions',
  expiry: 10,
  method: "POST",
)
```
