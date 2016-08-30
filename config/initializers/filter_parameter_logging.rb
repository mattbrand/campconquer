# Be sure to restart your server when you modify this file.

# Configure sensitive parameters which will be filtered from the log file.
Rails.application.config.filter_parameters += [:password, :moves]

# http://stackoverflow.com/questions/13051949/how-to-disable-activerecord-logging-for-a-certain-column

class ActiveRecord::ConnectionAdapters::AbstractAdapter
  protected

  def log_with_binary_truncate(sql, name="SQL", binds=[], statement_name = nil, &block)
    binds = binds.map do |col, data|
      if data.is_a?(String) && data.size > 100
        data = "#{data[0,10]} [REDACTED #{data.size - 20} bytes] #{data[-10,10]}"
      end
      [col, data]
    end

    sql = sql.gsub(/(?<='\\x[0-9a-f]{100})[0-9a-f]{100,}?(?=[0-9a-f]{100}')/) do |match|
      "[REDACTED #{match.size} chars]"
    end

    sql = sql.gsub("\n", "\\n")

    if sql.size > 1000
      sql = sql[0,1000] + '...'
    end

    log_without_binary_truncate(sql, name, binds, statement_name, &block)
  end

  alias_method_chain :log, :binary_truncate
end
