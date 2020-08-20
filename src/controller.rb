# // script de controle da classe de interface 'view.rb/Application'
# // subclassifica 'App -> class' a 'Application -> class' para o controle de interface
# // controle de botões e labels

require_relative 'view'
require_relative 'crud'
require_relative 'loadconf'
require 'tk'

class App < Application
    $val = 0      # guarda o valor total da compra
    $tro = false  # Verifica se a janela de troco foi ativa na venda atual se sim se mantem como true ate o encerramento da venda
    
    # // inicialização da nova superclasse herdada de view::application
    def initialize
        super
        @root.bind 'KeyPress', proc { self.tecla }
        @en_codig.bind 'Return', proc { self.confirma }
        @lv_codig.configure :takefocus => false
        @bt_final.bind 'Return', proc { self.finaliza }
        @bt_final.configure :command => proc { self.finaliza }
        @bt_liber.configure :command => proc { self.limpar }
        @bt_liber.bind 'Return', proc { self.limpar }
        @bt_cance.configure :command => proc { self.limpar 'cancel' }
        @bt_cance.bind 'Return', proc { self.limpar 'cancel'}
        @bt_retir.configure :command => proc { self.retirar }
    end

    # // busca o preço dos itens a cada tecla pressionada caso seja possivel realizar a busca
    def tecla
        $cod = @en_codig.get
        $asteristico = $cod.rindex '*' # busca o  multiplicador
        $multiplicador = 1 # valor padrão do multiplicador
        
        if !$asteristico.nil? # filtra a entrada de codigo
            $multiplicador = $cod[$asteristico + 1, $cod.length].gsub(',', '.').to_f
            $cod = $cod[0, $asteristico]
        end
        
        @lista = db_query $cod
        
        if @lista.length > 0
            tmp_lmt = @lista[0][1]
            tmp_lmt = tmp_lmt[0, 30] # limita a string a 30 caracteres
            tmp_des = tmp_lmt + "\n\n" + "Código:  " + @lista[0][0] + "\n\n"
            tmp_txt = @lista[0][2] * $multiplicador
            #---------formatando a string de exibixão-------------
            tmp_txt = "R$ #{'%.2f' % tmp_txt}"
            tmp_    = "R$ #{'%.2f' % @lista[0][2]}"
            @lb_p_atu.configure :text => tmp_txt.gsub('.', ',')
            @lb_show_.configure :text => tmp_des + "Preço:  " + tmp_.gsub('.', ',')
        else
            @lb_p_atu.configure :text => 'R$ 0,00'
            @lb_show_.configure :text => 'Produto'
        end
    end

    # // Solicita uma busca no banco de dados atraves dos dados contidos no  campo de codigos
    def confirma
        @lista = db_query $cod 
        if @lista.length > 0
            @lv_codig.insert 0, @lista[0][1]
            $val = $val + (@lista[0][2] * $multiplicador)
            tmp_txt = "R$ #{'%.2f' % $val}"
            @lb_p_tot.configure :text => tmp_txt.gsub('.', ',')
        end
        @en_codig.delete 0, 100
    end

    # // Abre um top level para gerenciamento do troco -----------------------------------------
    def finaliza
        tr = Tk::Toplevel.new do 
            title 'Troco '
            bg BG
        end
        tr.geometry "300x300+400+100"
        tr.iconbitmap '../images/icone.ico'

        def math_ #calculos para exibir nos labels da janela de troco
            min = @ent.get.gsub(",", ".").to_f
            v = min - $val
            $tro = true
            imprimir = "R$ #{'%.2f' % v}".gsub('.', ',')
            @lb_troco.configure :text => imprimir, :fg => 'orange'
            if v < 0 
                @lb_troco.configure :fg => 'red'
            end
        end
        
        lb1 = Tk::Label.new tr do
            text 'Dinheiro'
            bg BG
            fg FG
            pack :expand => true, :fill => 'x'
        end
        lb1.configure :font => @font_media
        
        @ent = Tk::Entry.new tr do
            pack :expand => true, :fill => 'x' 
        end 
        @ent.configure :font => @font_media
        @ent.bind 'Return', proc { math_ }
        @ent.bind 'Escape', proc { tr.destroy }
        @ent.focus
        
        lb2 = Tk::Label.new tr do
            text 'Troco'
            bg BG
            fg FG
            pack :expand => true, :fill => 'x'
        end
        lb2.configure :font => @font_media 

        @lb_troco = Tk::Label.new tr do 
            text 'R$ 0,00'
            bg BG
            fg FG 
            pack :expand => true, :fill => 'x'
        end
        @lb_troco.configure :font => @font_title
    end
    
    # // Limpa o caixa depois que a venda ja foi realizada e tambem cancela a venda atual
    # // usada pelos botões de cancelar e liberar, o id não deverá estar vazio caso cancelar seja pressionado
    def limpar id=nil
        $multiplicador = 1.0
        
        if !id.nil? 
            $val = 0
        end
       
        resp = Tk::Message.messageBox :type=>'yesno', :title => 'Liberar o Caixa',
            :message => 
        '''
        Tem certeza que deseja liberar o caixa?
        essa ação irá limpar a venda atual.
        '''
        
        if resp == 'yes'
            begin
                $tro = false
                self.gravar 
                @lv_codig.clear 
                @lb_p_tot.configure :text => 'R$ 0,00'
                @en_codig.delete 0, $cod.length
                $val = 0
            rescue
                puts 'clear error' 
            end
        else
            return 'no clear'
        end        
    end

    # // Retira produtos da lista de vendas atuais
    def retirar
        indice =  @lv_codig.curselection[0]
        
        if indice.nil?
            Tk::Message.messageBox :icon => 'info', :title => 'Sem seleção',
                :message => 'Por favor selecione um item da lista.'
            puts 'nada selecionado'
            return 
        end
        
        array  = @lv_codig.value
        if array.length > 0  
            busca   = array[indice]
            @lv_codig.delete indice
            valor   = db_search busca
            nume    = valor[0][2].to_f
            $val    = $val - (nume * $multiplicador)
            tmp_txt = "R$ #{'%.2f' % $val}"
            @lb_p_tot.configure :text => tmp_txt.gsub('.', ',')
        end
    end

    #// grava o arquivo de registro de faturamento 'ftr', '$tro' deve ser 'false'  para gravar
    def gravar 
        if $tro == false 
            faturamento = File.open '../conf/ftr', 'a'
            faturamento.puts $val
            faturamento.close
        end
    end
end



# /////   Chamada da classe principal
App.new
Tk.mainloop
