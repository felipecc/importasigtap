require 'rubygems'
require 'conexao'
require 'procedimento'
require 'layout'
require 'procedimentos_mv'
require 'procedimentos_sigtap'
require 'fastercsv'


class ImportaSigtap < Conexao
  def importa_layout(nome_tabela,arquivo)
    #Coluna,Tamanho,Inicio,Fim,Tipo
    conecta_prd_sqlite
    arq = File.open(arquivo,'r')
    arq.each_line do |linha|
      ary = linha.split(',')
      next if ary[0] == 'Coluna'
      puts ary
      l = Layout.new
      l.tabela  = nome_tabela
      l.coluna  = ary[0]
      l.tamanho = ary[1]
      l.inicio  = ary[2]
      l.fim     = ary[3]
      l.save
    end     
  end

  def adciona_ponto(str)
    return str[-10..-3] + '.' + str[-2..-1]
  end

  def adiciona_dia(str)
    return str = str + '01'
  end

  def importa_tb(tabela_layout,arquivo)
    conecta_prd_sqlite
    

    arq = File.open(arquivo,'r')
    arq.each_line do |linha|
      p = Procedimento.new

      layout = Layout.find(:all,
                           :conditions => { :tabela => tabela_layout })
        layout.each do |l|
           inicio = l.inicio
           fim = l.fim

           inicio = inicio - 1
           fim = fim -1
           p.co_procedimento    = linha.slice(inicio..fim) if l.coluna == 'CO_PROCEDIMENTO'
           p.no_procedimento    = linha.slice(inicio..fim) if l.coluna == 'NO_PROCEDIMENTO'
           p.tp_complexidade    = linha.slice(inicio..fim) if l.coluna == 'TP_COMPLEXIDADE'
           p.tp_sexo            = linha.slice(inicio..fim) if l.coluna == 'TP_SEXO'
           p.qt_maxima_execucao = linha.slice(inicio..fim) if l.coluna == 'QT_MAXIMA_EXECUCAO'
           p.qt_dias_permanencia= linha.slice(inicio..fim) if l.coluna == 'QT_DIAS_PERMANENCIA'
           p.vl_sh              = adciona_ponto(linha.slice(inicio..fim)) if l.coluna == 'VL_SH'
           p.vl_sa              = adciona_ponto(linha.slice(inicio..fim)) if l.coluna == 'VL_SA'
           p.vl_sp              = adciona_ponto(linha.slice(inicio..fim)) if l.coluna == 'VL_SP'
           p.co_financiamento   = linha.slice(inicio..fim) if l.coluna == 'CO_FINANCIAMENTO'
           p.co_rubrica         = linha.slice(inicio..fim) if l.coluna == 'CO_RUBRICA'
           p.dt_competencia     = adiciona_dia(linha.slice(inicio..fim)) if l.coluna == 'DT_COMPETENCIA'
           if l.coluna == 'QT_PONTOS'
             qtd_pontos = linha.slice(inicio..fim)
             if qtd_pontos == '9999'
               p.qt_pontos =  '0'
             else
               p.qt_pontos =  qtd_pontos
             end
           end
           if l.coluna == 'VL_IDADE_MINIMA'
             vl_idade_minima    = linha.slice(inicio..fim)
             if vl_idade_minima == '9999'
               p.vl_idade_minima = '0'
             else
               p.vl_idade_minima = vl_idade_minima
             end
           end

          if l.coluna == 'VL_IDADE_MAXIMA'
             vl_idade_maxima    = linha.slice(inicio..fim)
             if vl_idade_maxima == '9999'
               p.vl_idade_maxima = '0'
             else
               p.vl_idade_maxima = vl_idade_maxima
             end
           end
         end
         p.save
      end
   end

  def procura_diferenca(mes_ano)
    ary = mes_ano.split('/')
    nome_arquivo = "diferenca#{ary[0]}#{ary[1]}.csv"
    FasterCSV.open("C:/importa_sigtap/#{nome_arquivo}", "w" ,:col_sep => ';') do |out|
      out << ["cd_procedimento","no_procedimento","dt_vigencia","vl_sh_sigtap","vl_servico_hospitalar_mv","vl_sa_sigtap","vl_servico_ambulatorial_mv","vl_sp_sigtap","vl_servico_profissional_mv","qt_pontos_sigtap" ,"qt_pontos.mv"]
          procedimentos_sigtap = ProcedimentosSigtap.find(:all,
                                                          :conditions => ['dt_competencia = ?',Date.strptime(mes_ano,"%m/%Y")])
      procedimentos_sigtap.each do |ps|
        procedimento_mv = ProcedimentosMv.find(:all,
                                               :conditions =>['dt_vigencia = to_date(?,?) and cd_procedimento = ?',ps.dt_competencia.strftime("%m/%Y"),'MM/YYYY',ps.co_procedimento])
        procedimento_mv.each do |pmv|
          if !(ps.vl_sh == pmv.vl_servico_hospitalar)
            out << [pmv.cd_procedimento.to_s,ps.no_procedimento.to_s,pmv.dt_vigencia.strftime("%m/%Y"), ps.vl_sh.to_s, pmv.vl_servico_hospitalar.to_s, ps.vl_sa.to_s,pmv.vl_servico_ambulatorial.to_s ,ps.vl_sp.to_s ,pmv.vl_servico_profissional.to_s ,ps.qt_pontos.to_s ,pmv.qt_pontos.to_s]
          elsif !(ps.vl_sa == pmv.vl_servico_ambulatorial)
            out << [pmv.cd_procedimento.to_s,ps.no_procedimento.to_s,pmv.dt_vigencia.strftime("%m/%Y"), ps.vl_sh.to_s, pmv.vl_servico_hospitalar.to_s, ps.vl_sa.to_s,pmv.vl_servico_ambulatorial.to_s ,ps.vl_sp.to_s ,pmv.vl_servico_profissional.to_s ,ps.qt_pontos.to_s ,pmv.qt_pontos.to_s]
          elsif !(ps.vl_sp == pmv.vl_servico_profissional)
            out << [pmv.cd_procedimento.to_s,ps.no_procedimento.to_s,pmv.dt_vigencia.strftime("%m/%Y"), ps.vl_sh.to_s, pmv.vl_servico_hospitalar.to_s, ps.vl_sa.to_s,pmv.vl_servico_ambulatorial.to_s ,ps.vl_sp.to_s ,pmv.vl_servico_profissional.to_s ,ps.qt_pontos.to_s ,pmv.qt_pontos.to_s]
          elsif !(ps.qt_pontos == pmv.qt_pontos)
            out << [pmv.cd_procedimento.to_s,ps.no_procedimento.to_s,pmv.dt_vigencia.strftime("%m/%Y"), ps.vl_sh.to_s, pmv.vl_servico_hospitalar.to_s, ps.vl_sa.to_s,pmv.vl_servico_ambulatorial.to_s ,ps.vl_sp.to_s ,pmv.vl_servico_profissional.to_s ,ps.qt_pontos.to_s ,pmv.qt_pontos.to_s]
          end
        end
      end
    end
  end
end

imp = ImportaSigtap.new
#imp.importa_tb('tb_procedimento','C:/importa_sigtap/arquivos/tb_procedimento.txt')
#imp.procura_diferenca("01/2008")
#imp.procura_diferenca("02/2008")
#imp.procura_diferenca("03/2008")
#imp.procura_diferenca("04/2008")
#imp.procura_diferenca("05/2008")
#imp.procura_diferenca("06/2008")
#imp.procura_diferenca("07/2008")
#imp.procura_diferenca("08/2008")
#imp.procura_diferenca("09/2008")
#imp.procura_diferenca("10/2008")
#imp.procura_diferenca("11/2008")
#imp.procura_diferenca("12/2008")
#imp.procura_diferenca("01/2009")
#imp.procura_diferenca("02/2009")
imp.procura_diferenca("03/2009")
#imp.importa_tb('tb_procedimento')
#imp.depura('tb_procedimento')
#puts imp.adciona_ponto('0000018150')
#imp.importa_layout('tb_procedimento','C:/importa_sigtap/arquivos/tb_procedimento_layout.txt')
