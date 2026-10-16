
/// obj_menu - Draw GUI

var w = display_get_gui_width();
var h = display_get_gui_height();

draw_set_color(c_white);
draw_set_alpha(1);

if (menu_tela == 0) {

    draw_sprite_stretched(spr_menu_fundo, 0, 0, 0, w, h);

    // Posicao do botao selecionado
    var bx1 = w * 0.40;
    var bx2 = w * 0.63;
    var by = h * (0.50 + menu_selecao * 0.08);
    var bh = h * 0.075;

    // Brilho pulsante
    var pulso = 0.5 + 0.5 * sin(current_time / 230);

    draw_set_color(make_color_rgb(255, 205, 55));
    draw_set_alpha(0.55 + 0.35 * pulso);

    // Contorno dourado
    draw_roundrect(
        bx1 - 6, by - bh / 2 - 6,
        bx2 + 6, by + bh / 2 + 6, true
    );

    // Contorno branco
    draw_set_color(c_white);
    draw_set_alpha(1);

    draw_roundrect(
        bx1 - 3, by - bh / 2 - 3,
        bx2 + 3, by + bh / 2 + 3, true
    );

} else {
    draw_sprite_stretched(spr_menu_instrucoes, 0, 0, 0, w, h);
}

draw_set_color(c_white);
draw_set_alpha(1);
