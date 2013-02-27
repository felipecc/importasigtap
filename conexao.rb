require 'rubygems'
require 'active_record'

class Conexao

  def conecta_prd_oracle
    conecta_oracle('prd','***')
  end
  
  def conecta_sml
    conecta_oracle('sml','antrax')
  end

  def conecta_prd_sqlite
    conecta_sqlite
  end
  
private
  def conecta_oracle(instancia, senha)
    ActiveRecord::Base.pluralize_table_names = false
    #    ActiveRecord::Base.logger = Logger.new(STDOUT)
    ActiveRecord::Base.establish_connection(
      :adapter => "oracle", 
      :username => "DBAMV", 
      :password => senha, 
      :database => "192.168.1.110:1521/#{instancia}")
  end

  def conecta_sqlite
    ActiveRecord::Base.establish_connection(
      :adapter  =>'sqlite3',
      :database => 'C:\importa_sigtap\db\sigtap.db',
      :pool => 5,
      :timeout => 5000)
  end
end





