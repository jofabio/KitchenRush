/// KITCHENRUSH | DRAW GUI | INTERFACE V3 (1280 x 720)
/// Este evento substitui TODO o Draw GUI antigo do obj_cozinha.
/// Todas as coordenadas da logica de jogo continuam iguais.

// -------------------------------------------------------------
// 1. PALETA E PREPARACAO
// -------------------------------------------------------------
var W = 1280;
var H = 720;
var cor_fundo = make_color_rgb(239, 231, 211);
var cor_piso = make_color_rgb(218, 204, 178);
var cor_junta = make_color_rgb(194, 178, 153);
var cor_madeira = make_color_rgb(113, 81, 58);
var cor_painel = make_color_rgb(30, 52, 49);
var cor_escuro = make_color_rgb(22, 38, 36);
var cor_claro = make_color_rgb(255, 248, 229);
var cor_ouro = make_color_rgb(243, 190, 95);
var cor_verde = make_color_rgb(75, 160, 103);

// Evita herdar alinhamento/alpha de telas ou eventos anteriores.
draw_set_alpha(1);
draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_color(c_white);

// -------------------------------------------------------------
// 2. FUNDO, COZINHA EXPANDIDA E PISO
// -------------------------------------------------------------
draw_set_color(cor_fundo);
draw_rectangle(0, 0, W, H, false);

// Area jogavel: agora ocupa praticamente toda a largura do jogo.
draw_set_color(cor_piso);
draw_rectangle(24, 165, 1256, 626, false);

draw_set_color(cor_junta);
for (var gx = 20; gx <= 940; gx += 40) {
    var linha_x = ui_map_x(gx);
    draw_line(linha_x, 165, linha_x, 626);
}
for (var gy = 110; gy <= 615; gy += 40) {
    var linha_y = ui_map_y(gy);
    draw_line(24, linha_y, 1256, linha_y);
}

// Paredes com a mesma geometria da cozinha original.
draw_set_color(cor_madeira);
draw_rectangle(18, 157, 1262, 172, false);
draw_rectangle(18, 157, 31, 632, false);
draw_rectangle(1249, 157, 1262, 632, false);
draw_rectangle(18, 625, 1262, 632, false);

// -------------------------------------------------------------
// 3. ESTACOES PIXEL ART
// -------------------------------------------------------------
var est_sprites = [
    spr_est_frutas,
    spr_est_verduras,
    spr_est_graos,
    spr_est_proteinas,
    spr_est_laticinios,
    spr_est_bebidas
];
for (var i = 0; i < array_length(est_x); i++) {
    var ex = ui_map_x(est_x[i]);
    var ey = ui_map_y(est_y[i]);
    draw_set_color(c_white);
    draw_sprite_ext(est_sprites[i], 0, ex, ey, 1.18, 1.18, 0, c_white, 1);

    // Pequeno selo de estacao concluida, sem cobrir os alimentos.
    if (concluidos[i]) {
        draw_set_color(cor_verde);
        draw_circle(ex + 50, ey - 41, 16, false);
        draw_set_halign(fa_center);
        draw_set_color(c_white);
        draw_text(ex + 50, ey - 49, "OK");
        draw_set_halign(fa_left);
    }
}

// -------------------------------------------------------------
// 4. EQUIPAMENTOS DA COZINHA
// -------------------------------------------------------------
// Geladeira
var g1 = ui_map_x(65), g2 = ui_map_x(165);
var gt = ui_map_y(460), gb = ui_map_y(580);
draw_set_color(make_color_rgb(143, 176, 187));
draw_rectangle(g1, gt, g2, gb, false);
draw_set_color(make_color_rgb(84, 117, 128));
draw_rectangle(g1, ui_map_y(505), g2, ui_map_y(511), false);
draw_rectangle(g2 - 17, gt + 12, g2 - 12, gt + 38, false);
draw_rectangle(g2 - 17, gt + 59, g2 - 12, gb - 20, false);
draw_set_color(cor_escuro);
draw_text(g1 + 12, gb + 6, "GELADEIRA");

// Bancada de preparo
var bx1 = ui_map_x(350), bx2 = ui_map_x(610);
var by1 = ui_map_y(515), by2 = ui_map_y(585);
draw_set_color(make_color_rgb(113, 72, 43));
draw_rectangle(bx1, by1, bx2, by2, false);
draw_set_color(make_color_rgb(222, 177, 117));
draw_rectangle(bx1 + 10, by1 + 7, bx2 - 10, by2 - 9, false);
draw_set_color(cor_escuro);
draw_set_halign(fa_center);
draw_text((bx1 + bx2)/2, by1 + 22, "BANCADA DE PREPARO");
draw_set_halign(fa_left);


// -------------------------------------------------------------
// PIA - coordenadas da estacao
// -------------------------------------------------------------

var px1 = ui_map_x(625);
var px2 = ui_map_x(755);
var py1 = ui_map_y(515);
var py2 = ui_map_y(585);

// Nome da estacao
draw_set_color(cor_escuro);
draw_set_halign(fa_center);
draw_text((px1 + px2) / 2, py2 + 6, "PIA");
draw_set_halign(fa_left);


// FOGAO - coordenadas da estacao
var fx1 = ui_map_x(785);
var fx2 = ui_map_x(890);
var fy1 = ui_map_y(460);
var fy2 = ui_map_y(570);

// Nome da estacao
draw_set_color(cor_escuro);
draw_set_halign(fa_center);
draw_text((fx1 + fx2) / 2, fy2 + 6, "FOGAO");
draw_set_halign(fa_left);


// -------------------------------------------------------------
// 5. CHEF E PERSONAGEM (POSICOES LOGICAS PRESERVADAS)
// -------------------------------------------------------------
var chef_gui_x = ui_map_x(480);
var chef_gui_y = ui_map_y(400);
draw_set_color(c_white);
draw_sprite_ext(chef_sprite, floor(chef_frame), chef_gui_x, chef_gui_y,
                1.23, 1.23, 0, c_white, 1);
draw_set_color(cor_escuro);
draw_set_halign(fa_center);
draw_text(chef_gui_x, chef_gui_y - 63, "CHEF");
draw_set_halign(fa_left);

draw_set_color(c_white);
draw_sprite_ext(sprite_player, floor(frame_player),
                ui_map_x(player_x), ui_map_y(player_y),
                1.23, 1.23, 0, c_white, 1);

// -------------------------------------------------------------
// 6. BARRA SUPERIOR: IDENTIDADE, MISSAO E TEMPO
// -------------------------------------------------------------
draw_set_color(cor_painel);
draw_rectangle(0, 0, W, 157, false);

draw_set_color(cor_ouro);
draw_text_transformed(24, 15, "KITCHENRUSH", 1.65, 1.65, 0);
draw_set_color(c_white);
draw_text(26, 52, "Cargo: " + cargo + "  |  XP: " + string(xp));

if (missao_ativa && !jogo_concluido) {
    var missao_topo = missoes[indice_missao];
    draw_set_color(cor_ouro);
    draw_text(26, 82, "MISSAO " + string(indice_missao + 1) + "/" + string(array_length(missoes))
                         + "  -  " + missao_topo.nome);
    draw_set_color(c_white);
    draw_text(26, 107, "Dica: " + missao_topo.dica);
} else {
    draw_set_color(cor_claro);
    if (jogo_concluido) {
        draw_text(26, 85, "Todas as receitas concluidas. Parabens!");
    } else {
        draw_text(26, 85, "Encontre o Chef para iniciar sua proxima receita.");
    }
}

// Cronometro compacto, em destaque e sem invadir a sacola.
if (missao_ativa && tempo_missao_rodando) {
    var restante = ceil(max(0, tempo_restante_missao));
    var minutos = floor(restante / 60);
    var segundos = restante mod 60;
    var txt_segundos = string(segundos);
    if (segundos < 10) txt_segundos = "0" + txt_segundos;
    var total_barra = clamp(tempo_restante_missao / max(1, tempo_total_missao), 0, 1);
    var t_cor = cor_verde;
    if (restante <= 30) t_cor = make_color_rgb(214, 87, 74);

    draw_set_color(cor_escuro);
    draw_roundrect(728, 16, 916, 136, false);
    draw_set_color(cor_ouro);
    draw_set_halign(fa_center);
    draw_text(822, 25, "TEMPO RESTANTE");
    draw_set_color(t_cor);
    draw_text_transformed(822, 52, string(minutos) + ":" + txt_segundos, 2, 2, 0);
    draw_set_color(make_color_rgb(81, 102, 94));
    draw_rectangle(752, 108, 892, 119, false);
    draw_set_color(t_cor);
    draw_rectangle(752, 108, 752 + 140 * total_barra, 119, false);
    draw_set_halign(fa_left);
}

// -------------------------------------------------------------
// 7. SACOLA NO CANTO SUPERIOR DIREITO + LISTA DINAMICA
// -------------------------------------------------------------
// Painel dentro da GUI de 1280 pixels: X = 928 ate 1269.
draw_set_color(make_color_rgb(125, 92, 65));
draw_roundrect(928, 10, 1269, 151, false);
draw_set_color(cor_claro);
draw_roundrect(933, 15, 1264, 146, false);

// Sprite de 64 x 64, com origem central (32, 32).
// Ele fica a esquerda dos textos, sem cobrir o contador.
draw_set_color(c_white);
draw_sprite_ext(spr_sacola, 0, 955, 57, 0.85, 0.85, 0, c_white, 1);

// Titulo e progresso.
draw_set_color(cor_escuro);
draw_text_transformed(1031, 24, "SACOLA", 1.26, 1.26, 0);
draw_set_color(make_color_rgb(111, 76, 44));
var total_necessario = 3;
if (missao_ativa && !jogo_concluido) {
    total_necessario = array_length(missoes[indice_missao].ingredientes);
}
draw_text(1033, 50,
    string(array_length(sacola)) + "/" +
    string(total_necessario) + " ingredientes"
);

// Itens coletados e espacos vazios.
for (var s = 0; s < total_necessario; s++) {
    var bag_y = 75 + s * 24;
    if (s < array_length(sacola)) {
        draw_set_color(make_color_rgb(38, 128, 73));
        draw_text(1032, bag_y, "[+] " + string(sacola[s]));
    } else {
        draw_set_color(make_color_rgb(139, 136, 127));
        draw_text(1032, bag_y, "[ ] Aguardando...");
    }
}

// -------------------------------------------------------------
// 8. FALA DO CHEF EM BALAO DE QUADRINHOS CENTRALIZADO
// -------------------------------------------------------------

var chef_falando = (string_pos("Chef:", mensagem) == 1);

if (chef_falando && !pergunta_ativa && !preparo_ativo
    && tempo_mensagem_conclusao <= 0 && falha_missao_visivel <= 0) {

    var fala_chef = string_trim(string_delete(mensagem, 1, 5));

    // Borda externa do balao
    draw_set_color(make_color_rgb(81, 63, 44));
    draw_roundrect(407, 275, 873, 390, false);

    // Cauda do balao
    draw_triangle(630, 386, 650, 386, 641, 410, false);

    // Fundo interno
    draw_set_color(cor_claro);
    draw_roundrect(412, 280, 868, 385, false);
    draw_triangle(634, 382, 646, 382, 641, 402, false);

    // Titulo centralizado
    draw_set_halign(fa_center);
    draw_set_valign(fa_top);

    draw_set_color(make_color_rgb(145, 89, 48));
    draw_text(640, 292, "CHEF:");

    // Mensagem centralizada e com quebra de linha
    draw_set_color(cor_escuro);
    draw_text_ext(640, 323, fala_chef, 18, 390);

    // Restaurar alinhamento
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
}


// -------------------------------------------------------------
// 9. RODAPE FIXO: MENSAGENS + CONTROLES NO CANTO INFERIOR DIREITO
// -------------------------------------------------------------
draw_set_color(make_color_rgb(40, 63, 57));
draw_rectangle(0, 637, W, 720, false);

// Mensagem / feedback com contraste alto, no rodape.
draw_set_color(make_color_rgb(125, 92, 65));
draw_roundrect(24, 646, 922, 710, false);
draw_set_color(cor_claro);
draw_roundrect(29, 651, 917, 705, false);
draw_set_color(make_color_rgb(129, 81, 43));
draw_text(41, 657, "MENSAGEM");
draw_set_color(cor_escuro);
var msg_rodape = mensagem;
if (chef_falando) msg_rodape = mensagem_missao;
draw_text_ext(41, 680, msg_rodape, 18, 855);

// Painel dos comandos ancorado ao lado DIREITO e INFERIOR.
draw_set_color(cor_escuro);
draw_roundrect(938, 646, 1265, 710, false);
draw_set_color(cor_ouro);
draw_text(955, 654, "CONTROLES");
draw_set_color(c_white);
draw_text(955, 674, "WASD / SETAS   Mover");
draw_text(955, 693, "E  Interagir   |   1-3  Responder");

// -------------------------------------------------------------
// 10. PERGUNTA NUTRICIONAL (MODAL CENTRAL)
// -------------------------------------------------------------
if (pergunta_ativa) {
    draw_set_alpha(0.64);
    draw_set_color(cor_escuro);
    draw_rectangle(0, 157, W, 637, false);
    draw_set_alpha(1);

    draw_set_color(make_color_rgb(88, 65, 44));
    draw_roundrect(240, 218, 1040, 546, false);
    draw_set_color(cor_claro);
    draw_roundrect(246, 224, 1034, 540, false);
    draw_set_color(cor_painel);
    draw_roundrect(262, 241, 1018, 288, false);
    draw_set_color(cor_ouro);
    draw_text_transformed(288, 252, "DESAFIO DE NUTRICAO", 1.38, 1.38, 0);
    draw_set_color(cor_escuro);
    draw_text_ext(288, 310, pergunta, 22, 684);
    for (var p = 0; p < 3; p++) {
        var opt_y = 372 + 49 * p;
        draw_set_color(make_color_rgb(220, 230, 215));
        draw_roundrect(285, opt_y, 992, opt_y + 40, false);
        draw_set_color(cor_escuro);
        draw_text(307, opt_y + 11, string(p + 1) + ")  " + opcoes[p]);
    }
}

// -------------------------------------------------------------
// 11. MINIGAMES POR ESTACAO (REDESENHADOS E CENTRALIZADOS)
// -------------------------------------------------------------
if (corte_ativo || arroz_ativo || frango_ativo || fruta_ativo || leite_ativo || bebida_ativo) {
    var mx1 = 290, my1 = 220, mx2 = 990, my2 = 545;
    var bx = 390, by = 372, bw = 500;
    draw_set_alpha(0.64);
    draw_set_color(cor_escuro);
    draw_rectangle(0, 157, W, 637, false);
    draw_set_alpha(1);
    draw_set_color(make_color_rgb(94, 68, 47));
    draw_roundrect(mx1, my1, mx2, my2, false);
    draw_set_color(cor_painel);
    draw_roundrect(mx1 + 5, my1 + 5, mx2 - 5, my2 - 5, false);
    draw_set_color(cor_ouro);
    draw_set_halign(fa_center);

    var titulo_mini = "DESAFIO";
    var instrucao_mini = "";
    if (corte_ativo) {
        titulo_mini = "CORTE O INGREDIENTE!";
        instrucao_mini = "Aperte ESPACO quando o marcador estiver no verde.";
    } else if (arroz_ativo) {
        titulo_mini = "COZINHE O GRAO!";
        instrucao_mini = "Aperte ESPACO no ponto ideal do cozimento.";
    } else if (frango_ativo) {
        titulo_mini = "PREPARE A PROTEINA!";
        instrucao_mini = "Use SETA CIMA e SETA BAIXO para controlar a temperatura.";
    } else if (fruta_ativo) {
        titulo_mini = "FRUTAS - DESAFIO DE AGILIDADE";
        instrucao_mini = "Pressione o numero indicado (0 a 9).";
    } else if (leite_ativo) {
        titulo_mini = "LATICINIOS - MEDIDA CERTA";
        instrucao_mini = "Segure ESPACO; solte entre 75% e 85%.";
    } else if (bebida_ativo) {
        titulo_mini = "BEBIDAS - MISTURA EQUILIBRADA";
        instrucao_mini = "Alterne as teclas A e D ate completar 10 pontos.";
    }

    draw_text_transformed(640, 246, titulo_mini, 1.34, 1.34, 0);
    draw_set_color(c_white);
    draw_text(640, 300, instrucao_mini);
    draw_set_halign(fa_left);

    if (corte_ativo || arroz_ativo || frango_ativo || leite_ativo || bebida_ativo) {
        // Barra, com zona de acerto verde e marcador amarelo.
        draw_set_color(make_color_rgb(94, 101, 102));
        draw_rectangle(bx, by, bx + bw, by + 32, false);
        var zona_ini = 0, zona_fim = 100, valor = 0;
        if (corte_ativo) {
            zona_ini = corte_zona_inicio; zona_fim = corte_zona_fim;
            valor = corte_posicao;
        } else if (arroz_ativo) {
            zona_ini = arroz_zona_inicio; zona_fim = arroz_zona_fim;
            valor = arroz_progresso;
        } else if (frango_ativo) {
            zona_ini = frango_zona_inicio; zona_fim = frango_zona_fim;
            valor = frango_temperatura;
        } else if (leite_ativo) {
            zona_ini = 75; zona_fim = 85; valor = leite_nivel;
        } else {
            zona_ini = 0; zona_fim = clamp(bebida_progresso * 10, 0, 100);
            valor = bebida_progresso * 10;
        }
        draw_set_color(cor_verde);
        draw_rectangle(bx + bw * zona_ini/100, by,
                       bx + bw * zona_fim/100, by + 32, false);
        draw_set_color(cor_ouro);
        var marca = bx + bw * clamp(valor, 0, 100)/100;
        draw_rectangle(marca - 4, by - 8, marca + 4, by + 40, false);
    }

    draw_set_halign(fa_center);
    draw_set_color(c_white);
    if (fruta_ativo) {
        draw_set_color(cor_ouro);
        draw_text_transformed(640, 342, string(fruta_alvo), 3, 3, 0);
        draw_set_color(c_white);
        draw_text(640, 422, "Acertos: " + string(fruta_acertos) + "/" + string(fruta_meta)
                       + "   |   Tempo: " + string(ceil(fruta_tempo/room_speed)) + " s");
        draw_text(640, 447, "Bonus: ate 150 XP por velocidade");
    } else if (corte_ativo) {
        draw_text(640, 423, "Cortes: " + string(corte_acertos) + "/3   |   Erros: " + string(corte_erros));
    } else if (arroz_ativo) {
        draw_text(640, 423, "Cozimento: " + string(floor(arroz_progresso))
                       + "%   |   Tentativas: " + string(arroz_tentativas));
    } else if (frango_ativo) {
        draw_text(640, 423, "Temperatura: " + string(floor(frango_temperatura)) + "%");
        draw_text(640, 448, "Tempo ideal: " + string(floor(frango_tempo_ideal / room_speed))
                       + " / " + string(floor(frango_tempo_necessario / room_speed)) + " s");
    } else if (leite_ativo) {
        draw_text(640, 423, "Nivel da dosagem: " + string(floor(leite_nivel)) + "%");
    } else if (bebida_ativo) {
        draw_text(640, 423, "Mistura: " + string(bebida_progresso) + "/10");
    }
    draw_set_color(cor_ouro);
    draw_text_ext(640, 495, mensagem_preparo, 18, 610);
    draw_set_halign(fa_left);
}

// -------------------------------------------------------------
// 12. MINIGAME DE MONTAGEM (SEQUENCIA + CRONOMETRO)
// -------------------------------------------------------------
if (montagem_ativa) {
    draw_set_alpha(0.64);
    draw_set_color(cor_escuro);
    draw_rectangle(0, 157, W, 637, false);
    draw_set_alpha(1);

    var cx = W / 2;
    var cy = H / 2;
    var x1 = cx - 330;
    var y1 = cy - 235;
    var x2 = cx + 330;
    var y2 = cy + 230;

    draw_set_color(make_color_rgb(111, 77, 51));
    draw_roundrect(x1, y1, x2, y2, false);
    draw_set_color(cor_painel);
    draw_roundrect(x1 + 6, y1 + 6, x2 - 6, y2 - 6, false);
    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);
    draw_set_color(cor_ouro);
    draw_text_transformed(cx, y1 + 42, "MONTAGEM DO PRATO", 1.45, 1.45, 0);

    var tempo_segundos = max(0, ceil(montagem_cronometro / room_speed));
    var tempo_total_montagem = montagem_tempo_jogo;
    if (montagem_fase == 0) tempo_total_montagem = montagem_tempo_memoria;
    var proporcao = clamp(montagem_cronometro / max(1, tempo_total_montagem), 0, 1);
    var cor_tempo = cor_verde;
    if (proporcao <= 0.5) cor_tempo = cor_ouro;
    if (montagem_fase == 1 && tempo_segundos <= 3) {
        cor_tempo = c_red;
        if (floor(current_time / 250) mod 2 == 0) cor_tempo = c_white;
    }
    draw_set_color(make_color_rgb(50, 76, 78));
    draw_roundrect(cx - 126, y1 + 82, cx + 126, y1 + 172, false);
    draw_set_color(cor_tempo);
    draw_text_transformed(cx, y1 + 126, string(tempo_segundos), 2.6, 2.6, 0);
    draw_set_color(make_color_rgb(75, 92, 95));
    draw_rectangle(cx - 225, y1 + 195, cx + 225, y1 + 209, false);
    draw_set_color(cor_tempo);
    draw_rectangle(cx - 225, y1 + 195, cx - 225 + 450 * proporcao, y1 + 209, false);
    draw_set_color(c_white);
    if (montagem_fase == 0) {
        draw_text(cx, y1 + 245, "MEMORIZE A SEQUENCIA!");
    } else {
        draw_text(cx, y1 + 245, "REPITA A SEQUENCIA!");
    }

    var setas = ["", "^", "v", "<", ">"]; // mesma codificacao do STEP
    for (var m = 0; m < montagem_tamanho; m++) {
        var sx = cx - (montagem_tamanho - 1) * 45 + m * 90;
        var montage_y = y1 + 315;
        var correto = (montagem_fase == 1 && m < montagem_posicao);
        draw_set_color(correto ? cor_verde : make_color_rgb(78, 104, 106));
        draw_roundrect(sx - 35, montage_y - 34, sx + 35, montage_y + 34, false);
        draw_set_color(cor_claro);
        var letra = "?";
        if (montagem_fase == 0) letra = setas[montagem_sequencia[m]];
        else if (correto) letra = "OK";
        draw_text_transformed(sx, montage_y, letra, 1.65, 1.65, 0);
    }
    draw_set_color(c_white);
    if (montagem_fase == 0) draw_text(cx, y1 + 382, "Prepare-se para repetir as setas!");
    else draw_text(cx, y1 + 382, "USE AS SETAS DO TECLADO!");
    draw_set_color(cor_ouro);
    draw_text(cx, y1 + 420, "ERROS: " + string(montagem_erros) + "/3");
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
}

// -------------------------------------------------------------
// 13. CONFIRMACAO / FALHA DE MISSAO
// -------------------------------------------------------------
if (tempo_mensagem_conclusao > 0) {
    var cx = W/2, cy = H/2;
    draw_set_alpha(0.65);
    draw_set_color(cor_escuro);
    draw_rectangle(0, 157, W, 637, false);
    draw_set_alpha(1);
    draw_set_color(make_color_rgb(27, 76, 57));
    draw_roundrect(cx-355, cy-165, cx+355, cy+165, false);
    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);
    draw_set_color(cor_ouro);
    draw_text_transformed(cx, cy-113, "RECEITA CONCLUIDA!", 1.8, 1.8, 0);
    draw_set_color(c_white);
    draw_text(cx, cy-50, receita_concluida_nome);
    draw_set_color(make_color_rgb(137, 230, 155));
    draw_text_transformed(cx, cy+2, "+"+string(xp_ganho_missao)+" XP", 1.7, 1.7, 0);
    draw_set_color(cor_ouro);
    draw_text(cx, cy+60, classificacao_missao);
    draw_set_color(c_white);
    draw_text(cx, cy+111, "Volte ao Chef para continuar!");
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
}
if (falha_missao_visivel > 0) {
    var cx = W/2, cy = H/2;
    draw_set_alpha(0.65);
    draw_set_color(cor_escuro);
    draw_rectangle(0, 157, W, 637, false);
    draw_set_alpha(1);
    draw_set_color(make_color_rgb(113, 38, 42));
    draw_roundrect(cx-355, cy-130, cx+355, cy+130, false);
    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);
    draw_set_color(cor_ouro);
    draw_text_transformed(cx, cy-73, "MISSAO FALHOU!", 1.75, 1.75, 0);
    draw_set_color(c_white);
    draw_text(cx, cy, "TEMPO ESGOTADO!");
    draw_text(cx, cy+60, "Fale com o Chef para tentar novamente.");
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
}

// Garante que o estado de desenho nao contamine outros objetos.
draw_set_alpha(1);
draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_color(c_white);



// -------------------------------------------------------------
// 14. SPRITE DA PIA INDUSTRIAL
// -------------------------------------------------------------

// Posicao da estacao PIA na interface
var pia_centro_x = (px1 + px2) / 2;
var pia_centro_y = (py1 + py2) / 2;

// Dimensoes do sprite
var pia_largura = 140;
var pia_altura = 80;

// Escalas proporcionais ao tamanho desejado
var pia_escala_x = pia_largura / sprite_get_width(spr_pia);
var pia_escala_y = pia_altura / sprite_get_height(spr_pia);

// Desenha a pia na estacao correta
draw_sprite_ext(
    spr_pia,
    0,
    pia_centro_x,
    pia_centro_y,
    pia_escala_x,
    pia_escala_y,
    0,
    c_white,
    1
);
altura_pia = 80;


// -------------------------------------------------------------
// 15. SPRITE DO FOGAO INDUSTRIAL
// -------------------------------------------------------------

var fogao_centro_x = (fx1 + fx2) / 2;
var fogao_centro_y = (fy1 + fy2) / 2;

var fogao_largura = 125;
var fogao_altura = 120;

var fogao_escala_x = fogao_largura / sprite_get_width(spr_fogao);
var fogao_escala_y = fogao_altura / sprite_get_height(spr_fogao);

draw_sprite_ext(
    spr_fogao,
    0,
    fogao_centro_x,
    fogao_centro_y,
    fogao_escala_x,
    fogao_escala_y,
    0,
    c_white,
    1
);
