require 'rubygems'
require 'conexao_sigtap'
require 'active_record'


class ProcedimentosSigtap < ConexaoSigtap
  set_table_name "PROCEDIMENTOS"
end