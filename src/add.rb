require 'tk'
require_relative 'crud'

def manipulation
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
                    :title => 'Preço inválido', :message =>'Insira um preço válido'
            return
        end
        if exist[0].nil?
            db_insert cod, pro, pre
            @lb_in.insert 0, "cod: " + cod + " "*15 + pro + " "*15 + "R$ " + pre.to_s
            Tk::Message.messageBox :icon => 'info',
                    :title => 'Cadastrado!', :message => pro + ' cadastrado com sucesso'
            @ent1.delete 0, 100
            @ent2.delete 0, 100
            @ent3.delete 0, 100
            @ent1.set_focus
        else
            Tk::Message.messageBox :icon => 'error',
                :title => 'Erro', :message => 
                    """
                    O código inserido está sendo usado 
                    por favor insira um código diferente\n
                    USADO POR: #{exist[0][1]}
                    """    
        end
    end

    def edit 
        puts 'limpando'
    end

    # // Inicio da janela de manipulação de banco de dados
    app = Tk::Toplevel.new do title 'Manipular Cadastro de produtos'; bg 'gray' end
    app.geometry "650x300+300+0"

    fonte = TkFont.new :size => 15, :family => 'Arial', :weight => 'bold'

    frame1 = Tk::Frame.new app do bg 'gray'; pack :expand => true end
    frame2 = Tk::Frame.new app do bg 'gray'; pack :expand => true end
    frame3 = Tk::Frame.new app do bg 'gray'; pack :expand => true end

    lbs1 = Tk::Label.new frame1 do bg 'gray'; font fonte; text 'Cod'; 
        pack :anchor => 's', :fill => 'x', :side => 'left', :padx => 50 end

    lbs2 = Tk::Label.new frame1 do bg 'gray'; font fonte; text 'Des';
        pack :anchor => 's', :fill => 'x', :side => 'left', :padx => 50 end

    lbs3 = Tk::Label.new frame1 do bg 'gray'; font fonte; text 'Pre';
        pack :anchor => 's', :fill => 'x', :side => 'left', :padx => 50 end

    @ent1 = Tk::Entry.new frame2 do font fonte; pack :anchor => 'n', :side => 'left' end
    @ent1.focus
    @ent2 = Tk::Entry.new frame2 do font fonte; pack :anchor => 'n', :side => 'left' end
    @ent3 = Tk::Entry.new frame2 do font fonte; pack :anchor => 'n', :side => 'left' end
    @ent3.bind 'Return', proc { cad }

    @fr_s = Tk::Frame.new frame3 do bg 'gray'; pack :side => 'top' end
    @lb_s = Tk::Label.new @fr_s do font fonte; text 'Buscar'; bg 'gray';
        fg 'white';pack :side => 'left' end
    @ent_search = Tk::Entry.new @fr_s do pack :side => 'left' end

    @lb_in = Tk::Listbox.new frame3 do width 600;
        pack :expand => true , :fill => 'x', :pady => 10 end

    bt0 = Tk::Button.new frame3 do text 'Cadastrar'; pack :side => 'left', :padx => 10 end
    bt0.configure :command => proc { cad }
    bt0.bind 'Return', proc { cad }

    bt1 = Tk::Button.new frame3 do text 'Editar'; pack :side => 'left', :padx => 10 end
    bt1.configure :command => proc { edit }
    bt1.bind 'Return', proc { edit }

    bt2 = Tk::Button.new frame3 do text 'Remover'; pack :side => 'left', :padx => 10 end
    bt2.configure :command => proc { cad }
    bt2.bind 'Return', proc { cad }

    bt3 = Tk::Button.new frame3 do text 'Listar'; pack :side => 'left', :padx => 10 end
    bt3.configure :command => proc { cad }
    bt3.bind 'Return', proc { cad }

    bt4 = Tk::Button.new frame3 do text 'Limpar'; pack :side => 'left', :padx => 10 end
    bt4.configure :command => proc { @lb_in.clear }
    bt4.bind 'Return', proc { @lb_in.clear }
end

#manipulation