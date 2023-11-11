# frozen_string_literal: true

require "test_helper"

ID = ENV.fetch("SW_ID", "my-id")
SECRET = ENV.fetch("SW_SECRET", "my-secret")
HOST = ENV.fetch("SW_HOST", "http://localhost:3000")

class TestSignwaySdk < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::SignwaySdk::VERSION
  end

  def test_empty_get_request
    url = SignwaySdk.sign_url(
      id: ID,
      secret: SECRET,
      host: HOST,
      expiry: 10,
      method: "GET",
      proxy_url: "https://postman-echo.com/get"
    )

    response = RestClient.get(url)
    json_response = JSON.parse(response.body)

    assert_equal "https://postman-echo.com/get", json_response["url"]
  end

  def test_get_request_with_params
    url = SignwaySdk.sign_url(
      id: ID,
      secret: SECRET,
      host: HOST,
      expiry: 10,
      method: "GET",
      proxy_url: "https://postman-echo.com/get?param=1"
    )

    response = RestClient.get(url)
    json_response = JSON.parse(response.body)

    assert_equal "1", json_response["args"]["param"]
  end

  def test_get_request_with_headers
    url = SignwaySdk.sign_url(
      id: ID,
      secret: SECRET,
      host: HOST,
      expiry: 10,
      method: "GET",
      headers: { 'X-Foo': "foo" },
      proxy_url: "https://postman-echo.com/get"
    )

    response = RestClient.get(url, { 'X-Foo': "foo" })
    json_response = JSON.parse(response.body)

    assert_equal "foo", json_response["headers"]["x-foo"]
  end

  def test_post_request_with_body
    url = SignwaySdk.sign_url(
      id: ID,
      secret: SECRET,
      host: HOST,
      expiry: 10,
      method: "POST",
      headers: { 'X-Foo': "foo" },
      body: '{"foo": "bar"}',
      proxy_url: "https://postman-echo.com/post"
    )

    response = RestClient.post(url, '{"foo": "bar"}', { 'X-Foo': "foo", 'Content-Type': "application/json" })
    json_response = JSON.parse(response.body)

    assert_equal "bar", json_response["json"]["foo"]
  end

  def test_expired_signature
    url = SignwaySdk.sign_url(
      id: ID,
      secret: SECRET,
      host: HOST,
      expiry: 1,
      method: "GET",
      proxy_url: "https://postman-echo.com/get"
    )

    sleep(1.1) # Wait for the signature to expire

    assert_raises(RestClient::ExceptionWithResponse) do
      RestClient.get(url)
    end
  end

  def test_non_present_header
    url = SignwaySdk.sign_url(
      id: ID,
      secret: SECRET,
      host: HOST,
      expiry: 10,
      method: "GET",
      headers: { 'X-Foo': "foo" },
      proxy_url: "https://postman-echo.com/get"
    )

    assert_raises(RestClient::ExceptionWithResponse) do
      RestClient.get(url)
    end
  end

  def test_bad_header_value
    url = SignwaySdk.sign_url(
      id: ID,
      secret: SECRET,
      host: HOST,
      expiry: 10,
      method: "GET",
      headers: { 'X-Foo': "foo" },
      proxy_url: "https://postman-echo.com/get"
    )

    assert_raises(RestClient::ExceptionWithResponse) do
      RestClient.get(url, { ':X-Foo': "bar" })
    end
  end

  def test_bad_body_value
    url = SignwaySdk.sign_url(
      id: ID,
      secret: SECRET,
      host: HOST,
      expiry: 10,
      method: "POST",
      body: '{"foo": "bar"}',
      proxy_url: "https://postman-echo.com/post"
    )

    assert_raises(RestClient::ExceptionWithResponse) do
      RestClient.post(url, '{"foo": "baz"}')
    end
  end
end
