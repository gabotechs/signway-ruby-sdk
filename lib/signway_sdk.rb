# frozen_string_literal: true

require_relative "signway_sdk/version"

require_relative "signway_sdk/signing_functions"

# Ruby SDK for creating Signway's signed URLs.
module SignwaySdk
  module_function

  # Signs a URL with the specified parameters using the Signway signature method.
  #
  # @param id [String] the Signway's access key ID
  # @param secret [String] the Signway's secret access key
  # @param host [String] the base URL of the resource to sign
  # @param proxy_url [String] the proxy URL that the request will go through
  # @param expiry [Integer] the number of seconds until the signature expires
  # @param method [String] the HTTP method for the request (GET, POST, etc.)
  # @param headers [Hash] (optional) HTTP headers to include in the signature
  # @param body [String] (optional) the body of the request to include in the signature
  # @param datetime_override [DateTime] (optional) the datetime to use for the signature
  #   defaults to the current time if not specified
  #
  # @return [String] the signed URL which includes the signature as a query parameter
  def sign_url(
    id:,
    secret:,
    host:,
    proxy_url:,
    expiry:,
    method:,
    headers: {},
    body: "",
    datetime_override: nil
  )
    host = host.end_with?("/") ? host : "#{host}/"
    dt = datetime_override || DateTime.now.new_offset("+00:00")
    headers ||= {}
    headers["Content-Length"] = body.bytesize.to_s unless body.empty?

    unsigned_url = host + SigningFunctions.authorization_query_params_no_sig(
      access_key: id,
      dt: dt,
      expires: expiry,
      proxy_url: proxy_url,
      custom_headers: headers,
      sign_body: !body.empty?
    )

    canonical_req = SigningFunctions.canonical_request(
      method: method,
      url: unsigned_url,
      headers: headers,
      body: body
    )

    to_sign = SigningFunctions.string_to_sign(dt, canonical_req)
    signing_key = SigningFunctions.signing_key(dt, secret)

    signature = OpenSSL::HMAC.hexdigest("sha256", signing_key, to_sign)

    "#{unsigned_url}&#{SigningFunctions::X_SIGNATURE}=#{signature}"
  end
end
