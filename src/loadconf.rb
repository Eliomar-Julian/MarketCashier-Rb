# // script responsavel por ler os arquivos de configuração presentes em './conf/'

require 'json'
require 'tk'
require_relative 'view'

# // leitura de configuração de das cores----------------------------
def read 
    js = File.read '../conf/conf.json'
    dict = JSON.parse js
    return dict
end

# // lista o historico de faturamento de vendas------------------
def encerra 
    
    def limpar_historico 
        res = Tk::Message.messageBox :type => 'yesno', 
                :icon => 'warning', :title => 'apagar faturamento',
                :message => 
                """
                essa ação apagará todo o faturamento até então do histórico,\
                deseja realmete limpar o historico de valores?
                """
        
        if res != 'yes' 
            return 'no'
        end
        
        File.new '../conf/ftr', 'w'
        @ftr.destroy
    end
    
    @ftr = Tk::Toplevel.new do 
        title 'Faturamento'
    end
    @ftr.configure :bg => read["theme"]["backgroundColor"]
    @ftr.iconbitmap "../images/icone.ico"
    @ftr.minsize 300, 300
    
    arq = File.new '../conf/ftr', 'r'
    ver = arq.readlines
    lisbox = Tk::Listbox.new @ftr
    itens = []
    $ftr_val = 0
    
    begin
        ver.map do |x|
            itens.push x.strip
        end
        itens.map do |x|
            $ftr_val += x.to_f
            lisbox.insert 0, x
        end
    rescue
        puts 'list nil'
    end
    
    f = TkFont.new :size => 20, :weight => 'bold'
    
    lb1 = Tk::Label.new @ftr do 
        text "Faturamento"
        bg read["theme"]["backgroundColor"]
        fg 'red'
        font f
    end
    
    forma = "R$ #{'%.2f' % $ftr_val}"
    lb2 =  Tk::Label.new @ftr do 
        text forma
        bg read["theme"]["backgroundColor"]
        fg 'red'
        font f
    end
    
    lisbox.pack :expand => true
    lb1.pack :expand => true
    lb2.pack :expand => true
    arq.close
    
    bt = Tk::Button.new @ftr do 
        text 'Limpar histórico'
    end
    bt.pack :expand => true
    bt.configure :command => proc { limpar_historico }
end

# // função que muda o label de marketing----------------------------
def nome
    def mude 
        dict = read 
        dict['nome'] = @en.get.strip
        trans = JSON.generate dict
        fil = File.new '../conf/conf.json', 'w'
        fil.puts trans
        fil.close
        
        Tk::Message.messageBox :icon => 'info',
            :title => 'Marketing alterado',
            :message => 'O marketing foi alterado com sucesso!'
        @nn.destroy
    end

    @nn = Tk::Toplevel.new do 
        title 'Alterar o marketing'
        bg read['theme']['backgroundColor']
    end
    
    @nn.minsize 300, 200
    @nn.iconbitmap '../images/icone.ico'

    lb = Tk::Label.new @nn do 
        text 'Alterar: '
        bg read['theme']['backgroundColor']
    end

    @en = Tk::Entry.new @nn
    @en.insert 0, read['nome']
    @en.selection_range 0, 100

    bt = Tk::Button.new @nn do 
        text 'Mudar'
    end

    lb.pack :side => 'left', :expand => true
    @en.pack :side => 'left', :expand => true
    bt.pack :side => 'left', :expand => true

    bt.configure :command => proc { mude }
end

# // manipulação da aparencia com cores----------------------------------
def tema
    @main = Tk::Toplevel.new do 
        bg read['theme']['backgroundColor']
        title "Configurar aparência "
    end
    
    @main.geometry '450x450+400+0'
    @main.iconbitmap '../images/icone.ico'
    
    # // manipula a hash de cores de acordo com o id do botão pressionado
    def manipule id
        dict = read
        
        case id 
        when 1
            colorbutton = Tk.chooseColor
            if colorbutton == "" 
                return
            end
            dict["theme"]["backgroundButtons"] = colorbutton.to_s
        when 2
            colorfont = Tk.chooseColor
            if colorfont == ""
                return 
            end
            dict["theme"]["foregroundButtons"] = colorfont.to_s
        when 3
            colorback = Tk.chooseColor
            if colorback == ""
                return
            end
            dict["theme"]["backgroundColor"] = colorback.to_s
        when 4
            coloraux = Tk.chooseColor
            if coloraux == ""
                return
            end
            dict["theme"]["auxiliarBackground"] = coloraux.to_s
        when 5
            colormarket = Tk.chooseColor
            if colormarket == ""
                return
            end
            dict["theme"]["marketColor"] = colormarket.to_s
        end
        
        novo = JSON.generate dict
        arq = File.new "../conf/conf.json", "w"
        arq.puts novo
        arq.close
        @main.destroy
        tema
    end
    
    # // Todos os botões logo abaixo *devem fornecer um id para identificação
    bt1 = Tk::Button.new @main do 
        text "cor dos botões"
        width 25
        height 5
        bg read['theme']['backgroundButtons']
    end
    
    bt1.pack :expand => true,
             :side => 'top'
    bt1.configure :command => proc { manipule 1 }

    bt2 = Tk::Button.new @main do 
        text "cor da fonte"
        width 25
        height 5
        bg read['theme']['foregroundButtons']
    end
    
    bt2.pack :expand => true,
             :side => 'top'
    bt2.configure :command => proc { manipule 2 }

    bt3 = Tk::Button.new @main do 
        text "cor de fundo"
        width 25
        height 5
        bg read['theme']['backgroundColor']
    end
    
    bt3.pack :expand => true,
             :side => 'top'
    bt3.configure :command => proc { manipule 3 }

    bt4 = Tk::Button.new @main do 
        text "cor da lateral"
        width 25
        height 5
        bg read['theme']['auxiliarBackground']
    end
    
    bt4.pack :expand => true,
            :side => 'top'
    bt4.configure :command => proc { manipule 4 }

    bt5 = Tk::Button.new @main do 
        text "cor da propaganda"
        width 25
        height 5
        bg read['theme']['marketColor']
    end
    
    bt5.pack :expand => true,
             :side => 'top'
    bt5.configure :command => proc { manipule 5 }
end
