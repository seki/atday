require 'rotp'
require 'open-uri'

days = ARGV.shift || 28

secret=ENV["ATDAY_SECRET"]
totp = ROTP::TOTP.new(secret, issuer: "atday")

url = ENV["ATDAY_URL"] || 'http://localhost:8000'
puts URI.open(url).read
puts URI.open(url + "/run?token=#{totp.now}&days=#{days}").read
