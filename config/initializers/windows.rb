require 'rbconfig'
if RbConfig::CONFIG["host_os"] == 'mingw32'
  ENV['EXECJS_RUNTIME'] = 'Node'
end
