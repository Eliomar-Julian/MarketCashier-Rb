require_relative 'view'
require_relative 'crud'
require_relative 'loadconf'
require 'tk'

class App < Application
    $val = 0
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
        @bt_cance.configure :command => proc { self.limpar }
        @bt_cance.bind 'Return', proc { self.limpar }
        @bt_retir.configure :command => proc { self.retirar }
    end

    # // busca o preço dos itens a cada tecla pressionada caso seja possivel realizar a busca
    def tecla 
        $cod = @en_codig.get
        @lista = db_query $cod
        if @lista.length > 0
            tmp_lmt = @lista[0][1]
            tmp_lmt = tmp_lmt[0, 30] # limita a string a 30 caracteres
            tmp_des = tmp_lmt + "\n\n" + "Código:  " + @lista[0][0] + "\n\n"
            tmp_txt = @lista[0][2]
            tmp_txt = "R$ #{'%.2f' % tmp_txt}"
            @lb_p_atu.configure :text => tmp_txt.gsub('.', ',')
            @lb_show_.configure :text => tmp_des + "Preço:  " + tmp_txt.gsub('.', ',')
        else
            @lb_p_atu.configure :text => 'R$ 0,00'
            @lb_show_.configure :text => 'Produto'
        end
    end

    # // Solicita uma busca no banco de dados atraves dos dados contidos no campo
    def confirma
        @lista = db_query $cod 
        if @lista.length > 0
            @lv_codig.insert 0, @lista[0][1]
            $val = $val + @lista[0][2]
            tmp_txt = "R$ #{'%.2f' % $val}"
            @lb_p_tot.configure :text => tmp_txt.gsub('.', ',')
        end
        @en_codig.delete 0, $cod.length
    end

    # // Abre um top level para gerenciamento do troco alem de guardar as opçoes de faturamento
    def finaliza
        tr = Tk::Toplevel.new do 
            title 'Troco '
            bg BG
        end
        tr.geometry "300x300+400+100"

        def math_ #calculos para exibir nos labels da interface
            min = @ent.get.gsub(",", ".").to_f
            v = min - $val
            faturamento = File.open '../conf/ftr', 'a'
            faturamento.puts $val
            faturamento.close
            imprimir = "R$ #{'%.2f' % v}".gsub('.', ',')
            @lb_troco.configure :text => imprimir, 
                                :fg => 'orange'
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
            pack :expand => true, 
                 :fill => 'x' 
        end 
        @ent.configure :font => @font_media
        @ent.bind 'Return', proc { math_ }
        @ent.bind 'Escape', proc { tr.destroy }
        @ent.focus
        
        lb2 = Tk::Label.new tr do
            text 'Troco'
            bg BG
            fg FG
            pack :expand => true,
                 :fill => 'x'
        end
        lb2.configure :font => @font_media 

        @lb_troco = Tk::Label.new tr do 
            text 'R$ 0,00'
            bg BG
            fg FG 
            pack :expand => true,
                 :fill => 'x'
        end
        @lb_troco.configure :font => @font_title
    end
    
    # // Limpa o caixa depois que a venda ja foi realizada
    def limpar
        resp = Tk::Message.messageBox :type=>'yesno',
        :title => 'Liberar o Caixa',
        :message => 
        '''
        Tem certeza que deseja liberar o caixa?
        essa ação irá limpar a venda atual.
        '''
        if resp == 'yes'
            begin 
                @lv_codig.clear 
                @lb_p_tot.configure :text => 'R$ 0,00'
                @en_codig.delete 0, $cod.length
                $val = 0
            rescue
                puts 'clear' 
            end
        else
            return 'no clear'
        end        
    end

    # // Retira produtos da lista de vendas atuais
    def retirar
        indice =  @lv_codig.curselection[0]
        if indice.nil?
            return 'nil'
        end
        array  = @lv_codig.value
        if array.length > 0  
            busca   = array[indice]
            @lv_codig.delete indice
            valor   = db_search busca
            nume    = valor[0][2].to_f
            $val    = $val - nume
            tmp_txt = "R$ #{'%.2f' % $val}"
            @lb_p_tot.configure :text => tmp_txt.gsub('.', ',')
        end
    end
end




App.new
Tk.mainloop
