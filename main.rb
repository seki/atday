require 'webrick'
require 'rotp'
require_relative 'src/atday'

port = Integer(ENV['PORT']) rescue 8000
server = WEBrick::HTTPServer.new({
  :Port => port,
  :FancyIndexing => false
})

class MyTOTP
  def initialize(secret=ENV["ATDAY_SECRET"])
    @totp = ROTP::TOTP.new(secret, issuer: "atday")
    @last_otp_at = 0
  end

  def verify(string)
    result = @totp.verify(string, drift_behind: 15, after: @last_opt_at)
    @last_opt_at = result if result
    result
  end

  def now
    @totp.now
  end
end

$totp = MyTOTP.new

server.mount_proc('/run') {|req, res|
  token = req.query['token']
  days = req.query['days'] || 28
  res.content_type = "text/plain"
  if $totp.verify(token)
    main(days)
    res.body = "maybe"
  else
    res.body = "perhaps"
  end
}

server.mount_proc('/') {|req, res|
  res.content_type = "text/plain"
  res.body = "It works."
}

trap(:INT){exit!}
server.start
