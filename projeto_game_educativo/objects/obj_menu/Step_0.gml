
// obj_menu - Step
var w = display_get_gui_width();
var h = display_get_gui_height();
var confirmar = false;

if (menu_tela == 0) {

    // Navegacao pelo teclado
    if (keyboard_check_pressed(vk_down) ||
        keyboard_check_pressed(ord("S"))) {
        menu_selecao = (menu_selecao + 1) mod 3;
    }

    if (keyboard_check_pressed(vk_up) ||
        keyboard_check_pressed(ord("W"))) {
        menu_selecao = (menu_selecao + 2) mod 3;
    }

    // Mouse e areas clicaveis
    var mx = device_mouse_x_to_gui(0);
    var my = device_mouse_y_to_gui(0);
    var bx1 = w * 0.40;
    var bx2 = w * 0.63;
    var bh = h * 0.075;

    for (var i = 0; i < 3; i++) {
        var by = h * (0.50 + i * 0.08);

        if (mx >= bx1 && mx <= bx2 &&
            my >= by - bh / 2 &&
            my <= by + bh / 2) {

            // Mouse movido ou clique
            if (mx != menu_mouse_anterior_x ||
                my != menu_mouse_anterior_y ||
                mouse_check_button_pressed(mb_left)) {
                menu_selecao = i;
            }

            if (mouse_check_button_pressed(mb_left)) {
                confirmar = true;
            }
            break;
        }
    }

    // Confirmar pelo teclado
    if (keyboard_check_pressed(vk_enter) ||
        keyboard_check_pressed(vk_space)) {
        confirmar = true;
    }

    if (confirmar) {
        switch (menu_selecao) {
            case 0: room_goto_next(); break;
            case 1: menu_tela = 1; break;
            case 2: game_end(); break;
        }
    }

    menu_mouse_anterior_x = mx;
    menu_mouse_anterior_y = my;

} else {

    // Voltar das instrucoes
    if (keyboard_check_pressed(vk_escape) ||
        keyboard_check_pressed(vk_enter) ||
        keyboard_check_pressed(vk_backspace) ||
        mouse_check_button_pressed(mb_left)) {
        menu_tela = 0;
    }
}
