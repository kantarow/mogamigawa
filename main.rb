require_relative "lib/mogamigawa"
require 'dotenv'
require 'twitter'
require 'json'
require 'paho-mqtt'
require 'aws_iot_device'

Dotenv.load

MQTT_HOST = ENV['MQTT_HOST']
MQTT_PORT = ENV['MQTT_PORT']
MQTT_TOPIC = "haiku"

ROOT_CA_PATH = ENV['ROOT_CA_PATH']
CERTIFICATE_PATH = ENV['CERTIFICATE_PATH']
PRIVATE_KEY_PATH = ENV['PRIVATE_KEY_PATH']

twitter_client = Twitter::REST::Client.new do |config|
  config.consumer_key        = ENV['API_KEY']
  config.consumer_secret     = ENV['API_KEY_SECRET']
  config.access_token        = ENV['ACCESS_TOKEN']
  config.access_token_secret = ENV['ACCESS_TOKEN_SECRET']
end

mqtt_client = AwsIotDevice::MqttShadowClient::MqttManager.new(host: MQTT_HOST, port: MQTT_PORT)
mqtt_client.config_ssl_context(ROOT_CA_PATH, PRIVATE_KEY_PATH, CERTIFICATE_PATH)
mqtt_client.connect

TARGET_USERS = twitter_client.follower_ids

TARGET_USERS.each do |user|
  tweets = twitter_client.user_timeline(user)

  tweets.each do |tweet|
    text = tweet.full_text
    mogamigawa = Mogamigawa.new text
    haiku = []

    begin
      first = mogamigawa.consume(5)
      second = mogamigawa.consume(7)
      third = mogamigawa.consume(5)

      kigo = nil

      (first + second + third).each do |mn|
        kigo = mn.kigo
        break if kigo
      end

    rescue RangeError
      next
    end

    pub_json = {
      first: first.join,
      second: second.join,
      third: third.join,
      kigo: kigo,
    }.to_json

    mqtt_client.publish(MQTT_TOPIC, pub_json)
    sleep 5
  end
end

sleep 1

mqtt_client.disconnect
