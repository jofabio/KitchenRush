/// KITCHENRUSH | STEP | INTERFACE V3 + MISSOES V5
// F11 alterna tela cheia, sem alterar coordenadas logicas de colisao.
if (keyboard_check_pressed(vk_f11)) window_set_fullscreen(!window_get_fullscreen());
// M liga/desliga todo o som
if (keyboard_check_pressed(ord("M"))) { global.mudo = !global.mudo; audio_master_gain(global.mudo ? 0 : 1); }
display_set_gui_maximise(window_get_width() / 1280, window_get_height() / 720);


// Estado inicial da animacao a cada frame
if (pergunta_bloqueio > 0) pergunta_bloqueio--;
player_andando = false;
// Cronometro em segundos reais: ativo em perguntas, minigames e montagem.
if (missao_ativa && tempo_missao_rodando) {
    tempo_restante_missao = max(0, tempo_restante_missao - delta_time / 1000000);
    if (tempo_restante_missao <= 0) falhar_missao_tempo();
}
if (falha_missao_visivel > 0) falha_missao_visivel = max(0, falha_missao_visivel - delta_time / 1000000);

// Loja e avisos de progressao (L abre a loja entre missoes)
economia_step();

// KITCHENRUSH - STEP | MINIGAMES POR ESTACAO
// 1) Pergunta -> 2) minigame -> 3) ingrediente e XP -> 4) montagem

if (!pergunta_ativa && !preparo_ativo && !selecao_ativa && !loja_aberta) {
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
	
    // INTERACOES: chef, bancada, geladeira, fogao e estacoes.
    if (keyboard_check_pressed(ord("E"))) {
        tocar_som(snd_interagir, 0.5);
        if (point_distance(player_x,player_y,480,400)<85) {
            if (jogo_concluido) mensagem="Chef: Parabens! As nove missoes foram concluidas!";
            else if (!missao_ativa) {
                missao_ativa=true; missao_concluida=false;
                sacola=[]; ingredientes_coletados=0;
                frigorifico_verificado=false; fogao_verificado=false;
                for(var c=0;c<array_length(concluidos);c++) concluidos[c]=false;
                tempo_total_missao=limites_tempo_missoes[indice_missao];
                tempo_restante_missao=tempo_total_missao;
                tempo_missao_rodando=true; falha_missao_visivel=0;
                xp_inicio_missao=xp;
                var m=missoes[indice_missao];
                mensagem="Chef: Missao " + string(indice_missao+1)+" - "+m.nome;
                if (m.livre) {
                    mensagem_missao=((indice_missao==8)?"Escolha de 7 a 8 alimentos":"Escolha "+string(m.quantidade)+" alimentos")+" | kcal "+string(m.kcal_min)+"-"+string(m.kcal_max)+" | grupos: "+string_join_ext(", ",m.requisitos);
                } else {
                    mensagem_missao="Colete: "+string_join_ext(", ",m.ingredientes);
                }
            } else mensagem="Chef: "+mensagem_missao;
        } else if (player_x>=325 && player_x<=620 && player_y>=445 && player_y<=610) {
            if (!missao_ativa) mensagem="Bancada: Fale com o Chef primeiro!";
            else {
                var avaliacao=avaliar_prato();
                feedback_nutricional=avaliacao.texto;
                if (avaliacao.aprovado) {
                    // A geladeira e o fogao funcionam como pontos de consulta,
                    // sem criar bloqueios artificiais na receita atual.
                    iniciar_montagem();
                } else mensagem="Bancada: "+avaliacao.texto;
            }
        } else if (point_distance(player_x,player_y,115,520)<105) {
            if (missao_ativa) {
                frigorifico_verificado=true;
                mensagem="Geladeira: ingredientes disponiveis nas estacoes. Escolha com E.";
            } else mensagem="Geladeira: fale com o Chef para iniciar.";
        } else if (point_distance(player_x,player_y,835,520)<105) {
            if(missao_ativa) {
                fogao_verificado=true;
                mensagem="Fogao: prepare proteinas e graos nos minigames das estacoes.";
            } else mensagem="Fogao: fale com o Chef primeiro.";
        } else {
            var perto=-1;
            var menor=99999;
            for(var k=0;k<array_length(est_x);k++) {
                var distancia=point_distance(player_x,player_y,est_x[k],est_y[k]);
                if(distancia<125 && distancia<menor) {perto=k;menor=distancia;}
            }
            if(perto>=0 && missao_ativa) abrir_estacao(perto);
            else if(!missao_ativa) mensagem="Fale com o Chef para iniciar.";
            else mensagem="Aproxime-se de uma estacao.";
        }
    }
    // R desfaz a ultima coleta (somente quando livre e sem outro painel).
    if (keyboard_check_pressed(ord("R")) && missao_ativa && missoes[indice_missao].livre && array_length(sacola)>0) {
        var ultimo=sacola[array_length(sacola)-1];
        array_pop(sacola);
        ingredientes_coletados=array_length(sacola);
        mensagem=ultimo+" removido da sacola.";
    }
}

// SELECAO LIVRE DAS ESTACOES (teclas 1 a 9 e 0 para cancelar).
if(selecao_ativa) {
    if(keyboard_check_pressed(ord("0")) || keyboard_check_pressed(vk_escape)) selecao_ativa=false;
    else {
        var esc=-1;
        for(var v=1;v<=9;v++) if(keyboard_check_pressed(ord("0")+v) || keyboard_check_pressed(vk_numpad0+v)) {esc=v-1;break;}
        if(esc>=0 && esc<array_length(selecao_opcoes)) {
            var idx=selecao_opcoes[esc];
            selecao_ativa=false;
            tocar_som(snd_menu_ok, 0.6);
            iniciar_escolha_ingrediente(idx,selecao_setor);
        }
    }
}

// PERGUNTAS SORTEADAS PELA FAIXA DE DIFICULDADE.
if(pergunta_ativa && pergunta_bloqueio<=0) {
    var escolha=-1;
    if(keyboard_check_pressed(ord("1")) || keyboard_check_pressed(vk_numpad1)) escolha=0;
    if(keyboard_check_pressed(ord("2")) || keyboard_check_pressed(vk_numpad2)) escolha=1;
    if(keyboard_check_pressed(ord("3")) || keyboard_check_pressed(vk_numpad3)) escolha=2;
    if(keyboard_check_pressed(ord("4")) || keyboard_check_pressed(vk_numpad4)) escolha=3;
    if(escolha>=0) {
        if(escolha==correta) {
            tocar_som(snd_acerto, 0.8);
            iniciar_minigame_setor(setor_atual,indice_ingrediente_pendente);
            mensagem="Resposta correta! Conclua o minigame.";
        } else {
            tocar_som(snd_erro, 0.8);
            mensagem="Resposta incorreta! Tente novamente na estacao.";
        }
        pergunta_ativa=false;
        setor_atual=-1;
    }
}

// VERDURAS - CORTE: erros acumulados ate reinicio automatico.
if (corte_ativo) {
    corte_posicao += corte_velocidade * corte_direcao;
    if (corte_posicao >= 100) { corte_posicao = 100; corte_direcao = -1; }
    if (corte_posicao <= 0) { corte_posicao = 0; corte_direcao = 1; }
    if (keyboard_check_pressed(vk_space)) {
        if (corte_posicao >= corte_zona_inicio && corte_posicao <= corte_zona_fim) {
            corte_acertos++; corte_velocidade += 1;
            tocar_som(snd_faca, 1, 0.92 + corte_acertos * 0.06); // faca batendo na tabua
            mensagem_preparo = "CORTE PERFEITO!";
            if (corte_acertos >= 3) finalizar_ingrediente();
        } else {
            corte_erros++;
            tocar_som(snd_faca_erro, 0.9); // corte errado: pancada seca
            mini_registrar_erro("Corte fora da zona!");
        }
    }
}
// GRAOS: passar do ponto ou clicar fora conta como erro.
if (arroz_ativo) {
    arroz_progresso += arroz_velocidade;
    if (arroz_progresso >= 100) {
        arroz_progresso = 0; arroz_tentativas++;
        mini_registrar_erro("Passou do ponto!");
    } else if (keyboard_check_pressed(vk_space)) {
        if (arroz_progresso >= arroz_zona_inicio && arroz_progresso <= arroz_zona_fim) {
            finalizar_ingrediente();
        } else {
            arroz_tentativas++; arroz_progresso = 0;
            mini_registrar_erro("Fora do ponto!");
        }
    }
}

 // PROTEINAS - CONTROLE DE TEMPERATURA
if (frango_ativo) {

    frango_dificuldade = 1
        + (frango_tempo_ideal / frango_tempo_necessario) * 0.8;

    frango_oscilacao = sin(current_time / 350)
        * 0.12 * frango_dificuldade;

    frango_temperatura += frango_aquecimento
        * frango_dificuldade + frango_oscilacao;

    if (keyboard_check(vk_up)) {
        frango_temperatura += frango_ajuste;
    }

    if (keyboard_check(vk_down)) {
        frango_temperatura -= frango_ajuste;
    }

    frango_temperatura = clamp(frango_temperatura, 0, 100);

    if (frango_temperatura >= frango_zona_inicio
        && frango_temperatura <= frango_zona_fim) {

        frango_iniciou_aquecimento = true;
        frango_fora_frames = 0;

        frango_tempo_ideal++;

        mensagem_preparo = "TEMPERATURA IDEAL! Continue assim!";

        if (frango_tempo_ideal >= frango_tempo_necessario) {
            finalizar_ingrediente();
        }

    } else {

        if (frango_temperatura < frango_zona_inicio) {
            mensagem_preparo = "AUMENTE O FOGO!";
        } else {
            mensagem_preparo = "DIMINUA O FOGO!";
        }

        if (frango_iniciou_aquecimento) {

            frango_fora_frames++;

            if (frango_fora_frames >= room_speed * 2) {

                frango_fora_frames = 0;

                mini_registrar_erro(
                    "Temperatura fora da faixa por muito tempo!"
                );
            }
        }
    }
}

// FRUTAS: sequencia reiniciada apos esgotar erros do nivel.
if (fruta_ativo) {
    if (fruta_aguardando_soltar) {
        var alguma_tecla_num = false;
        for (var k = 0; k <= 9; k++) {
            if (keyboard_check(ord("0") + k) || keyboard_check(vk_numpad0 + k)) alguma_tecla_num = true;
        }
        if (!alguma_tecla_num) fruta_aguardando_soltar = false;
    } else {
        fruta_tempo--;
        var resposta_fruta = -1;
        for (var k = 0; k <= 9; k++) {
            if (keyboard_check_pressed(ord("0") + k) || keyboard_check_pressed(vk_numpad0 + k)) {
                resposta_fruta = k; break;
            }
        }
        if (resposta_fruta != -1) {
            if (resposta_fruta == fruta_alvo) {
                fruta_acertos++;
                tocar_som(snd_fruta_acerto, 0.8, 0.9 + 0.5 * (fruta_acertos / max(1, fruta_meta)));
                if (fruta_acertos >= fruta_meta) {
                    var segundos_usados = 20 - max(0, fruta_tempo) / room_speed;
                    if (segundos_usados <= 5) fruta_bonus_xp = 150;
                    else if (segundos_usados <= 8) fruta_bonus_xp = 100;
                    else if (segundos_usados <= 12) fruta_bonus_xp = 60;
                    else if (segundos_usados <= 16) fruta_bonus_xp = 30;
                    else fruta_bonus_xp = 0;
                    finalizar_ingrediente();
                } else {
                    var anterior = fruta_alvo;
                    do { fruta_alvo = irandom_range(0, 9); } until (fruta_alvo != anterior);
                    mensagem_preparo = "BOA! Continue acertando!";
                }
            } else {
                fruta_alvo = irandom_range(0, 9);
                mini_registrar_erro("Numero incorreto!");
            }
        }
        if (fruta_ativo && fruta_tempo <= 0) mini_registrar_erro("Tempo de frutas esgotado!");
        // Evita contagem negativa repetindo o mesmo erro em frames seguintes.
        if (fruta_ativo && fruta_tempo <= 0) {
            fruta_tempo = 20 * room_speed;
            fruta_acertos = 0;
            fruta_aguardando_soltar = true;
        }
    }
}
// LATICINIOS - DOSAGEM
if (leite_ativo) {
    if (keyboard_check(vk_space)) leite_nivel = min(100, leite_nivel + leite_velocidade);
    if (keyboard_check_released(vk_space)) {
        if (leite_nivel >= leite_zona_inicio && leite_nivel <= leite_zona_fim) finalizar_ingrediente();
        else { leite_nivel = 0; mini_registrar_erro("Dosagem incorreta!"); }
    }
}
// BEBIDAS - MISTURA ALTERNADA; repeticao da mesma tecla e erro.
if (bebida_ativo) {
    var batida = 0;
    if (keyboard_check_pressed(ord("A"))) batida = 1;
    if (keyboard_check_pressed(ord("D"))) batida = 2;
    if (batida != 0) {
        if (batida != bebida_ultima_tecla) {
            bebida_progresso++; bebida_ultima_tecla = batida;
            tocar_som(snd_mistura, 0.9, (batida == 1) ? 1.0 : 1.3);
            if (bebida_progresso >= bebida_meta) finalizar_ingrediente();
        } else mini_registrar_erro("Repita alternando A e D!");
    }
}

// MONTAGEM - MEMORIA DE SETAS
if (montagem_ativa) {
    montagem_cronometro--;
    if (montagem_fase == 0) {
        // toca a sequencia de notas enquanto as setas aparecem
        var _idx = floor((montagem_tempo_memoria - montagem_cronometro) / (montagem_tempo_memoria / max(1, montagem_tamanho)));
        if (_idx != som_montagem_idx && _idx >= 0 && _idx < montagem_tamanho) {
            som_montagem_idx = _idx;
            tocar_som(snd_seta, 0.6, som_pitch_seta[montagem_sequencia[_idx]]);
        }
        if (montagem_cronometro <= 0) {
            montagem_fase = 1;
            montagem_cronometro = montagem_tempo_jogo;
            montagem_posicao = 0;
        }
    } else if (montagem_fase == 1) {
        var falhou = false;
        if (montagem_cronometro <= 0) { mini_registrar_erro("Tempo da montagem esgotado!"); falhou = false; }
        else {
            var tecla_digitada = 0;
            if (keyboard_check_pressed(vk_up)) tecla_digitada = 1;
            if (keyboard_check_pressed(vk_down)) tecla_digitada = 2;
            if (keyboard_check_pressed(vk_left)) tecla_digitada = 3;
            if (keyboard_check_pressed(vk_right)) tecla_digitada = 4;
            if (tecla_digitada != 0) {
                if (tecla_digitada == montagem_sequencia[montagem_posicao]) {
                    tocar_som(snd_seta, 0.8, som_pitch_seta[tecla_digitada]);
                    montagem_posicao++;
                    if (montagem_posicao >= montagem_tamanho) {
                        montagem_ativa = false;
                        montagem_concluida = true;
                        tempo_missao_rodando = false;
                        var m = missoes[indice_missao];
                        mensagem_conclusao = "PARABENS! MISSAO " + string(indice_missao + 1) + " DE " + string(array_length(missoes)) + " CONCLUIDA!";
                        tempo_mensagem_conclusao = room_speed * 4;
                        ganhar_xp(m.bonus);
                        moedas_ganhas_missao = moedas_da_missao(m);
                        ganhar_moedas(moedas_ganhas_missao);
                        tocar_som(snd_missao_ok, 1);
                        som_moeda_atraso = round(room_speed * 1.4);
                        xp_ganho_missao = xp - xp_inicio_missao;
                        receita_concluida_nome = m.nome;
                        if (xp_ganho_missao >= 500) classificacao_missao = "CHEF ESTRELA!";
                        else if (xp_ganho_missao >= 400) classificacao_missao = "EXCELENTE!";
                        else if (xp_ganho_missao >= 300) classificacao_missao = "MUITO BOM!";
                        else classificacao_missao = "MISSAO CONCLUIDA!";
                        mensagem = feedback_nutricional + " +" + string(m.bonus) + " XP! +" + string(moedas_ganhas_missao) + " moedas!";
                        sacola = [];
                        ingredientes_coletados = 0;
                        preparo_ativo = false;
                        missao_ativa = false;
                        missao_concluida = true;
                        for (var j = 0; j < array_length(concluidos); j++) concluidos[j] = false;
                        indice_missao++;
                        salvar_economia(); // grava a proxima missao
                        if (indice_missao >= array_length(missoes)) {
                            jogo_concluido = true;
                            mensagem_missao = "Todas as receitas concluidas!";
                        } else mensagem_missao = "Volte ao Chef para a proxima missao! (L abre a loja)";
                    }
                } else {
                    montagem_erros++;
                    montagem_posicao = 0;
                    mini_registrar_erro("Sequencia de setas incorreta!");
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
            chef_sprite = chef_sprite_do_estado(0);
            chef_duracao = room_speed * 6;
            break;

        case 1:
            chef_sprite = chef_sprite_do_estado(1);
            chef_duracao = room_speed * 4;
            break;

        case 2:
            chef_sprite = chef_sprite_do_estado(2);
            chef_duracao = room_speed * 4;
            break;

        case 3:
            chef_sprite = chef_sprite_do_estado(3);
            chef_duracao = room_speed * 6;
            break;
    }
}

// Animacao dos quadros
chef_frame += chef_vel_anim;

if (chef_frame >= sprite_get_number(chef_sprite)) {
    chef_frame = 0;
}

// SOM: loops e avisos que dependem do estado (fogo, fervura, despejar, passos, tempo)
atualizar_sons_minigames();
