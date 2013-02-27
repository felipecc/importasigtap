require 'rubygems'
require 'active_record'

class ConexaoSigtap < ActiveRecord::Base
  pluralize_table_names = false
  establish_connection(
    :adapter  => 'sqlite3',
    :database => 'C:\importa_sigtap\db\sigtap.db',
    :pool => 5,
    :timeout => 5000
  )

end