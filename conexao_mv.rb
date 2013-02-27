require 'rubygems'
require 'active_record'

class ConexaoMv < ActiveRecord::Base
  establish_connection(
    :adapter => "oracle",
    :username => "DBAMV",
    :password => "asterix2008",
    :database => "192.168.1.110:1521/prd"
  )
  #ActiveRecord::Base.logger = Logger.new(STDERR)
end