
// obj_menu - Create
// ---- SOM do menu ----
audio_stop_all();
if (!variable_global_exists("vol_sfx")) global.vol_sfx = 1;
if (!variable_global_exists("vol_musica")) global.vol_musica = 1;
if (!variable_global_exists("mudo")) global.mudo = false;
audio_master_gain(global.mudo ? 0 : 1);
tocar_som = function(_snd, _vol = 1, _pitch = 1) {
    var _id = audio_play_sound(_snd, 10, false);
    audio_sound_gain(_id, _vol * global.vol_sfx, 0);
    audio_sound_pitch(_id, _pitch);
    return _id;
};
musica_menu = audio_play_sound(mus_menu, 1, true);
audio_sound_gain(musica_menu, 0.5 * global.vol_musica, 0);

menu_tela = 0;
menu_selecao = 0;
menu_titulos = ["JOGAR", "COMO JOGAR", "SAIR"];

menu_mouse_anterior_x = -1;
menu_mouse_anterior_y = -1;


// =====================================================================
// LOGIN DE USUARIO (contas locais, guardadas neste computador)
// =====================================================================
randomize();
if (!variable_global_exists("usuario")) global.usuario = "";

arquivo_contas = "usuarios.json";
contas = [];                     // lista de { nome, sal, hash }
login_modo = 0;                  // 0 = entrar | 1 = criar conta
login_campo = 0;                 // campo ativo: 0 usuario, 1 senha, 2 confirmar senha
login_campos = ["", "", ""];
login_msg = "";
login_msg_ok = false;

// Mantem so os caracteres validos de cada campo.
// Usuario: letras minusculas, numeros, _ e - (ate 16). Senha: qualquer caractere (ate 24).
limpar_login = function(_txt, _campo) {
    var _max = (_campo == 0) ? 16 : 24;
    var _out = "";
    for (var i = 1; i <= string_length(_txt); i++) {
        var _c = string_char_at(_txt, i);
        if (_campo == 0) {
            _c = string_lower(_c);
            if (string_pos(_c, "abcdefghijklmnopqrstuvwxyz0123456789_-") == 0) continue;
        } else if (ord(_c) < 32) {
            continue;
        }
        _out += _c;
        if (string_length(_out) >= _max) break;
    }
    return _out;
};

// ---------- ARQUIVO DE CONTAS ----------
carregar_contas = function() {
    var _lista = [];
    if (!file_exists(arquivo_contas)) return _lista;
    try {
        var _f = file_text_open_read(arquivo_contas);
        var _txt = "";
        while (!file_text_eof(_f)) { _txt += file_text_read_string(_f); file_text_readln(_f); }
        file_text_close(_f);
        var _d = json_parse(_txt);
        if (is_struct(_d) && variable_struct_exists(_d, "contas") && is_array(_d.contas)) {
            for (var i = 0; i < array_length(_d.contas); i++) {
                var _c = _d.contas[i];
                if (is_struct(_c) && variable_struct_exists(_c, "nome")
                    && variable_struct_exists(_c, "sal") && variable_struct_exists(_c, "hash")) {
                    array_push(_lista, _c);
                }
            }
        }
    } catch (_e) {
        // arquivo ilegivel: trata como se nao houvesse contas
    }
    return _lista;
};

salvar_contas = function() {
    var _f = file_text_open_write(arquivo_contas);
    file_text_write_string(_f, json_stringify({ contas: contas }));
    file_text_close(_f);
};

conta_buscar = function(_nome) {
    for (var i = 0; i < array_length(contas); i++) {
        if (contas[i].nome == _nome) return contas[i];
    }
    return undefined;
};

// ---------- SENHA (nunca guardada em texto puro) ----------
gerar_sal = function() {
    var _s = "";
    repeat (16) _s += chr(irandom_range(97, 122));
    return _s;
};

hash_senha = function(_sal, _senha) {
    var _h = _sal + _senha;
    repeat (1000) _h = sha1_string_utf8(_h + _sal);
    return _h;
};

// ---------- ACOES ----------
login_ir_campo = function(_i) {
    login_campo = _i;
    keyboard_string = login_campos[_i];
};

login_limpar = function() {
    login_campos = ["", "", ""];
    login_campo = 0;
    keyboard_string = "";
};

login_alternar_modo = function() {
    login_modo = 1 - login_modo;
    login_limpar();
    login_msg = "";
};

login_concluir = function(_nome) {
    global.usuario = _nome;
    login_limpar();
    login_msg = "";
    menu_tela = 0;
    tocar_som(snd_menu_ok, 0.8);
};

login_sair = function() {
    global.usuario = "";
    login_modo = 0;
    login_limpar();
    login_msg = "";
    menu_tela = 2;
};

tentar_entrar = function() {
    var _nome = login_campos[0];
    var _senha = login_campos[1];
    login_msg_ok = false;
    if (_nome == "" || _senha == "") { login_msg = "Preencha usuario e senha."; return; }
    var _c = conta_buscar(_nome);
    // mesma mensagem para usuario inexistente e senha errada
    if (_c == undefined || hash_senha(_c.sal, _senha) != _c.hash) {
        login_msg = "Usuario ou senha incorretos.";
        login_campos[1] = "";
        if (login_campo == 1) keyboard_string = "";
        return;
    }
    login_concluir(_nome);
};

tentar_criar = function() {
    var _nome = login_campos[0];
    var _senha = login_campos[1];
    login_msg_ok = false;
    if (string_length(_nome) < 3)  { login_msg = "Usuario: minimo 3 caracteres."; return; }
    if (_nome == "convidado")      { login_msg = "Esse nome nao pode ser usado."; return; }
    if (string_length(_senha) < 4) { login_msg = "Senha: minimo 4 caracteres."; return; }
    if (_senha != login_campos[2]) { login_msg = "As senhas nao conferem."; return; }
    if (conta_buscar(_nome) != undefined) { login_msg = "Este usuario ja existe."; return; }

    var _sal = gerar_sal();
    array_push(contas, { nome: _nome, sal: _sal, hash: hash_senha(_sal, _senha) });
    salvar_contas();
    login_concluir(_nome);
};

login_confirmar = function() {
    if (login_modo == 1) tentar_criar(); else tentar_entrar();
    if (menu_tela == 2) tocar_som(snd_erro, 0.6); // continua no login = deu erro
};

// ---------- LAYOUT (usado pelo Step e pelo Draw) ----------
// 0..2 = campos | 10 = botao confirmar | 11 = link para trocar de modo
login_retangulo = function(_i) {
    var _w = display_get_gui_width();
    var _h = display_get_gui_height();
    var _cx = _w / 2;
    var _lw = _w * 0.34;
    var _yb = _h * ((login_modo == 1) ? 0.70 : 0.59);
    if (_i < 3)  { var _yc = _h * (0.37 + _i * 0.105); return { x1: _cx - _lw / 2, y1: _yc, x2: _cx + _lw / 2, y2: _yc + _h * 0.065 }; }
    if (_i == 10) return { x1: _cx - _lw / 2, y1: _yb, x2: _cx + _lw / 2, y2: _yb + _h * 0.07 };
    return { x1: _cx - _lw / 2, y1: _yb + _h * 0.095, x2: _cx + _lw / 2, y2: _yb + _h * 0.145 };
};

// ---------- STEP DA TELA DE LOGIN ----------
login_step = function() {
    var _n = (login_modo == 1) ? 3 : 2;

    // texto digitado no campo ativo
    login_campos[login_campo] = limpar_login(keyboard_string, login_campo);
    keyboard_string = login_campos[login_campo];

    if (keyboard_check_pressed(vk_tab) || keyboard_check_pressed(vk_down)) login_ir_campo((login_campo + 1) mod _n);
    if (keyboard_check_pressed(vk_up)) login_ir_campo((login_campo - 1 + _n) mod _n);
    if (keyboard_check_pressed(vk_f1)) { login_alternar_modo(); return; }
    if (keyboard_check_pressed(vk_escape)) { game_end(); return; }

    if (keyboard_check_pressed(vk_enter)) {
        if (login_campo < _n - 1) login_ir_campo(login_campo + 1);
        else { login_confirmar(); return; }
    }

    if (mouse_check_button_pressed(mb_left)) {
        var _mx = device_mouse_x_to_gui(0);
        var _my = device_mouse_y_to_gui(0);
        for (var i = 0; i < _n; i++) {
            var _r = login_retangulo(i);
            if (point_in_rectangle(_mx, _my, _r.x1, _r.y1, _r.x2, _r.y2)) login_ir_campo(i);
        }
        var _rb = login_retangulo(10);
        if (point_in_rectangle(_mx, _my, _rb.x1, _rb.y1, _rb.x2, _rb.y2)) { login_confirmar(); return; }
        var _rl = login_retangulo(11);
        if (point_in_rectangle(_mx, _my, _rl.x1, _rl.y1, _rl.x2, _rl.y2)) { login_alternar_modo(); return; }
    }
};

// ---------- DRAW GUI DA TELA DE LOGIN ----------
login_draw = function() {
    var _w = display_get_gui_width();
    var _h = display_get_gui_height();
    var _e = _h / 720;
    var _cx = _w / 2;
    var _n = (login_modo == 1) ? 3 : 2;
    var _ouro = make_color_rgb(243, 190, 95);
    var _painel = make_color_rgb(30, 52, 49);
    var _escuro = make_color_rgb(22, 38, 36);

    draw_sprite_stretched(spr_menu_fundo, 0, 0, 0, _w, _h);
    draw_set_alpha(0.7);
    draw_set_color(c_black);
    draw_rectangle(0, 0, _w, _h, false);
    draw_set_alpha(1);

    var _py2 = _h * ((login_modo == 1) ? 0.92 : 0.84);
    draw_set_color(_painel);
    draw_roundrect(_cx - _w * 0.21, _h * 0.18, _cx + _w * 0.21, _py2, false);
    draw_set_color(_ouro);
    draw_roundrect(_cx - _w * 0.21, _h * 0.18, _cx + _w * 0.21, _py2, true);

    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);
    draw_set_color(_ouro);
    draw_text_transformed(_cx, _h * 0.25, (login_modo == 1) ? "CRIAR CONTA" : "ENTRAR", 1.8 * _e, 1.8 * _e, 0);

    var _rotulos = ["Usuario", "Senha", "Confirmar senha"];
    for (var i = 0; i < _n; i++) {
        var _r = login_retangulo(i);
        var _ativo = (i == login_campo);

        draw_set_halign(fa_left);
        draw_set_valign(fa_bottom);
        draw_set_color(c_white);
        draw_text_transformed(_r.x1, _r.y1 - 4 * _e, _rotulos[i], _e, _e, 0);

        draw_set_color(_ativo ? make_color_rgb(52, 84, 78) : _escuro);
        draw_roundrect(_r.x1, _r.y1, _r.x2, _r.y2, false);
        draw_set_color(_ativo ? _ouro : make_color_rgb(110, 120, 115));
        draw_roundrect(_r.x1, _r.y1, _r.x2, _r.y2, true);

        var _t = login_campos[i];
        if (i > 0) _t = string_repeat("*", string_length(_t));
        if (_ativo && ((current_time div 500) mod 2 == 0)) _t += "|";
        draw_set_valign(fa_middle);
        draw_set_color(c_white);
        draw_text_transformed(_r.x1 + 10 * _e, (_r.y1 + _r.y2) / 2, _t, _e, _e, 0);
    }

    // botao confirmar
    var _rb = login_retangulo(10);
    draw_set_color(_ouro);
    draw_roundrect(_rb.x1, _rb.y1, _rb.x2, _rb.y2, false);
    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);
    draw_set_color(_escuro);
    draw_text_transformed(_cx, (_rb.y1 + _rb.y2) / 2, (login_modo == 1) ? "CRIAR E ENTRAR" : "ENTRAR", 1.2 * _e, 1.2 * _e, 0);

    // link para trocar de modo
    var _rl = login_retangulo(11);
    draw_set_color(c_white);
    draw_text_transformed(_cx, (_rl.y1 + _rl.y2) / 2,
        (login_modo == 1) ? "Ja tenho conta (F1)" : "Criar nova conta (F1)", _e, _e, 0);

    // mensagem de erro / sucesso
    if (login_msg != "") {
        draw_set_color(login_msg_ok ? make_color_rgb(137, 230, 155) : make_color_rgb(235, 110, 110));
        draw_text_transformed(_cx, _rl.y2 + 22 * _e, login_msg, _e, _e, 0);
    }

    // comandos
    draw_set_color(_ouro);
    draw_text_transformed(_cx, _h * 0.95, "TAB: proximo campo   ENTER: confirmar   F1: entrar / criar conta   ESC: sair", _e, _e, 0);

    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
};

// ---------- INICIALIZACAO ----------
contas = carregar_contas();
keyboard_string = "";
menu_tela = (global.usuario == "") ? 2 : 0;   // sem usuario logado, comeca pelo login
