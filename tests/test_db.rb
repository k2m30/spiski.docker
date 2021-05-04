require "minitest/autorun"
require 'mysql2'

class TestDB < Minitest::Test
  def setup
    begin
      retries ||= 0
      @client = Mysql2::Client.new(host: ENV['MYSQL_HOST'], username: ENV['MYSQL_ROOT_USERNAME'], password: ENV['MYSQL_ROOT_PASSWORD'])
      @client.query("USE #{ENV['MYSQL_DATABASE']};")
    rescue
      sleep 5
      retry if (retries += 1) < 3
      raise
    end
  end

  def test_count
    begin
      retries ||= 0
      result = @client.query("SELECT COUNT(*) FROM records;")
      assert(result.first["COUNT(*)"] > 0)
    rescue Minitest::Assertion => e
      sleep 5
      puts e.message
      puts 'Retry..'
      retry if (retries += 1) < 3
      raise
    end
  end
end