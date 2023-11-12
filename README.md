# Signway Ruby SDK

The Signway Ruby SDK enables you to generate signed URLs for the [Signway service](https://github.com/gabotechs/signway).
Signway facilitates a secure, direct request from a client-side application to a
third-party API without exposing sensitive credentials.

# Install

To install the Signway Ruby SDK, run the following command:

```shell
gem install signway_sdk
```

# Usage

```rb
require "signway_sdk"

puts SignwaySdk.sign_url(
  # The Application ID.
  # It can be either a Signway managed Application ID (ex: ID0123ABCD...),
  # or the ID provided when launching your own Signway instance (`$ signway <ID> <SECRET>`)
  #                                                                          ^
  id: ENV.fetch("SW_ID"),
  # The Application Secret paired with the provided Application ID.
  # It can be either a Signway managed Application Secret (ex: Gi8p1uZ39cg...),
  # or the Secret provided when launching your own Signway instance (`$ signway <ID> <SECRET>`)
  #                                                                                   ^
  secret: ENV.fetch("SW_SECRET"),
  # The Signway host that will proxy the signed request.
  # If you are using Signway managed, it should be "https://api.signway.io",
  # otherwise, it should be the url where your own Signway instance is listening.
  host: "https://api.signway.io",
  # To which URL the request will be proxy-ed by the Signway host. This url
  # will be embedded into your signed url as a query parameter, that way
  # Signway will know where to proxy the request.
  proxy_url: "https://api.openai.com/v1/completions",
  # The validity period of signed URL in seconds. Signway will reject the request
  # if this number of seconds have happened since the signed URL was created.
  expiry: 10,
  # The method that will be used for performing the request through Signway.
  # If a signed URL with a POST method is created, but when performing the
  # HTTP query to Signway a GET method is used, the request will be rejected.
  method: "POST",
  # [Optional] headers to include in the signature. Any headers set here must
  # also be included in the final HTTP request with the exact value provided here.
  # Additional headers not present here can anyways be sent freely and Signway will
  # not take them into account for validating the request's signature.
  headers: { "Content-Type": "application/json" },
  # [Optional] which body to include in the signature. If provided, the final
  # HTTP request must include exactly this body, otherwise the Signway will reject
  # the request. If not provided, the body will not be taken into account for
  # calculating the signature, and consumers can freely send any body they want.
  body: '{
  "model": "text-davinci-003",
  "stream": true,
  "prompt": "Say this is a test"
}'
)
```
