require 'tk'
require_relative 'crud'
require_relative 'loadconf'

def manipulation
    bgg = read['theme']['backgroundColor']
    fgb = read['theme']['foregroundButtons']
    bgb = read['theme']['backgroundButtons']
    # // Faz o cadastro
    def cad 
        cod = @ent1.get.strip
        pro = @ent2.get.strip
        pre = @ent3.get.gsub(",", ".")
        exist = db_query cod
        begin 
            pre = Float pre
        rescue
            Tk::Message.messageBox :icon => 'error',
                    :title => 'Preço inválido', 
                    :message =>'Insira um preço válido'
            return
        end
        if exist[0].nil?
            if cod != "" and pro != "" and pre != ""
                db_insert cod, pro, pre
                @lb_in.insert 0, "cod: " + cod + " "*15 + pro + " "*15 + "R$ " + pre.to_s
                Tk::Message.messageBox :icon => 'info',
                        :title => 'Cadastrado!', 
                        :message => pro + ' cadastrado com sucesso'
                @ent1.delete 0, 100
                @ent2.delete 0, 100
                @ent3.delete 0, 100
                @ent1.set_focus
            else
                Tk::Message.messageBox :icon => 'error',
                    :title => 'Campo em branco', 
                    :message =>'Não pode haver campos em branco'
                return
            end
        else
            Tk::Message.messageBox :icon => 'error',
                        :title => 'Erro', 
                        :message =>
                    """
                    O código inserido está sendo usado 
                    por favor insira um código diferente\n
                    USADO POR: #{exist[0][1]}
                    """    
        end
    end
    
    # // prepara os  updates nos cadastros
    def edit
        @ent1.delete 0, 100
        @ent2.delete 0, 100
        @ent3.delete 0, 100 
        begin
            indice = @lb_in.curselection
            valor  = @lb_in.value            
            item   = valor[indice[0]].strip
            ind = nil
            for x in 0..$lista.length do 
                if $lista[x][1] == item 
                    ind = x
                    break
                end
            end
            @ent1.insert 0, $lista[ind][0] 
            @ent2.insert 0, $lista[ind][1] 
            @ent3.insert 0, $lista[ind][2]
            @ent2.configure :state => 'disabled'
            @bt0.configure :state => 'disabled'
            @bt1.configure :state => 'disabled'
            @bt2.configure :state => 'disabled'
            @bt3.configure :state => 'disabled'
            @bt4.configure :state => 'disabled'
            @bt5.configure :state => 'normal'
        rescue
            puts
        end
    end
    
    # // confirmar updates dos itens
    def conf_update
        t_cod = @ent1.get
        t_pro = @ent2.get
        t_pre = @ent3.get.gsub(',', '.')
        begin 
            t_pre = Float t_pre
        rescue
            Tk::Message.messageBox :icon => 'error',
                                   :title => 'Preço inválido',
                                   :message =>'Insira um preço válido'
        end
        db_update t_cod, t_pro, t_pre
        Tk::Message.messageBox :icon => 'info',
                               :title => 'Alterado',
                               :message => 'Alterado com sucesso'
        @ent2.configure :state => 'normal'
        @bt0.configure :state =>  'normal'
        @bt1.configure :state =>  'disabled'
        @bt2.configure :state =>  'normal'
        @bt3.configure :state =>  'normal'
        @bt4.configure :state =>  'normal'
        @bt5.configure :state =>  'disabled'
        @ent1.delete 0, 100   
        @ent2.delete 0, 100   
        @ent3.delete 0, 100   
    end
    
    # /// Lista todos os produtos cadastrados na listBox
    # o pipe '|' é importante para o filtro da lista caso falte a listagem não funciona
    def listar
        $estado = 1 
        col_a = 30
        @lb_in.clear
        $lista = db_listing
        $lista.each do |pr|
            a = pr[0].length
            @lb_in.insert 0, "codigo: " + pr[0] + " "*(col_a - a) + "|  " + pr[1]
        end
    end

    # // Remove itens do banco de dados
    def remove 
        begin
            indice = @lb_in.curselection
            valor  = @lb_in.value            
            item   = valor[indice[0]].strip
            $i = nil
            tam = item.length
            for x in 0..tam do 
                if item[x] == '|' 
                    $i = x
                end
            end
            item = item[$i + 2, tam]
            resp   = Tk::Message.messageBox :icon => 'warning',
                    :title => 'Excluir', :type => 'yesno',
                    :message =>'Tem certeza que deseja excluir ' + item + ' do cadastro?'
            if resp == 'no'
                return
            end
            db_remove item.strip
            @lb_in.delete indice
            @ent_search.delete 0, 100
        rescue
            Tk::Message.messageBox :icon => 'info',
                                   :title => 'Excluir', 
                                   :message => 'Selecione um item'
        end
    end

    # // faz a busca dinamica no campo de pesquisa
    def busca 
        @lb_in.clear
        if !$estado.nil?
            @bt1.configure :state => 'normal'
        end
        lista = db_search @ent_search.get
        lista.each do |itens|
            @lb_in.insert 0, " "*5 + itens[1]
        end
    end

    # // Inicio da janela de manipulação de banco de dados
    ######################################################
    app = Tk::Toplevel.new do
        title 'Manipular Cadastro de produtos'
        bg bgg 
    end
    app.geometry "650x400+300+0"
    app.resizable false, false
    app.iconbitmap '../images/icone.ico'

    fonte = TkFont.new :size => 15,
                       :family => 'Arial',
                       :weight => 'bold'

    # // inicio dos frames______________
    frame1 = Tk::Frame.new app do
        bg bgg 
        pack :expand => true 
    end 
    frame2 = Tk::Frame.new app do
        bg bgg 
        pack :expand => true 
    end
    frame3 = Tk::Frame.new app do 
        bg bgg 
        pack :expand => true 
    end
    
    # // inicio dos labels
    Tk::Label.new frame1 do
        bg bgg
        font fonte
        text 'Cod' 
        pack :anchor => 's',
             :fill => 'x',
             :side => 'left',
             :padx => 50 
    end

    Tk::Label.new frame1 do
        bg bgg 
        font fonte
        text 'Des'
        pack :anchor => 's', 
             :fill => 'x',
             :side => 'left',
             :padx => 50
     end

    Tk::Label.new frame1 do
        bg bgg 
        font fonte
        text 'Pre'
        pack :anchor => 's',
             :fill => 'x',
             :side => 'left',
             :padx => 50
    end
    
    # // inicio dos entrys
    @ent1 = Tk::Entry.new frame2 do
        font fonte
        pack :anchor => 'n',
             :side => 'left' 
    end
    @ent1.set_focus
    @ent2 = Tk::Entry.new frame2 do
        font fonte
        pack :anchor => 'n', 
             :side => 'left' 
    end
    @ent3 = Tk::Entry.new frame2 do
        font fonte
        pack :anchor => 'n',
             :side => 'left' 
    end
    @ent3.bind 'Return', proc { cad }
    # // campo de busca ____
    @fr_s = Tk::Frame.new frame3 do
        bg bgg
        pack :side => 'top' 
    end
    @lb_s = Tk::Label.new @fr_s do
        font fonte
        text 'Buscar'
        bg bgg
        fg fgb 
        pack :side => 'left' 
    end
    @ent_search = Tk::Entry.new @fr_s do
        pack :side => 'left' 
    end
    @ent_search.bind 'KeyPress', proc { busca }

    @lb_in = Tk::Listbox.new frame3 do
        width 600
        height 15;
        pack :expand => true,
             :fill => 'x',
             :pady => 10 
    end

    # // inicio dos buttons
    @bt0 = Tk::Button.new frame3 do
        text 'Cadastrar'
        bg bgb
        fg fgb
        pack :side => 'left',
             :padx => 10 
    end
    @bt0.configure :command => proc { cad }
    @bt0.bind 'Return', proc { cad }

    @bt1 = Tk::Button.new frame3 do
        bg bgb
        fg fgb
        text 'Editar'
        pack :side => 'left',
             :padx => 10 
    end
    @bt1.configure :command => proc { edit },
        :state => 'disabled', :bg => 'yellow'
    @bt1.bind 'Return', proc { edit }

    @bt2 = Tk::Button.new frame3 do
        text 'Remover'
        bg bgb
        fg fgb
        pack :side => 'left',
             :padx => 10 
    end
    @bt2.configure :command => proc { remove }
    @bt2.bind 'Return', proc { remove }

    @bt3 = Tk::Button.new frame3 do
        text 'Listar'
        bg bgb
        fg fgb
        pack :side => 'left',
             :padx => 10 
    end
    @bt3.configure :command => proc { listar }
    @bt3.bind 'Return', proc { listar }

    @bt4 = Tk::Button.new frame3 do
        text 'Limpar'
        bg bgb
        fg fgb
        pack :side => 'left',
             :padx => 10 
    end
    @bt4.configure :command => proc { @lb_in.clear }
    @bt4.bind 'Return', proc { @lb_in.clear }

    @bt5 = Tk::Button.new frame3 do
        bg 'yellow'
        text 'Update'
        pack :side => 'left',
             :padx => 10 
    end
    @bt5.configure :state => 'disabled', :command => proc { conf_update }
    @bt5.bind 'Return', proc { conf_update }
end