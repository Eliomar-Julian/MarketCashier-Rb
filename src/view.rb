require 'tk'
require_relative 'loadconf'

class Application
    FG  = read['theme']['fg0']
    BG  = read['color']['bg0']
    BG2 = read['color']['bg1']
    def initialize 
        @root = Tk::Root.new do title "Sale Market - by Leo" end
        wid = @root.winfo_screenwidth
        hei = @root.winfo_screenheight
        center_x = Integer (wid - 800) / 2
        center_y = Integer (hei - 600) / 2
        @root.geometry "#{800}x#{600}+#{center_x}+#{center_y}"
        @root.configure :bg => BG
        self.start_widgets
    end

    def start_widgets
        # // configure fonts
        @font_title = TkFont.new :family => 'Arial', :size => 50, :weight => 'bold'
        @font_media = TkFont.new :family => 'Arial', :size => 20, :weight => 'bold'
        @font_minim = TkFont.new :family => 'Arial', :size => 8
        
        # // Configure Frames
        @frame1 = Tk::Frame.new @root
        @frame2 = Tk::Frame.new @root do bg BG2 end
        @frame3 = Tk::Frame.new @root do bg BG end
        @frame4 = Tk::Frame.new @root do bg BG2 end

        @frame1.pack :fill => 'x', :side => 'top'
        @frame2.pack :fill => 'y', :side => 'left', :expand => true
        @frame3.pack :fill => 'y', :side => 'left', :expand => true
        @frame4.pack :fill => 'y', :side => 'left', :expand => true
        
        # // insert Widgets
        @lb_title = Tk::Label.new @frame1 do text 'Supermercado Santanna' end # frame1
        
        @bt_final = Tk::Button.new @frame2 do text 'Finalizar' end # frame2
        @bt_cance = Tk::Button.new @frame2 do text 'Cancelar' end
        @bt_retir = Tk::Button.new @frame2 do text 'Retirar' end
        @bt_liber = Tk::Button.new @frame2 do text 'Liberar' end
        
        @lb_codig = Tk::Label.new @frame3 do text 'Código' end # frame3
        @en_codig = Tk::Entry.new @frame3
        @lv_codig = Tk::Listbox.new @frame3

        @lb_preco = Tk::Label.new @frame4 do text 'Preço' end # frame4
        @lb_p_atu = Tk::Label.new @frame4 do text 'R$ 0,00' end
        @lb_total = Tk::Label.new @frame4 do text 'Total' end
        @lb_p_tot = Tk::Label.new @frame4 do text 'R$ 0,00' end

        # // configure widgets
        @lb_title.configure :font => @font_title, :bg => BG, :fg => FG
        @bt_final.configure :font => @font_media, :fg => FG
        @bt_cance.configure :font => @font_media, :fg => FG 
        @bt_retir.configure :font => @font_media, :fg => FG 
        @bt_liber.configure :font => @font_media, :fg => FG
        
        @lb_codig.configure :font => @font_media, :bg => BG, :fg => FG
        @en_codig.configure :font => @font_media
        @en_codig.focus

        @lb_preco.configure :font => @font_media, :bg => BG2
        @lb_p_atu.configure :font => @font_title, :bg => BG2, :fg => 'blue'
        @lb_total.configure :font => @font_media, :bg => BG2
        @lb_p_tot.configure :font => @font_title, :bg => BG2, :fg => 'orange'
        
        # // position widgets
        @lb_title.pack :fill => 'x'
        @bt_final.pack :fill => 'x', :expand => true, :padx => 30
        @bt_cance.pack :fill => 'x', :expand => true, :padx => 30
        @bt_retir.pack :fill => 'x', :expand => true, :padx => 30
        @bt_liber.pack :fill => 'x', :expand => true, :padx => 30

        @lb_codig.pack :fill => 'x'
        @en_codig.pack :fill => 'x'
        @lv_codig.pack :fill => 'x'

        @lb_preco.pack :expand => true
        @lb_p_atu.pack :expand => true
        @lb_total.pack :expand => true
        @lb_p_tot.pack :expand => true    
    end

    def run  
        Tk.mainloop 
    end

end