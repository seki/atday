require 'mail'
require 'net/imap'
require 'date'

Config = {
  :imap => 'imap.mail.me.com',
  :smtp => 'smtp.mail.me.com',
  :user => ENV["ICLOUD_USER"],
  :password => ENV["ICLOUD_APP_PASSWORD"],
  :imap_user => ENV["ICLOUD_USER"].split('@').first
}

class MySMTP
  def initialize(env=Config)
    @env = env
    #FIXME
    Mail.defaults do
      delivery_method :smtp, { 
        :address   => env[:smtp],
        :port      => 587,
        :user_name => env[:user],
        :password  => env[:password],
        :authentication => 'plain',
        :enable_starttls_auto => true }
    end
  end

  def send_me(subject, text)
    env = @env
    mail = Mail.deliver do
      to env[:user]
      from env[:user]
      subject subject
      text_part do
        body text
        content_type 'text/plain; charset=UTF-8'
      end
    end    
  end
end

class MyIMAP
  def initialize(env=Config)
    @imap = Net::IMAP.new(Config[:imap], 993, true)
    @imap.login(Config[:imap_user], Config[:password])
  end

  def fetch_at(date)
    @imap.examine('INBOX')
    e = @imap.search(["FROM", Config[:user], "SENTON", date.strftime("%d-%b-%Y"), "SUBJECT", "atday"])
    e.map {|msg|
      s = @imap.fetch(msg, "RFC822")[0].attr["RFC822"]
      m = Mail.new(s)
      next(nil) unless m.subject.include?('atday')
      subject = m.subject.strip
      subject = nil if subject == 'atday'
      if m.multipart?
        if m.text_part
          body = m.text_part.decoded
        end
      else
        body = m.body.to_s.force_encoding('utf-8')
      end
      [subject, body].compact.join("\n\n")
    }.select {|x| x}.join("\n-- \n")
  end
end

def main(arg)
  ndays = arg.to_i
  imap = MyIMAP.new
  date = Date.today - ndays
  text = imap.fetch_at(date)
  return if text.strip.empty?
  smtp = MySMTP.new
  smtp.send_me("from #{ndays} days ago", text)
end

main(ARGV.shift || 28)