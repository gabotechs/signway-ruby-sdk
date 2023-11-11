# frozen_string_literal: true

require "uri"
require "cgi"
require "openssl"
require "date"

module SignwaySdk
  # Helper functions for performing signatures.
  module SigningFunctions
    ALGORITHM = "SW1-HMAC-SHA256"
    LONG_DATETIME = "%Y%m%dT%H%M%SZ"
    SHORT_DATETIME = "%Y%m%d"
    X_ALGORITHM = "X-Sw-Algorithm"
    X_CREDENTIAL = "X-Sw-Credential"
    X_DATE = "X-Sw-Date"
    X_EXPIRES = "X-Sw-Expires"
    X_SIGNED_HEADERS = "X-Sw-SignedHeaders"
    X_SIGNED_BODY = "X-Sw-Body"
    X_PROXY = "X-Sw-Proxy"
    X_SIGNATURE = "X-Sw-Signature"

    def self.canonical_uri_string(uri)
      URI(uri).path
    end

    def self.canonical_query_string(uri)
      params = CGI.parse(URI(uri).query.to_s)
      params.map { |k, vs| vs.map { |v| "#{CGI.escape(k)}=#{CGI.escape(v)}" } }.flatten.sort.join("&")
    end

    def self.canonical_header_string(headers)
      headers.map { |k, v| "#{k.to_s.downcase}:#{v.strip}" }.sort.join("\n")
    end

    def self.signed_header_string(headers)
      headers.keys.map(&:to_s).map(&:downcase).sort.join(";")
    end

    def self.canonical_request(method:, url:, headers:, body:)
      "#{method}\n" \
        "#{canonical_uri_string(url)}\n" \
        "#{canonical_query_string(url)}\n" \
        "#{canonical_header_string(headers)}\n\n" \
        "#{signed_header_string(headers)}\n" \
        "#{body}"
    end

    def self.scope_string(dt)
      dt.strftime(SHORT_DATETIME)
    end

    def self.string_to_sign(dt, canonical_req)
      "#{ALGORITHM}\n" \
        "#{dt.strftime(LONG_DATETIME)}\n" \
        "#{scope_string(dt)}\n" \
        "#{OpenSSL::Digest.new("sha256").hexdigest(canonical_req)}"
    end

    def self.signing_key(dt, secret)
      key = "#{ALGORITHM}#{secret}"
      OpenSSL::HMAC.digest("sha256", key, dt.strftime(SHORT_DATETIME))
    end

    def self.authorization_query_params_no_sig(access_key:, dt:, expires:, proxy_url:, custom_headers:, sign_body:)
      credentials = "#{access_key}/#{scope_string(dt)}"
      signed_headers = signed_header_string(custom_headers)

      parsed_proxy_url = URI(proxy_url)

      credentials = CGI.escape(credentials)
      signed_headers = CGI.escape(signed_headers)
      proxy_url = CGI.escape(parsed_proxy_url.to_s)
      long_date = dt.strftime(LONG_DATETIME)
      sign_body_str = sign_body ? "true" : "false"

      "?#{X_ALGORITHM}=#{ALGORITHM}" \
        "&#{X_CREDENTIAL}=#{credentials}" \
        "&#{X_DATE}=#{long_date}" \
        "&#{X_EXPIRES}=#{expires}" \
        "&#{X_PROXY}=#{proxy_url}" \
        "&#{X_SIGNED_HEADERS}=#{signed_headers}" \
        "&#{X_SIGNED_BODY}=#{sign_body_str}"
    end
  end
end
