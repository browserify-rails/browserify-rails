module BrowserifyRails::Logger
  def self.log(message)
    Rails.logger.debug message
    puts "\n#{message}\n\n" if in_dummy_rails?
  end

  def self.in_dummy_rails?
    @in_dummy_rails ||= !!Rails.root.to_s.match(/browserify-rails\/test\/dummy$/)
  end
end
