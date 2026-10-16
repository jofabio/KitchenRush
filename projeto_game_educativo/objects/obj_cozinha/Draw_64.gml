
/// KITCHENRUSH - CENARIO V2

// Fundo
draw_clear(make_color_rgb(240, 233, 212));

// Piso da cozinha
draw_set_color(make_color_rgb(218, 205, 178));
draw_rectangle(20, 110, 940, 615, false);

// Ladrilhos
draw_set_color(make_color_rgb(195, 181, 155));

for (var px = 20; px <= 940; px += 40) {
    draw_line(px, 110, px, 615);
}

for (var py = 110; py <= 615; py += 40) {
    draw_line(20, py, 940, py);
}

// Parede superior
draw_set_color(make_color_rgb(116, 91, 72));
draw_rectangle(20, 110, 940, 135, false);

// Parede lateral
draw_rectangle(20, 110, 35, 615, false);
draw_rectangle(925, 110, 940, 615, false);



// ========================================
// KITCHENRUSH - ESTACOES EM PIXEL ART
// ========================================

// Associa os sprites aos nomes das estacoes
for (var i = 0; i < array_length(est_x); i++) {

    var sx = est_x[i];
    var sy = est_y[i];

    var sprite_estacao = -1;

    // Escolhe o sprite correto pelo nome da estacao
    switch (string_lower(nomes[i])) {

        case "verduras":
        case "verduras e legumes":
            sprite_estacao = spr_est_verduras;
            break;

        case "graos":
        case "grãos":
        case "graos e cereais":
        case "grãos e cereais":
            sprite_estacao = spr_est_graos;
            break;

        case "proteinas":
        case "proteínas":
            sprite_estacao = spr_est_proteinas;
            break;

        case "frutas":
            sprite_estacao = spr_est_frutas;
            break;

        case "laticinios":
        case "laticínios":
            sprite_estacao = spr_est_laticinios;
            break;

        case "bebidas":
            sprite_estacao = spr_est_bebidas;
            break;
    }

    // Desenha o sprite na posicao original
    if (sprite_estacao != -1) {

        draw_set_color(c_white);

        draw_sprite(
            sprite_estacao,
            0,
            sx,
            sy
        );

    } else {

        // Aviso visual caso o nome nao corresponda
        draw_set_color(c_red);
        draw_text(sx - 40, sy, nomes[i]);
    }

    // Indicador de estacao concluida
    if (concluidos[i]) {

        draw_set_color(c_lime);
        draw_circle(sx + 42, sy - 35, 12, false);

        draw_set_color(c_black);
        draw_text(sx + 35, sy - 43, "OK");
    }
}

// Restaura a cor padrao
draw_set_color(c_white);


// Geladeira
draw_set_color(make_color_rgb(150, 180, 190));
draw_rectangle(65, 460, 165, 580, false);

draw_set_color(make_color_rgb(95, 125, 135));
draw_rectangle(65, 505, 165, 510, false);
draw_rectangle(150, 475, 155, 495, false);
draw_rectangle(150, 520, 155, 555, false);

draw_set_color(c_black);
draw_text(75, 585, "Geladeira");

// Fogao
draw_set_color(make_color_rgb(105, 110, 115));
draw_rectangle(785, 460, 890, 570, false);

draw_set_color(c_black);
draw_circle(810, 485, 12, false);
draw_circle(865, 485, 12, false);
draw_circle(810, 540, 12, false);
draw_circle(865, 540, 12, false);

draw_text(810, 575, "Fogao");

// Bancada central
draw_set_color(make_color_rgb(125, 83, 49));
draw_rectangle(350, 515, 610, 585, false);

draw_set_color(make_color_rgb(220, 174, 115));
draw_rectangle(360, 520, 600, 575, false);

draw_set_color(c_black);
draw_text(400, 540, "BANCADA DE PREPARO");


// Pia ao lado da bancada de preparo
draw_set_color(make_color_rgb(120, 145, 150));
draw_rectangle(625, 515, 755, 585, false);

// Cuba da pia
draw_set_color(make_color_rgb(205, 220, 220));
draw_rectangle(635, 525, 745, 575, false);

// Ralo
draw_set_color(make_color_rgb(75, 95, 100));
draw_circle(690, 550, 6, false);

// Torneira
draw_set_color(make_color_rgb(85, 95, 100));
draw_rectangle(685, 520, 695, 535, false);

// Identificacao
draw_set_color(c_black);
draw_text(675, 590, "PIA");


// Chef

draw_set_color(c_white);

draw_sprite_ext(
    chef_sprite,
    floor(chef_frame),
    480,
    400,
    1,
    1,
    0,
    c_white,
    1
);

// Nome acima do personagem

draw_set_color(c_black);
draw_text(460, 325, "CHEF");
// ========================================
// DESENHAR ESTAGIARIO ANIMADO
// ========================================

draw_set_color(c_white);

draw_sprite_ext(
    sprite_player,
    floor(frame_player),
    player_x,
    player_y,
    1,
    1,
    0,
    c_white,
    1
);

// HUD
draw_set_color(c_black);

draw_text(20, 20,
    "KITCHENRUSH | Cargo: " + cargo
    + " | XP: " + string(xp));

draw_text(20, 48,
    "WASD/setas: mover | E: interagir | 1, 2, 3: responder");

draw_text(20, 80, mensagem);

// Perguntas
if (pergunta_ativa) {

    draw_set_color(make_color_rgb(250, 248, 235));
    draw_rectangle(95, 315, 865, 585, false);

    draw_set_color(c_black);
    draw_text(120, 340, "DESAFIO DE NUTRICAO");
    draw_text(120, 385, pergunta);

    for (var j = 0; j < 3; j++) {
        draw_text(120, 430 + j * 42,
            string(j + 1) + ") " + opcoes[j]);
    }
}

// INTERFACE DA SACOLA

draw_set_color(make_color_rgb(250, 245, 225));
draw_rectangle(650, 15, 935, 100, false);

draw_set_color(c_black);
draw_text(665, 20, "SACOLA");

var texto_sacola = "";

for (var i = 0; i < array_length(sacola); i++) {
    texto_sacola += sacola[i];

    if (i < array_length(sacola) - 1) {
        texto_sacola += ", ";
    }
}

draw_text(665, 45, texto_sacola);
draw_text(665, 70, string(ingredientes_coletados) + "/3 ingredientes");


// ==========================================
// PAINEL DE DICAS NUTRICIONAIS
// ==========================================

if (missao_ativa && !jogo_concluido) {

    var m_dica = missoes[indice_missao];

    // Fundo do painel
    draw_set_color(make_color_rgb(38, 65, 50));
    draw_roundrect(230, 105, 730, 140, false);

    // Titulo
    draw_set_color(c_yellow);
    draw_text(245, 115, "DICA:");

    // Conteudo da dica
    draw_set_color(c_white);
    draw_text(305, 115, m_dica.dica);
}

// Restaurar cor padrao
draw_set_color(c_white);
// =====================================
// PAINEL DO MINIGAME DE CORTE
// =====================================

if (corte_ativo) {

    // Fundo do painel
    draw_set_color(make_color_rgb(35, 48, 42));
    draw_roundrect(190, 170, 770, 420, false);

    // Titulo
    draw_set_color(c_white);
    draw_text(350, 195, "CORTE O INGREDIENTE!");

    draw_text(270, 235, "Aperte ESPACO na zona verde!");

    // Posicao e tamanho da barra
    var bx = 270;
    var by = 295;
    var largura = 420;

    // Barra cinza
    draw_set_color(c_gray);
    draw_rectangle(bx, by, bx + largura, by + 25, false);

    // Zona verde
    draw_set_color(c_lime);
    draw_rectangle(
        bx + largura * corte_zona_inicio / 100,
        by,
        bx + largura * corte_zona_fim / 100,
        by + 25,
        false
    );

    // Marcador amarelo
    var mx = bx + largura * corte_posicao / 100;

    draw_set_color(c_yellow);
    draw_rectangle(mx - 3, by - 8, mx + 3, by + 33, false);

    // Informacoes
    draw_set_color(c_white);

    draw_text(270, 350,
        "Cortes: " + string(corte_acertos) + "/3");

    draw_text(500, 350,
        "Erros: " + string(corte_erros));

    draw_set_color(c_yellow);
    draw_text(270, 385, mensagem_preparo);

    // Restaurar cor
    draw_set_color(c_white);
}


// =====================================
// PAINEL DO MINIGAME DO ARROZ
// =====================================

if (arroz_ativo) {

    // Fundo
    draw_set_color(make_color_rgb(35, 48, 42));
    draw_roundrect(190, 170, 770, 420, false);

    draw_set_color(c_white);
    draw_text(355, 195, "COZINHE O GRAO!");

    draw_text(260, 235, "Aperte ESPACO quando estiver no ponto!");

    var bx = 270;
    var by = 295;
    var largura = 420;

    // Regiao do arroz cru
    draw_set_color(make_color_rgb(200, 145, 85));
    draw_rectangle(
        bx, by,
        bx + largura * arroz_zona_inicio / 100,
        by + 25,
        false
    );

    // Regiao ideal
    draw_set_color(c_lime);
    draw_rectangle(
        bx + largura * arroz_zona_inicio / 100,
        by,
        bx + largura * arroz_zona_fim / 100,
        by + 25,
        false
    );

    // Regiao do arroz queimado
    draw_set_color(c_red);
    draw_rectangle(
        bx + largura * arroz_zona_fim / 100,
        by,
        bx + largura,
        by + 25,
        false
    );

    // Marcador
    var mx = bx + largura * arroz_progresso / 100;

    draw_set_color(c_yellow);
    draw_rectangle(mx - 3, by - 8, mx + 3, by + 33, false);

    // Informacoes
    draw_set_color(c_white);

    draw_text(270, 350,
        "Cozimento: " + string(floor(arroz_progresso)) + "%");

    draw_text(500, 350,
        "Tentativas: " + string(arroz_tentativas));

    draw_set_color(c_yellow);
    draw_text(270, 385, mensagem_preparo);

    draw_set_color(c_white);
}


// =====================================
// PAINEL DO MINIGAME DO FRANGO
// =====================================

if (frango_ativo) {

    // Fundo
    draw_set_color(make_color_rgb(35, 48, 42));
    draw_roundrect(190, 170, 770, 440, false);

    draw_set_color(c_white);
    draw_text(340, 195, "PREPARE A PROTEINA!");

    draw_text(250, 235, "Use as setas CIMA e BAIXO para controlar o fogo.");

    var bx = 270;
    var by = 295;
    var largura = 420;

    // Temperatura baixa
    draw_set_color(c_aqua);
    draw_rectangle(
        bx, by,
        bx + largura * frango_zona_inicio / 100,
        by + 25,
        false
    );

    // Temperatura ideal
    draw_set_color(c_lime);
    draw_rectangle(
        bx + largura * frango_zona_inicio / 100,
        by,
        bx + largura * frango_zona_fim / 100,
        by + 25,
        false
    );

    // Temperatura alta
    draw_set_color(c_red);
    draw_rectangle(
        bx + largura * frango_zona_fim / 100,
        by,
        bx + largura,
        by + 25,
        false
    );

    // Marcador
    var mx = bx + largura * frango_temperatura / 100;

    draw_set_color(c_yellow);
    draw_rectangle(mx - 3, by - 8, mx + 3, by + 33, false);

    // Informacoes
    draw_set_color(c_white);

    draw_text(270, 345,
        "Temperatura: " + string(floor(frango_temperatura)) + "%");

    draw_text(270, 375,
        "Tempo ideal: " +
        string(floor(frango_tempo_ideal / 60)) + " / 5 segundos");

    draw_set_color(c_yellow);
    draw_text(270, 405, mensagem_preparo);

    draw_set_color(c_white);
}





// =====================================
// NOVOS MINIGAMES: FRUTAS, LATICINIOS, BEBIDAS
// =====================================
if (fruta_ativo || leite_ativo || bebida_ativo) {
    draw_set_color(make_color_rgb(35, 48, 42));
    draw_roundrect(190, 170, 770, 430, false);
    draw_set_color(c_white);
    if (fruta_ativo) {
        draw_text(280, 195, "FRUTAS - DESAFIO DE AGILIDADE");
        draw_text(260, 245, "APERTE O NUMERO (0 A 9):");
        draw_set_color(c_yellow);
        draw_text_transformed(455, 280, string(fruta_alvo), 3, 3, 0);
        draw_set_color(c_white);
        draw_text(260, 355, "Acertos: " + string(fruta_acertos) + " / " + string(fruta_meta));
        draw_text(260, 385, "Tempo: " + string(ceil(fruta_tempo / room_speed)) + " s");
        draw_text(260, 410, "Bonus: ate +150 XP pela velocidade!");
    }
    if (leite_ativo) {
        draw_text(280, 195, "LATICINIOS - MEDIDA CERTA");
        draw_text(260, 245, "SEGURE ESPACO; SOLTE ENTRE 75% E 85%");
        draw_set_color(c_gray);
        draw_rectangle(270, 300, 690, 330, false);
        draw_set_color(c_lime);
        draw_rectangle(270 + 420 * 0.75, 300, 270 + 420 * 0.85, 330, false);
        draw_set_color(c_yellow);
        var lx = 270 + 420 * leite_nivel / 100;
        draw_rectangle(lx - 3, 290, lx + 3, 340, false);
        draw_set_color(c_white);
        draw_text(270, 360, "Nivel: " + string(floor(leite_nivel)) + "%");
    }
    if (bebida_ativo) {
        draw_text(280, 195, "BEBIDAS - MISTURA EQUILIBRADA");
        draw_text(260, 245, "ALTERNE AS TECLAS A E D!");
        draw_set_color(c_gray);
        draw_rectangle(270, 300, 690, 330, false);
        draw_set_color(c_lime);
        draw_rectangle(270, 300, 270 + 420 * bebida_progresso / 10, 330, false);
        draw_set_color(c_white);
        draw_text(270, 360, "Mistura: " + string(bebida_progresso) + "/10");
    }
    draw_set_color(c_yellow);
    draw_text(230, 405, mensagem_preparo);
    draw_set_color(c_white);
}

// =====================================
// PAINEL: MINIGAME DE MONTAGEM
// =====================================

if (montagem_ativa) {

    var gw = display_get_gui_width();
    var gh = display_get_gui_height();

    var cx = gw / 2;
    var cy = gh / 2;

    var x1 = cx - 300;
    var y1 = cy - 220;
    var x2 = cx + 300;
    var y2 = cy + 220;

    // Fundo escuro
    draw_set_alpha(0.94);
    draw_set_color(make_color_rgb(22, 34, 44));
    draw_roundrect(x1, y1, x2, y2, false);
    draw_set_alpha(1);

    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);

    // Titulo
    draw_set_color(make_color_rgb(255, 210, 100));
    draw_text(cx, y1 + 35, "MONTAGEM DO PRATO");

    // =================================
    // CRONOMETRO EM DESTAQUE
    // =================================

    var tempo_segundos = ceil(
        montagem_cronometro / room_speed
    );

    tempo_segundos = max(0, tempo_segundos);

    var tempo_total = montagem_tempo_jogo;

    if (montagem_fase == 0) {
        tempo_total = montagem_tempo_memoria;
    }

    var proporcao = clamp(
        montagem_cronometro / tempo_total,
        0, 1
    );

    var cor_tempo = c_lime;

    if (proporcao <= 0.5) {
        cor_tempo = c_yellow;
    }

	// Ultimos 3 segundos: alerta vermelho piscando
if (montagem_fase == 1 && tempo_segundos <= 3) {

    cor_tempo = c_red;

    // Alterna entre vermelho e branco
    if (floor(current_time / 250) mod 2 == 0) {
        cor_tempo = c_white;
    }
}
	
    // Moldura do cronometro
    draw_set_color(make_color_rgb(43, 60, 72));
    draw_roundrect(
        cx - 125, y1 + 65,
        cx + 125, y1 + 160,
        false
    );

    // Texto do cronometro ampliado
    // A escala aumenta o tamanho sem exigir outra fonte
    draw_set_color(cor_tempo);

    var texto_tempo = string(tempo_segundos);

    draw_text_transformed(
        cx, y1 + 110,
        texto_tempo,
        3, 3, 0
    );

    // Barra regressiva
    var barra_x = cx - 210;
    var barra_y = y1 + 185;
    var barra_largura = 420;

    draw_set_color(make_color_rgb(70, 80, 90));
    draw_rectangle(
        barra_x, barra_y,
        barra_x + barra_largura,
        barra_y + 18,
        false
    );

    draw_set_color(cor_tempo);
    draw_rectangle(
        barra_x, barra_y,
        barra_x + barra_largura * proporcao,
        barra_y + 18,
        false
    );

    // =================================
    // SEQUENCIA
    // =================================

    if (montagem_fase == 0) {

        draw_set_color(c_white);
        draw_text(cx, y1 + 235, "MEMORIZE A SEQUENCIA!");
		var simbolos_setas = ["", "^", "v", "<", ">"];

        for (var i = 0; i < montagem_tamanho; i++) {

            var px = cx - 160 + i * 80;

            draw_set_color(make_color_rgb(65, 85, 100));
            draw_roundrect(
                px - 30, y1 + 265,
                px + 30, y1 + 325,
                false
            );

            draw_set_color(c_yellow);
            draw_text(
			    px, y1 + 295,
			    simbolos_setas[montagem_sequencia[i]]
			);
            
        }

    } else {

        draw_set_color(c_white);
        draw_text(cx, y1 + 235, "REPITA A SEQUENCIA!");
		
        for (var i = 0; i < montagem_tamanho; i++) {

            var px = cx - 160 + i * 80;

            if (i < montagem_posicao) {
                draw_set_color(c_green);
            } else {
                draw_set_color(make_color_rgb(65, 85, 100));
            }

            draw_roundrect(
                px - 30, y1 + 265,
                px + 30, y1 + 325,
                false
            );

            draw_set_color(c_white);

            if (i < montagem_posicao) {
                draw_text(px, y1 + 295, "OK");
            } else {
                draw_text(px, y1 + 295, "?");
            }
        }
    }

    // =================================
    // INSTRUCOES E ERROS
    // =================================

    draw_set_color(c_white);

    if (montagem_fase == 0) {
        draw_text(
            cx, y1 + 355,
            "Prepare-se! O desafio comeca em breve."
        );
    } else {
        draw_text(
            cx, y1 + 355,
			 "USE AS SETAS DO TECLADO!"
        );
    }

    draw_set_color(c_yellow);
    draw_text(
        cx, y1 + 390,
        "ERROS: " + string(montagem_erros) + " / 3"
    );

    // Restaura configuracoes
    draw_set_color(c_white);
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
}


// =====================================
// CRONOMETRO GLOBAL - COMPACTO
// =====================================

if (missao_ativa && tempo_missao_rodando) {

    var segundos = ceil(max(0, tempo_restante_missao));
    var minutos = floor(segundos / 60);
    var seg = segundos mod 60;

    var seg_texto = string(seg);

    if (seg < 10) {
        seg_texto = "0" + seg_texto;
    }

    var tempo_texto = string(minutos) + ":" + seg_texto;

    var barra = clamp(
        tempo_restante_missao / max(1, tempo_total_missao),
        0, 1
    );

    // Painel compacto, entre o HUD e a sacola
    var painel_x = 490;
    var painel_y = 12;
    var painel_largura = 150;
    var painel_altura = 72;

    draw_set_alpha(0.95);
    draw_set_color(make_color_rgb(25, 40, 38));

    draw_roundrect(
        painel_x,
        painel_y,
        painel_x + painel_largura,
        painel_y + painel_altura,
        false
    );

    draw_set_alpha(1);

    // Titulo
    draw_set_halign(fa_center);
    draw_set_valign(fa_top);
    draw_set_color(c_white);

    draw_text(
        painel_x + painel_largura / 2,
        painel_y + 7,
        "MISSAO " + string(indice_missao + 1) + "/8"
    );

    // Tempo restante
    if (segundos <= 30) {
        draw_set_color(c_red);
    } else {
        draw_set_color(c_white);
    }

    draw_text(
        painel_x + painel_largura / 2,
        painel_y + 28,
        tempo_texto
    );

    // Fundo da barra
    draw_set_color(make_color_rgb(85, 85, 85));

    draw_rectangle(
        painel_x + 12,
        painel_y + 54,
        painel_x + painel_largura - 12,
        painel_y + 63,
        false
    );

    // Progresso do tempo
    if (segundos <= 30) {
        draw_set_color(c_red);
    } else {
        draw_set_color(c_lime);
    }

    draw_rectangle(
        painel_x + 12,
        painel_y + 54,
        painel_x + 12 + (painel_largura - 24) * barra,
        painel_y + 63,
        false
    );

    // Restaurar configuracoes
    draw_set_color(c_white);
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
}


// =====================================
// TELA DE CONCLUSAO DA MISSAO
// =====================================
if (tempo_mensagem_conclusao > 0) {
    var cx = display_get_gui_width() / 2;
    var cy = display_get_gui_height() / 2;
    draw_set_alpha(0.96);
    draw_set_color(make_color_rgb(25, 55, 45));
    draw_roundrect(cx - 310, cy - 145, cx + 310, cy + 145, false);
    draw_set_alpha(1);
    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);
    draw_set_color(c_yellow);
    draw_text_transformed(cx, cy - 105, "RECEITA CONCLUIDA!", 1.5, 1.5, 0);
    draw_set_color(c_white);
    draw_text(cx, cy - 50, receita_concluida_nome);
    draw_set_color(c_lime);
    draw_text_transformed(cx, cy + 5, "+" + string(xp_ganho_missao) + " XP", 1.6, 1.6, 0);
    draw_set_color(c_yellow);
    draw_text(cx, cy + 60, classificacao_missao);
    draw_set_color(c_white);
    draw_text(cx, cy + 105, "Volte ao Chef para continuar!");
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
    draw_set_color(c_white);
}

// =====================================
// TELA DE FALHA POR TEMPO ESGOTADO
// =====================================
if (falha_missao_visivel > 0) {
    var fx = display_get_gui_width() / 2;
    var fy = display_get_gui_height() / 2;
    draw_set_alpha(0.97);
    draw_set_color(make_color_rgb(80, 24, 30));
    draw_roundrect(fx - 320, fy - 110, fx + 320, fy + 110, false);
    draw_set_alpha(1);
    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);
    draw_set_color(c_yellow);
    draw_text_transformed(fx, fy - 52, "MISSAO FALHOU!", 1.6, 1.6, 0);
    draw_set_color(c_white);
    draw_text(fx, fy + 8, "TEMPO ESGOTADO!");
    draw_text(fx, fy + 52, "Fale com o Chef para tentar novamente.");
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
    draw_set_color(c_white);
}
