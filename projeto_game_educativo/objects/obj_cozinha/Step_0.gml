
// Estado inicial da animacao a cada frame
player_andando = false;
// Cronometro em segundos reais: ativo em perguntas, minigames e montagem.
if (missao_ativa && tempo_missao_rodando) {
    tempo_restante_missao = max(0, tempo_restante_missao - delta_time / 1000000);
    if (tempo_restante_missao <= 0) falhar_missao_tempo();
}
if (falha_missao_visivel > 0) falha_missao_visivel = max(0, falha_missao_visivel - delta_time / 1000000);

// KITCHENRUSH - STEP | MINIGAMES POR ESTACAO
// 1) Pergunta -> 2) minigame -> 3) ingrediente e XP -> 4) montagem

if (!pergunta_ativa && !preparo_ativo) {
    // MOVIMENTACAO
    var dx = keyboard_check(ord("D"))
           - keyboard_check(ord("A"))
           + keyboard_check(vk_right)
           - keyboard_check(vk_left);

    var dy = keyboard_check(ord("S"))
           - keyboard_check(ord("W"))
           + keyboard_check(vk_down)
           - keyboard_check(vk_up);

    var modulo = point_distance(0, 0, dx, dy);

    if (modulo > 0) {
        dx /= modulo;
        dy /= modulo;
    }

    var novo_x = clamp(player_x + dx * vel, 40, 920);
    var novo_y = clamp(player_y + dy * vel, 145, 600);

    // COLISAO HORIZONTAL
    var bloqueado_x = false;

    for (var i = 0; i < array_length(obstaculos); i++) {

        var o = obstaculos[i];

        if (novo_x + raio > o[0] &&
            novo_x - raio < o[2] &&
            player_y + raio > o[1] &&
            player_y - raio < o[3]) {

            bloqueado_x = true;
            break;
        }
    }

    // Colisao horizontal com o Chef
    if (point_distance(novo_x, player_y, 480, 400) < raio + 24) {
        bloqueado_x = true;
    }

    if (!bloqueado_x) {
        player_x = novo_x;
    }

    // COLISAO VERTICAL
    var bloqueado_y = false;

    for (var j = 0; j < array_length(obstaculos); j++) {

        var p = obstaculos[j];

        if (player_x + raio > p[0] &&
            player_x - raio < p[2] &&
            novo_y + raio > p[1] &&
            novo_y - raio < p[3]) {

            bloqueado_y = true;
            break;
        }
    }

    // Colisao vertical com o Chef
    if (point_distance(player_x, novo_y, 480, 400) < raio + 24) {
        bloqueado_y = true;
    }

    if (!bloqueado_y) {
        player_y = novo_y;
    }
	
	// ========================================
	// ANIMACAO DO ESTAGIARIO
	// ========================================

	// Verifica se o personagem realmente andou
	player_andando = (dx != 0 && !bloqueado_x)
	              || (dy != 0 && !bloqueado_y);

	// Escolhe o sprite conforme a direcao
	if (dx != 0 || dy != 0) {

	    if (abs(dx) > abs(dy)) {

	        if (dx > 0) {
	            sprite_player = spr_player_direita;
	        } else {
	            sprite_player = spr_player_esquerda;
	        }

	    } else {

	        if (dy > 0) {
	            sprite_player = spr_player_baixo;
	        } else {
	            sprite_player = spr_player_cima;
	        }
	    }
	}

	// Atualiza os quadros de caminhada
	if (player_andando) {

	    frame_player += anim_velocidade;

	    if (frame_player >= 4) {
	        frame_player = 0;
	    }

	} else {

	    // Quando para, fica no primeiro quadro
	    frame_player = 0;
	}
	
    // INTERACOES
    if (keyboard_check_pressed(ord("E"))) {
        var perto = -1;
        var menor = 99999;
        for (var k = 0; k < array_length(est_x); k++) {
            var dist = point_distance(player_x, player_y, est_x[k], est_y[k]);
            if (dist < 120 && dist < menor) {
                perto = k;
                menor = dist;
            }
        }
        if (perto >= 0) {
            if (!missao_ativa) {
                mensagem = "Fale com o Chef para iniciar uma missao!";
            } else {
                var m = missoes[indice_missao];
                var encontrado = -1;
                for (var a = 0; a < array_length(m.ingredientes); a++) {
                    if (m.setores[a] == perto && !tem_ingrediente(m.ingredientes[a])) {
                        encontrado = a;
                        break;
                    }
                }
                if (encontrado >= 0) {
                    indice_pergunta = indice_missao * 3 + encontrado;
                    var q = perguntas_missao[indice_pergunta];
                    pergunta = q.pergunta;
                    opcoes = q.opcoes;
                    correta = q.correta;
                    setor_atual = perto;
                    pergunta_ativa = true;
                } else {
                    mensagem = "Nenhum ingrediente pendente nesta estacao.";
                }
            }
        } else if (point_distance(player_x, player_y, 480, 400) < 90) {
            if (jogo_concluido) {
                mensagem = "Chef: Parabens! Todas as receitas concluidas!";
            } else if (!missao_ativa) {
                missao_ativa = true;
                missao_concluida = false;
                tempo_total_missao = limites_tempo_missoes[indice_missao];
                tempo_restante_missao = tempo_total_missao;
                tempo_missao_rodando = true;
                falha_missao_visivel = 0;
                xp_inicio_missao = xp;
                var m = missoes[indice_missao];
                mensagem = "Chef: Prepare " + m.nome + "!";
                mensagem_missao = "Colete: " + m.ingredientes[0] + ", "
                    + m.ingredientes[1] + ", " + m.ingredientes[2];
            } else {
                mensagem = "Chef: Prepare os ingredientes e monte na bancada!";
            }
        } else if (player_x >= 330 && player_x <= 630 &&
                   player_y >= 475 && player_y <= 610) {
            if (!missao_ativa) {
                mensagem = "Bancada: Fale com o Chef primeiro!";
            } else {
                var m = missoes[indice_missao];
                var completa = true;
                for (var b = 0; b < array_length(m.ingredientes); b++) {
                    if (!tem_ingrediente(m.ingredientes[b])) {
                        completa = false;
                        break;
                    }
                }
                if (completa) iniciar_montagem();
                else mensagem = "Bancada: Ainda faltam ingredientes!";
            }
        } else if (!missao_ativa) {
            mensagem = "Aproxime-se de uma estacao, do Chef ou da bancada.";
        }
    }
}

// RESPOSTAS DAS PERGUNTAS
if (pergunta_ativa) {
    var escolha = -1;
    if (keyboard_check_pressed(ord("1")) || keyboard_check_pressed(vk_numpad1)) escolha = 0;
    if (keyboard_check_pressed(ord("2")) || keyboard_check_pressed(vk_numpad2)) escolha = 1;
    if (keyboard_check_pressed(ord("3")) || keyboard_check_pressed(vk_numpad3)) escolha = 2;
    if (escolha >= 0) {
        if (escolha == correta) {
            var posicao = indice_pergunta - indice_missao * 3;
            iniciar_minigame_setor(setor_atual, posicao);
            mensagem = "Resposta correta! Complete o desafio para coletar.";
        } else {
            mensagem = "Resposta incorreta! Tente novamente na estacao.";
        }
        pergunta_ativa = false;
        setor_atual = -1;
    }
}

// VERDURAS - CORTE
if (corte_ativo) {
    corte_posicao += corte_velocidade * corte_direcao;
    if (corte_posicao >= 100) { corte_posicao = 100; corte_direcao = -1; }
    if (corte_posicao <= 0) { corte_posicao = 0; corte_direcao = 1; }
    if (keyboard_check_pressed(vk_space)) {
        if (corte_posicao >= corte_zona_inicio && corte_posicao <= corte_zona_fim) {
            corte_acertos++;
            corte_velocidade += 1;
            mensagem_preparo = "CORTE PERFEITO!";
            if (corte_acertos >= 3) finalizar_ingrediente();
        } else {
            corte_erros++;
            mensagem_preparo = "ERROU O CORTE! Tente novamente.";
        }
    }
}

// GRAOS - COZIMENTO
if (arroz_ativo) {
    arroz_progresso += arroz_velocidade;
    if (arroz_progresso >= 100) {
        arroz_progresso = 0;
        arroz_tentativas++;
        mensagem_preparo = "PASSOU DO PONTO! Tente novamente.";
    }
    if (keyboard_check_pressed(vk_space)) {
        if (arroz_progresso >= arroz_zona_inicio && arroz_progresso <= arroz_zona_fim) {
            finalizar_ingrediente();
        } else {
            arroz_tentativas++;
            arroz_progresso = 0;
            mensagem_preparo = "FORA DO PONTO! Tente novamente.";
        }
    }
}

// PROTEINAS - CONTROLE DE TEMPERATURA
if (frango_ativo) {
    frango_dificuldade = 1 + (frango_tempo_ideal / frango_tempo_necessario) * 2;
    frango_oscilacao = sin(current_time / 350) * 0.18 * frango_dificuldade;
    frango_temperatura += frango_aquecimento * frango_dificuldade + frango_oscilacao;
    if (keyboard_check(vk_up)) frango_temperatura += frango_ajuste;
    if (keyboard_check(vk_down)) frango_temperatura -= frango_ajuste;
    frango_temperatura = clamp(frango_temperatura, 0, 100);
    if (frango_temperatura >= frango_zona_inicio && frango_temperatura <= frango_zona_fim) {
        frango_tempo_ideal++;
        mensagem_preparo = "TEMPERATURA IDEAL! Continue assim!";
    } else if (frango_temperatura < frango_zona_inicio) {
        mensagem_preparo = "MUITO FRIO! Aumente o fogo!";
    } else {
        mensagem_preparo = "MUITO QUENTE! Diminua o fogo!";
    }
    if (frango_tempo_ideal >= frango_tempo_necessario) finalizar_ingrediente();
}

// FRUTAS - DESAFIO DE AGILIDADE: 10 ACERTOS EM 20 SEGUNDOS
if (fruta_ativo) {
    // Nao reutiliza a tecla que respondeu a pergunta nutricional.
    if (fruta_aguardando_soltar) {
        var alguma_tecla_num = false;
        for (var k = 0; k <= 9; k++) {
            if (keyboard_check(ord("0") + k)
                || keyboard_check(vk_numpad0 + k)) {
                alguma_tecla_num = true;
            }
        }
        if (!alguma_tecla_num) fruta_aguardando_soltar = false;
    } else {
        fruta_tempo--;
        var resposta_fruta = -1;
        for (var k = 0; k <= 9; k++) {
            if (keyboard_check_pressed(ord("0") + k)
                || keyboard_check_pressed(vk_numpad0 + k)) {
                resposta_fruta = k;
                break;
            }
        }
        if (resposta_fruta != -1) {
            if (resposta_fruta == fruta_alvo) {
                fruta_acertos++;
                if (fruta_acertos >= fruta_meta) {
                    // Bonus de velocidade: o tempo considera a tentativa inteira,
                    // inclusive os erros que zeraram a sequencia.
                    var segundos_usados = 20 - max(0, fruta_tempo) / room_speed;
                    if (segundos_usados <= 5) fruta_bonus_xp = 150;
                    else if (segundos_usados <= 8) fruta_bonus_xp = 100;
                    else if (segundos_usados <= 12) fruta_bonus_xp = 60;
                    else if (segundos_usados <= 16) fruta_bonus_xp = 30;
                    else fruta_bonus_xp = 0;
                    finalizar_ingrediente();
                } else {
                    var anterior = fruta_alvo;
                    do {
                        fruta_alvo = irandom_range(0, 9);
                    } until (fruta_alvo != anterior);
                    mensagem_preparo = "BOA! Continue acertando os numeros!";
                }
            } else {
                // Errou: perde a sequencia, mas o tempo restante continua.
                fruta_acertos = 0;
                fruta_alvo = irandom_range(0, 9);
                mensagem_preparo = "ERROU! Volta para 0/10. O tempo continua!";
            }
        }
        if (fruta_ativo && fruta_tempo <= 0) {
            fruta_acertos = 0;
            fruta_bonus_xp = 0;
            fruta_alvo = irandom_range(0, 9);
            fruta_tempo = 20 * room_speed;
            fruta_aguardando_soltar = true;
            mensagem_preparo = "TEMPO ESGOTADO! Tente novamente: 10 acertos em 20 s.";
        }
    }
}

// LATICINIOS - DOSAGEM
if (leite_ativo) {
    if (keyboard_check(vk_space)) {
        leite_nivel += leite_velocidade;
        if (leite_nivel > 100) leite_nivel = 100;
    }
    if (keyboard_check_released(vk_space)) {
        if (leite_nivel >= 75 && leite_nivel <= 85) finalizar_ingrediente();
        else {
            leite_nivel = 0;
            mensagem_preparo = "MEDIDA ERRADA! Segure ESPACO e tente de novo.";
        }
    }
}

// BEBIDAS - MISTURA ALTERNADA
if (bebida_ativo) {
    var batida = 0;
    if (keyboard_check_pressed(ord("A"))) batida = 1;
    if (keyboard_check_pressed(ord("D"))) batida = 2;
    if (batida != 0 && batida != bebida_ultima_tecla) {
        bebida_progresso++;
        bebida_ultima_tecla = batida;
        if (bebida_progresso >= 10) finalizar_ingrediente();
    }
}

// MONTAGEM - MEMORIA DE SETAS
if (montagem_ativa) {
    montagem_cronometro--;
    if (montagem_fase == 0) {
        if (montagem_cronometro <= 0) {
            montagem_fase = 1;
            montagem_cronometro = montagem_tempo_jogo;
            montagem_posicao = 0;
        }
    } else if (montagem_fase == 1) {
        var falhou = false;
        if (montagem_cronometro <= 0) falhou = true;
        else {
            var tecla_digitada = 0;
            if (keyboard_check_pressed(vk_up)) tecla_digitada = 1;
            if (keyboard_check_pressed(vk_down)) tecla_digitada = 2;
            if (keyboard_check_pressed(vk_left)) tecla_digitada = 3;
            if (keyboard_check_pressed(vk_right)) tecla_digitada = 4;
            if (tecla_digitada != 0) {
                if (tecla_digitada == montagem_sequencia[montagem_posicao]) {
                    montagem_posicao++;
                    if (montagem_posicao >= montagem_tamanho) {
                        montagem_ativa = false;
                        montagem_concluida = true;
                        tempo_missao_rodando = false;
                        var m = missoes[indice_missao];
                        mensagem_conclusao = "PARABENS! MISSAO " + string(indice_missao + 1) + " DE 8 CONCLUIDA!";
                        tempo_mensagem_conclusao = room_speed * 4;
                        xp += m.bonus;
                        xp_ganho_missao = xp - xp_inicio_missao;
                        receita_concluida_nome = m.nome;
                        if (xp_ganho_missao >= 500) classificacao_missao = "CHEF ESTRELA!";
                        else if (xp_ganho_missao >= 400) classificacao_missao = "EXCELENTE!";
                        else if (xp_ganho_missao >= 300) classificacao_missao = "MUITO BOM!";
                        else classificacao_missao = "MISSAO CONCLUIDA!";
                        mensagem = "Receita concluida! +" + string(m.bonus) + " XP!";
                        sacola = [];
                        ingredientes_coletados = 0;
                        preparo_ativo = false;
                        missao_ativa = false;
                        missao_concluida = true;
                        for (var j = 0; j < array_length(concluidos); j++) concluidos[j] = false;
                        indice_missao++;
                        if (xp >= 500) cargo = "Chef de cozinha";
                        else if (xp >= 250) cargo = "Cozinheiro";
                        else if (xp >= 100) cargo = "Assistente de cozinha";
                        if (indice_missao >= array_length(missoes)) {
                            jogo_concluido = true;
                            mensagem_missao = "Todas as receitas concluidas!";
                        } else mensagem_missao = "Volte ao Chef para a proxima missao!";
                    }
                } else {
                    montagem_erros++;
                    montagem_posicao = 0;
                    if (montagem_erros >= 3) falhou = true;
                }
            }
        }
        if (falhou) {
            montagem_ativa = false;
            preparo_ativo = false;
            mensagem = "Montagem falhou! Aperte E na bancada para tentar novamente.";
        }
    }
}

if (tempo_mensagem_conclusao > 0) tempo_mensagem_conclusao--;

// ========================================
// CONTROLE DE ANIMACAO DO CHEF
// ========================================

chef_tempo++;

// Troca de comportamento
if (chef_tempo >= chef_duracao) {

    chef_tempo = 0;
    chef_frame = 0;

    // Alterna entre os quatro estados
    chef_estado = (chef_estado + 1) mod 4;

    switch (chef_estado) {

        case 0:
            chef_sprite = spr_chef_normal;
            chef_duracao = room_speed * 6;
            break;

        case 1:
            chef_sprite = spr_chef_pensando;
            chef_duracao = room_speed * 4;
            break;

        case 2:
            chef_sprite = spr_chef_orientando;
            chef_duracao = room_speed * 4;
            break;

        case 3:
            chef_sprite = spr_chef_bracos_cruzados;
            chef_duracao = room_speed * 6;
            break;
    }
}

// Animacao dos quadros
chef_frame += chef_vel_anim;

if (chef_frame >= sprite_get_number(chef_sprite)) {
    chef_frame = 0;
}