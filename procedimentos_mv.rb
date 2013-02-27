require 'rubygems'
require 'conexao_mv'

class ProcedimentosMv < ConexaoMv
  set_table_name "PROCEDIMENTO_SUS_VALOR"
  set_primary_key "PROCEDIMENTO_CD"
end