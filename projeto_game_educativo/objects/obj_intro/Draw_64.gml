
/// @description Exibe o video de abertura

// Dimensoes da interface
var gui_w = display_get_gui_width();
var gui_h = display_get_gui_height();

// Fundo preto
draw_set_color(c_black);
draw_rectangle(0, 0, gui_w, gui_h, false);
draw_set_color(c_white);

// Obtem o quadro atual do video
var dados = video_draw();

// Verifica se o video esta reproduzindo
if (dados[0] == 0 &&
    video_get_status() == video_status_playing) {

    var surf = dados[1];

    if (surface_exists(surf)) {

        var largura = surface_get_width(surf);
        var altura = surface_get_height(surf);

        // Ajusta sem distorcer
        var escala = min(
            gui_w / largura,
            gui_h / altura
        );

        var nova_largura = largura * escala;
        var nova_altura = altura * escala;

        // Centraliza na tela
        var pos_x = (gui_w - nova_largura) / 2;
        var pos_y = (gui_h - nova_altura) / 2;

        draw_surface_stretched(
            surf,
            pos_x,
            pos_y,
            nova_largura,
            nova_altura
        );
    }
}
