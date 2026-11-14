/// KITCHENRUSH | CREATE | INTERFACE V3
/// A jogabilidade continua em coordenadas logicas 960 x 640.
/// Apenas o desenho foi expandido para um palco visual 1280 x 720.
/// Se houver outros objetos Draw GUI, reveja a ordem de desenho entre eles.

// Maximiza a GUI para cobrir TODA a janela (inclusive faixas pretas).
// O fator garante que as coordenadas virtuais sejam sempre 1280 x 720.

/// INICIALIZA O SORTEIO ALEATORIO
randomize();

// ==========================================
// SOM: musica de fundo e efeitos dos minigames
// ==========================================
audio_stop_all();
if (!variable_global_exists("vol_sfx")) global.vol_sfx = 1;
if (!variable_global_exists("vol_musica")) global.vol_musica = 1;
if (!variable_global_exists("mudo")) global.mudo = false;
audio_master_gain(global.mudo ? 0 : 1);

// Toca um efeito (volume 0..1, pitch 1 = normal).
tocar_som = function(_snd, _vol = 1, _pitch = 1) {
    var _id = audio_play_sound(_snd, 10, false);
    audio_sound_gain(_id, _vol * global.vol_sfx, 0);
    audio_sound_pitch(_id, _pitch);
    return _id;
};
// Para um som em loop e devolve -1 (marca "nao esta tocando").
parar_som = function(_id) {
    if (_id != -1) audio_stop_sound(_id);
    return -1;
};

som_fogo = -1;        // chama do fogao (minigame de proteinas)
som_chiado = -1;      // fritura quando a temperatura esta ideal
som_fervura = -1;     // agua fervendo (minigame de graos)
som_leite = -1;       // liquido sendo despejado (laticinios)
som_passo_tempo = 0;
som_moeda_atraso = 0;
som_alerta_ultimo = -1;
som_frango_na_zona = false;
som_montagem_idx = -1;
// Nota de cada seta (1 cima, 2 baixo, 3 esquerda, 4 direita) - escala pentatonica
som_pitch_seta = [1, 1.0, 1.26, 1.498, 1.682];

musica_cozinha = audio_play_sound(mus_cozinha, 1, true);
audio_sound_gain(musica_cozinha, 0.35 * global.vol_musica, 0);

// Chamada todo frame no fim do Step: sons continuos que dependem do estado do jogo.
atualizar_sons_minigames = function() {
    var _sfx = global.vol_sfx;

    // Musica mais baixa durante minigames, para os efeitos aparecerem
    if (audio_is_playing(musica_cozinha)) {
        audio_sound_gain(musica_cozinha, (preparo_ativo ? 0.12 : 0.35) * global.vol_musica, 350);
    }

    // PROTEINAS: fogo cresce e fica mais agudo com a temperatura; chiado na zona ideal
    if (frango_ativo) {
        var _p = clamp(frango_temperatura / 100, 0, 1);
        if (som_fogo == -1 || !audio_is_playing(som_fogo)) som_fogo = audio_play_sound(snd_fogo_loop, 5, true);
        audio_sound_gain(som_fogo, lerp(0.12, 1.0, _p) * _sfx, 80);
        audio_sound_pitch(som_fogo, lerp(0.75, 1.4, _p));

        var _na_zona = (frango_temperatura >= frango_zona_inicio && frango_temperatura <= frango_zona_fim);
        var _quente = (frango_temperatura > frango_zona_fim);
        if (som_chiado == -1 || !audio_is_playing(som_chiado)) {
            som_chiado = audio_play_sound(snd_chiado_loop, 5, true);
            audio_sound_gain(som_chiado, 0, 0);
        }
        audio_sound_gain(som_chiado, (_na_zona ? 0.9 : (_quente ? 0.5 : 0)) * _sfx, 150);
        audio_sound_pitch(som_chiado, _quente ? 1.2 : 1);

        // "ding" ao entrar na faixa ideal
        if (_na_zona && !som_frango_na_zona) tocar_som(snd_ding, 0.7);
        som_frango_na_zona = _na_zona;

        // bipe de aviso: grave = esta frio, agudo = esta quente demais
        if (frango_iniciou_aquecimento && !_na_zona && frango_fora_frames > 0
            && (frango_fora_frames mod (room_speed div 2)) == 1) {
            tocar_som(snd_alerta_tempo, 0.6, _quente ? 1.35 : 0.75);
        }
    } else {
        som_fogo = parar_som(som_fogo);
        som_chiado = parar_som(som_chiado);
        som_frango_na_zona = false;
    }

    // GRAOS: fervura aumenta ate o ponto de transbordar
    if (arroz_ativo) {
        var _a = clamp(arroz_progresso / 100, 0, 1);
        if (som_fervura == -1 || !audio_is_playing(som_fervura)) som_fervura = audio_play_sound(snd_fervura_loop, 5, true);
        audio_sound_gain(som_fervura, lerp(0.25, 1.0, _a) * _sfx, 80);
        audio_sound_pitch(som_fervura, lerp(0.85, 1.25, _a));
    } else {
        som_fervura = parar_som(som_fervura);
    }

    // LATICINIOS: som de despejar enquanto ESPACO esta pressionado
    if (leite_ativo && keyboard_check(vk_space) && leite_nivel < 100) {
        if (som_leite == -1 || !audio_is_playing(som_leite)) som_leite = audio_play_sound(snd_leite_loop, 5, true);
        audio_sound_gain(som_leite, 0.85 * _sfx, 60);
        audio_sound_pitch(som_leite, lerp(0.8, 1.4, clamp(leite_nivel / 100, 0, 1)));
    } else {
        som_leite = parar_som(som_leite);
    }

    // Ultimos 10 segundos da missao: tique a cada segundo
    if (missao_ativa && tempo_missao_rodando && tempo_restante_missao > 0 && tempo_restante_missao <= 10) {
        var _seg = ceil(tempo_restante_missao);
        if (_seg != som_alerta_ultimo) {
            som_alerta_ultimo = _seg;
            tocar_som(snd_alerta_tempo, 0.5, (_seg <= 3) ? 1.4 : 1);
        }
    } else {
        som_alerta_ultimo = -1;
    }

    // Moedas tocam um instante depois da fanfarra da missao
    if (som_moeda_atraso > 0) {
        som_moeda_atraso--;
        if (som_moeda_atraso <= 0) tocar_som(snd_moeda, 0.9);
    }

    // Passos do estagiario
    if (player_andando) {
        som_passo_tempo--;
        if (som_passo_tempo <= 0) {
            tocar_som(snd_passo, 0.45, random_range(0.85, 1.1));
            som_passo_tempo = 18;
        }
    } else {
        som_passo_tempo = 0;
    }
};

window_set_size(1280, 720);
display_set_gui_maximise(window_get_width() / 1280, window_get_height() / 720);

// Posicionamento do antigo mapa no novo palco visual.
// Colisoes, movimentacao e perguntas NAO precisam ser recalculadas.
ui_map_x = function(_x) { return 24 + (_x - 20) * (1232 / 920); };
ui_map_y = function(_y) { return 165 + (_y - 110) * (461 / 505); };

// Sprite opcional: importe spr_sacola.png como recurso 'spr_sacola'.
// Se ainda nao tiver sido importado, a interface usa um icone provisório.
sprite_sacola_hud = asset_get_index("spr_sacola");

// ========================================
// POSICAO DO JOGADOR
// ========================================

player_x = 480;
player_y = 500;

// ========================================
// SPRITES E ANIMACAO DO ESTAGIARIO
// ========================================

sprite_player = spr_player_baixo;

frame_player = 0;

anim_velocidade = 0.14;

player_andando = false;
vel = 3;
raio = 14;
xp = 0;
cargo = "Estagiario";
mensagem = "Chef: Bem-vindo! Aproxime-se de uma estacao e aperte E.";
pergunta_ativa = false;
pergunta = "";
opcoes = [];
correta = 0;
setor_atual = -1;
concluidos = array_create(6, false);
nomes = ["Frutas", "Verduras", "Graos", "Proteinas", "Laticinios", "Bebidas"];
questoes = [
    "Qual alimento e uma fonte de fibras?",
    "Qual habito ajuda a variar os micronutrientes?",
    "Qual opcao costuma ter mais fibras?",
    "Qual alimento e fonte vegetal de proteina?",
    "Qual informacao pode ser consultada no rotulo?",
    "Qual bebida e uma boa escolha para hidratacao diaria?"
];
respostas = [
    ["Maca com casca", "Refrigerante", "Bala"],
    ["Comer sempre a mesma verdura", "Variar os vegetais", "Evitar legumes"],
    ["Arroz integral", "Acucar refinado", "Bala"],
    ["Feijao", "Refrigerante", "Acucar"],
    ["Quantidade de sodio", "Cor da embalagem", "Marca mais bonita"],
    ["Agua", "Refrigerante", "Energetico"]
];
gabarito = [0, 1, 0, 0, 0, 0];
// Estacoes nas coordenadas logicas originais.
est_x = [105, 105, 855, 855, 400, 560];
est_y = [210, 365, 210, 365, 190, 190];


// KITCHENRUSH - SISTEMA DE COLISOES

// Cada obstaculo: [esquerda, topo, direita, baixo]
obstaculos = [
    // Frutas
    [45, 155, 165, 265],

    // Verduras
    [45, 310, 165, 420],

    // Graos
    [795, 155, 915, 265],

    // Proteinas
    [795, 310, 915, 420],

    // Laticinios
    [340, 135, 460, 245],

    // Bebidas
    [500, 135, 620, 245],

    // Geladeira
    [65, 460, 165, 580],

    // Bancada de preparo
    [350, 515, 610, 585],

    // Pia
    [625, 515, 755, 585],

    // Fogao
    [785, 460, 890, 570]
];



// MISSOES, INVENTARIO E BANCO NUTRICIONAL V3
// 0 frutas; 1 verduras; 2 graos; 3 proteinas; 4 laticinios; 5 bebidas
sacola = [];
ingredientes_coletados = 0;
indice_missao = 0;
missao_ativa = false;
missao_concluida = false;
jogo_concluido = false;
pergunta_ativa = false;
selecao_ativa = false;
selecao_opcoes = [];
selecao_setor = -1;
indice_pergunta = -1;
indice_ingrediente_pendente = -1;
pergunta_bloqueio = 0;
mensagem_missao = "Fale com o Chef para iniciar a missao.";
perguntas_usadas = [];
frigorifico_verificado = false;
fogao_verificado = false;
feedback_nutricional = "";

banco_ingredientes = [
    { nome:"Arroz", setor:2, kcal:130, grupos:["carboidrato"] },
    { nome:"Frango", setor:3, kcal:165, grupos:["proteina"] },
    { nome:"Brocolis", setor:1, kcal:35, grupos:["vegetal"] },
    { nome:"Banana", setor:0, kcal:90, grupos:["fruta"] },
    { nome:"Leite", setor:4, kcal:120, grupos:["laticinio", "proteina"] },
    { nome:"Aveia", setor:2, kcal:115, grupos:["carboidrato", "fibra"] },
    { nome:"Peixe", setor:3, kcal:140, grupos:["proteina"] },
    { nome:"Batata", setor:1, kcal:90, grupos:["carboidrato"] },
    { nome:"Cenoura", setor:1, kcal:40, grupos:["vegetal"] },
    { nome:"Morango", setor:0, kcal:35, grupos:["fruta"] },
    { nome:"Iogurte", setor:4, kcal:100, grupos:["laticinio", "proteina"] },
    { nome:"Manga", setor:0, kcal:65, grupos:["fruta"] },
    { nome:"Laranja", setor:0, kcal:60, grupos:["fruta"] },
    { nome:"Arroz integral", setor:2, kcal:125, grupos:["carboidrato", "fibra"] },
    { nome:"Feijao", setor:2, kcal:90, grupos:["proteina", "fibra"] },
    { nome:"Ovo", setor:3, kcal:80, grupos:["proteina"] },
    { nome:"Tomate", setor:1, kcal:20, grupos:["vegetal"] },
    { nome:"Batata-doce", setor:1, kcal:110, grupos:["carboidrato"] },
    { nome:"Maca", setor:0, kcal:75, grupos:["fruta"] },
    { nome:"Abobrinha", setor:1, kcal:25, grupos:["vegetal"] },
    { nome:"Agua", setor:5, kcal:0, grupos:["bebida"] },
    { nome:"Suco de laranja", setor:5, kcal:110, grupos:["bebida"] },
    { nome:"Pepino", setor:1, kcal:15, grupos:["vegetal"] },
    { nome:"Lentilha", setor:2, kcal:110, grupos:["proteina", "fibra"] },
    { nome:"Queijo branco", setor:4, kcal:85, grupos:["laticinio", "proteina"] }
];

missoes = [
    {nome:"Refeicao equilibrada", nivel:"facil", quantidade:2, livre:false, ingredientes:["Arroz", "Frango"], requisitos:[], kcal_min:0, kcal_max:0, bonus:150, dica:"Colete arroz e frango."},
    {nome:"Cafe da manha nutritivo", nivel:"facil", quantidade:3, livre:false, ingredientes:["Banana", "Leite", "Aveia"], requisitos:[], kcal_min:0, kcal_max:0, bonus:200, dica:"Fruta, laticinio e cereal."},
    {nome:"Almoco saudavel", nivel:"facil", quantidade:3, livre:false, ingredientes:["Peixe", "Batata", "Cenoura"], requisitos:[], kcal_min:0, kcal_max:0, bonus:250, dica:"Proteina, carboidrato e vegetal."},
    {nome:"Lanche energetico", nivel:"medio", quantidade:4, livre:false, ingredientes:["Morango", "Iogurte", "Aveia", "Banana"], requisitos:[], kcal_min:0, kcal_max:0, bonus:300, dica:"Quatro alimentos de diferentes grupos."},
    {nome:"Prato do Chef", nivel:"medio", quantidade:4, livre:false, ingredientes:["Frango", "Arroz", "Cenoura", "Feijao"], requisitos:[], kcal_min:0, kcal_max:0, bonus:400, dica:"Combine proteina, carboidrato e vegetal."},
    {nome:"Cafe tropical", nivel:"medio", quantidade:5, livre:false, ingredientes:["Manga", "Iogurte", "Aveia", "Morango", "Leite"], requisitos:[], kcal_min:0, kcal_max:0, bonus:450, dica:"Combine cinco ingredientes."},
    {nome:"Almoco colorido", nivel:"dificil", quantidade:5, livre:true, ingredientes:[], requisitos:["proteina", "carboidrato", "vegetal"], kcal_min:320, kcal_max:550, bonus:500, dica:"Cinco ingredientes; proteina, carboidrato e vegetal."},
    {nome:"Desafio das calorias", nivel:"dificil", quantidade:6, livre:true, ingredientes:[], requisitos:["proteina", "carboidrato", "vegetal"], kcal_min:450, kcal_max:650, bonus:600, dica:"Seis ingredientes; respeite a faixa de energia."},
    {nome:"O grande desafio do Chef", nivel:"final", quantidade:8, quantidade_min:7, livre:true, ingredientes:[], requisitos:["proteina", "carboidrato", "vegetal", "fruta"], kcal_min:450, kcal_max:650, bonus:800, dica:""}
];

banco_perguntas = [
    {estacao:0, nivel:"facil", pergunta:"Qual fruta apresenta MENOS de 100 kcal em 100 g da parte comestivel?", opcoes:["Coco seco", "Uva-passa", "Maca fresca com casca", "Banana-passa"], correta:2},
    {estacao:0, nivel:"facil", pergunta:"Qual destas frutas normalmente tem MAIS de 200 kcal por 100 g?", opcoes:["Melancia fresca", "Mamao fresco", "Laranja fresca", "Uva-passa"], correta:3},
    {estacao:0, nivel:"facil", pergunta:"Qual fruta costuma ter MENOS calorias por 100 g?", opcoes:["Abacate fresco", "Coco seco", "Melancia fresca", "Banana-passa"], correta:2},
    {estacao:0, nivel:"facil", pergunta:"Ao preparar uma salada de frutas, qual cuidado e importante?", opcoes:["Nao lavar as maos", "Deixar cortadas ao sol", "Usar utensilio sujo", "Higienizar as frutas"], correta:3},
    {estacao:0, nivel:"facil", pergunta:"Qual opcao tende a preservar mais fibras da laranja?", opcoes:["Comer a fruta inteira", "Coar o suco", "Usar refrigerante", "Filtrar toda a polpa"], correta:0},
    {estacao:0, nivel:"medio", pergunta:"Qual fruta geralmente concentra MAIS carboidratos por 100 g?", opcoes:["Melancia fresca", "Morango fresco", "Uva-passa", "Mamao fresco"], correta:2},
    {estacao:0, nivel:"medio", pergunta:"Qual opcao costuma fornecer MAIS fibras por 100 g?", opcoes:["Suco de maca coado", "Suco de laranja coado", "Agua de coco", "Coco seco"], correta:3},
    {estacao:0, nivel:"medio", pergunta:"Qual fruta fresca geralmente tem MENOS energia por 100 g?", opcoes:["Banana fresca", "Abacate fresco", "Melancia fresca", "Uva-passa"], correta:2},
    {estacao:0, nivel:"medio", pergunta:"Como aproveitar a doçura de uma banana madura em uma vitamina?", opcoes:["Evitar acucar extra", "Adicionar calda", "Misturar refrigerante", "Adicionar xarope"], correta:0},
    {estacao:0, nivel:"medio", pergunta:"Qual escolha costuma favorecer a saciedade pelo teor de fibra?", opcoes:["Suco filtrado", "Fruta inteira com casca comestivel", "Refresco adoçado", "Xarope de frutas"], correta:1},
    {estacao:0, nivel:"dificil", pergunta:"Qual fruta se destaca por ter MAIS gorduras totais por 100 g?", opcoes:["Abacate fresco", "Melancia fresca", "Morango fresco", "Laranja fresca"], correta:0},
    {estacao:0, nivel:"dificil", pergunta:"Em 100 g, qual produto de fruta tende a ter MAIOR densidade energetica?", opcoes:["Morango fresco", "Suco de laranja sem acucar", "Uva-passa", "Maca fresca"], correta:2},
    {estacao:0, nivel:"dificil", pergunta:"Um lanche de 300 kcal recebe duas porcoes de morango de 35. Total?", opcoes:["370 kcal", "335 kcal", "365 kcal", "400 kcal"], correta:0},
    {estacao:0, nivel:"dificil", pergunta:"Qual pratica reduz o escurecimento de frutas cortadas sem substituir a higiene?", opcoes:["Deixar no calor", "Reduzir contato com ar", "Expor por horas ao sol", "Usar utensilio sujo"], correta:1},
    {estacao:0, nivel:"dificil", pergunta:"Uma pessoa precisa aumentar fibras. Qual troca faz mais sentido?", opcoes:["Maca com casca por xarope", "Fruta inteira por refrigerante", "Suco coado por fruta inteira", "Fruta por agua apenas"], correta:2},
    {estacao:1, nivel:"facil", pergunta:"Qual vegetal cru costuma ter MENOS de 30 kcal por 100 g?", opcoes:["Batata-doce crua", "Mandioca crua", "Cenoura crua", "Pepino cru"], correta:3},
    {estacao:1, nivel:"facil", pergunta:"Qual vegetal geralmente fornece MAIS energia por 100 g?", opcoes:["Alface crua", "Pepino cru", "Mandioca crua", "Tomate cru"], correta:2},
    {estacao:1, nivel:"facil", pergunta:"Qual destes alimentos e fonte vegetal de betacaroteno?", opcoes:["Cenoura crua", "Pepino sem casca", "Alface americana", "Cogumelo branco"], correta:0},
    {estacao:1, nivel:"facil", pergunta:"Tomate e brocolis podem contribuir principalmente com qual grupo?", opcoes:["Vitaminas e minerais", "Alcool", "Cafeina", "Gordura trans industrial"], correta:0},
    {estacao:1, nivel:"facil", pergunta:"Qual atitude aumenta a variedade de vegetais no prato?", opcoes:["Usar sempre o mesmo vegetal", "Combinar verduras de tipos diferentes", "Retirar os legumes", "Usar apenas sal"], correta:1},
    {estacao:1, nivel:"medio", pergunta:"Qual alimento costuma ter MAIS amido por 100 g?", opcoes:["Tomate cru", "Batata crua", "Pepino cru", "Alface crua"], correta:1},
    {estacao:1, nivel:"medio", pergunta:"Qual vegetal, em 100 g, tende a ter MENOS calorias?", opcoes:["Batata-doce cozida", "Inhame cozido", "Mandioca cozida", "Alface crua"], correta:3},
    {estacao:1, nivel:"medio", pergunta:"Qual preparo geralmente ajuda a conservar textura de vegetais?", opcoes:["Cozimento controlado", "Fervura muito prolongada", "Deixar fora da geladeira", "Aquecer ate carbonizar"], correta:0},
    {estacao:1, nivel:"medio", pergunta:"Cenoura tem 40 kcal e brocolis 35. Qual total das porcoes?", opcoes:["65 kcal", "75 kcal", "85 kcal", "95 kcal"], correta:1},
    {estacao:1, nivel:"medio", pergunta:"Para uma refeicao mais diversa, qual inclusao e mais apropriada?", opcoes:["Mais acucar", "Apenas sal", "Cenoura e abobrinha", "So agua"], correta:2},
    {estacao:1, nivel:"dificil", pergunta:"Qual vegetal geralmente tem MAIS carboidratos por 100 g?", opcoes:["Abobrinha crua", "Mandioca cozida", "Tomate cru", "Pepino cru"], correta:1},
    {estacao:1, nivel:"dificil", pergunta:"Entre 100 g destes alimentos, qual tende a oferecer MAIS energia?", opcoes:["Brocolis cozido sem oleo", "Cenoura cozida sem oleo", "Batata-doce cozida sem oleo", "Alface crua"], correta:2},
    {estacao:1, nivel:"dificil", pergunta:"Se a meta exige dois vegetais diferentes, qual combinacao atende?", opcoes:["Arroz e batata", "Brocolis e cenoura", "Frango e peixe", "Banana e leite"], correta:1},
    {estacao:1, nivel:"dificil", pergunta:"Qual consequencia e possivel ao cozinhar vegetais por tempo excessivo em agua?", opcoes:["Aumento certo de fibra", "Criacao de proteina animal", "Perda de nutrientes soluveis", "Ausencia de alteracao"], correta:2},
    {estacao:1, nivel:"dificil", pergunta:"Um prato de 590 kcal recebe brocolis 35 e tomate 20. Qual total?", opcoes:["655 kcal", "625 kcal", "635 kcal", "645 kcal"], correta:3},
    {estacao:2, nivel:"facil", pergunta:"Qual alimento costuma fornecer MAIS energia por 100 g?", opcoes:["Arroz branco cozido", "Aveia em flocos seca", "Arroz integral cozido", "Milho verde cozido"], correta:1},
    {estacao:2, nivel:"facil", pergunta:"Qual destes graos costuma ter MAIS fibras por 100 g na forma seca?", opcoes:["Arroz branco polido cru", "Aveia em flocos", "Amido de milho", "Farinha de arroz refinada"], correta:1},
    {estacao:2, nivel:"facil", pergunta:"Qual alimento tem MENOS de 200 kcal por 100 g?", opcoes:["Aveia em flocos seca", "Arroz branco cru", "Macarrao seco", "Arroz branco cozido sem oleo"], correta:3},
    {estacao:2, nivel:"facil", pergunta:"Qual ingrediente e conhecido pelo teor de fibras soluveis?", opcoes:["Acucar refinado", "Aveia", "Sal", "Agua"], correta:1},
    {estacao:2, nivel:"facil", pergunta:"No preparo de graos secos, qual atitude e adequada?", opcoes:["Usar panela suja", "Deixar sem agua no fogo", "Observar tempo e agua de cozimento", "Ignorar conservacao"], correta:2},
    {estacao:2, nivel:"medio", pergunta:"Qual opcao, em 100 g, costuma ter MAIS agua e MENOS energia?", opcoes:["Arroz branco cru", "Aveia em flocos", "Arroz branco cozido", "Farinha de trigo"], correta:2},
    {estacao:2, nivel:"medio", pergunta:"Qual produto tende a ter MENOS fibras por 100 g?", opcoes:["Farelo de trigo", "Aveia em flocos", "Arroz branco polido", "Farinha de trigo integral"], correta:2},
    {estacao:2, nivel:"medio", pergunta:"Qual alimento, em 100 g, geralmente fornece MAIS energia?", opcoes:["Arroz branco cozido", "Aveia em flocos seca", "Milho verde cozido", "Arroz integral cozido"], correta:1},
    {estacao:2, nivel:"medio", pergunta:"Por que cozinhar bem o feijao e importante?", opcoes:["Adiciona cafeina", "Elimina toda proteina", "Melhora a digestibilidade e seguranca", "Dispensa higiene"], correta:2},
    {estacao:2, nivel:"medio", pergunta:"Qual combinacao inclui cereal e leguminosa?", opcoes:["Banana e manga", "Leite e queijo", "Peixe e ovo", "Arroz e feijao"], correta:3},
    {estacao:2, nivel:"dificil", pergunta:"Qual substituicao geralmente AUMENTA as fibras de um prato?", opcoes:["Arroz integral por arroz branco", "Arroz branco por arroz integral", "Aveia por amido de milho", "Feijao por macarrao refinado"], correta:1},
    {estacao:2, nivel:"dificil", pergunta:"Comparando 100 g de cada produto, qual e normalmente MAIS calorico?", opcoes:["Arroz integral cozido", "Milho verde cozido", "Aveia em flocos seca", "Arroz branco cozido"], correta:2},
    {estacao:2, nivel:"dificil", pergunta:"Arroz 130 kcal e feijao 90 kcal. Duas porcoes de cada somam:", opcoes:["460 kcal", "420 kcal", "440 kcal", "480 kcal"], correta:2},
    {estacao:2, nivel:"dificil", pergunta:"Qual vantagem nutricional pode haver na combinacao de arroz e feijao?", opcoes:["Ausencia de fibras", "Eliminacao total de carboidratos", "Formacao de cafeina", "Complementaridade de aminoacidos"], correta:3},
    {estacao:2, nivel:"dificil", pergunta:"Se a meta e incluir proteina vegetal e fibra, qual grao escolher?", opcoes:["Lentilha", "Arroz branco isolado", "Acucar refinado", "Sal de cozinha"], correta:0},
    {estacao:3, nivel:"facil", pergunta:"Qual alimento geralmente tem MAIS proteina por 100 g?", opcoes:["Peito de frango grelhado", "Arroz branco cozido", "Tomate cru", "Batata cozida"], correta:0},
    {estacao:3, nivel:"facil", pergunta:"Qual opcao costuma ter MENOS de 5 g de proteina por 100 g?", opcoes:["Peito de frango grelhado", "Ovo cozido", "Peixe grelhado", "Batata cozida"], correta:3},
    {estacao:3, nivel:"facil", pergunta:"Qual alimento normalmente tem MAIS gordura por 100 g?", opcoes:["Peito de frango sem pele grelhado", "Bacalhau cozido", "Bacon frito", "Tilapia grelhada"], correta:2},
    {estacao:3, nivel:"facil", pergunta:"Qual alternativa tambem pode fornecer proteina de origem vegetal?", opcoes:["Sal", "Refrigerante", "Lentilha", "Acucar"], correta:2},
    {estacao:3, nivel:"facil", pergunta:"Qual destas opcoes e uma fonte de proteina animal?", opcoes:["Laranja", "Arroz branco", "Batata", "Peixe"], correta:3},
    {estacao:3, nivel:"medio", pergunta:"Qual preparo tende a aumentar MAIS as calorias do frango por 100 g?", opcoes:["Frango cozido sem oleo", "Frango grelhado sem oleo", "Frango empanado e frito", "Frango feito no vapor"], correta:2},
    {estacao:3, nivel:"medio", pergunta:"Qual alimento costuma ter MAIS proteina por 100 g?", opcoes:["Ovo cozido", "Peito de frango grelhado", "Arroz cozido", "Feijao cozido"], correta:1},
    {estacao:3, nivel:"medio", pergunta:"Frango 165 kcal e ovo 80 kcal formam uma refeicao de:", opcoes:["255 kcal", "235 kcal", "245 kcal", "265 kcal"], correta:2},
    {estacao:3, nivel:"medio", pergunta:"Qual pratica evita contato cruzado ao preparar peixe e salada?", opcoes:["Deixar tudo em temperatura ambiente", "Usar a mesma tabua sem lavar", "Guardar juntos sem protecao", "Utensilios higienizados e separados"], correta:3},
    {estacao:3, nivel:"medio", pergunta:"Ao substituir frango por peixe na receita, qual grupo permanece presente?", opcoes:["Proteinas", "Frutas", "Graos", "Bebidas"], correta:0},
    {estacao:3, nivel:"dificil", pergunta:"Qual alimento em geral concentra MAIS gordura saturada por 100 g?", opcoes:["Peito de frango sem pele grelhado", "Tilapia cozida", "Bacon frito", "Clara de ovo cozida"], correta:2},
    {estacao:3, nivel:"dificil", pergunta:"Qual fonte animal tende a fornecer MAIS proteina por 100 g de alimento pronto?", opcoes:["Leite integral", "Iogurte natural", "Peito de frango grelhado", "Ovo cozido"], correta:2},
    {estacao:3, nivel:"dificil", pergunta:"Uma porcao de peixe tem 140 kcal. Uma e meia fornece:", opcoes:["240 kcal", "190 kcal", "220 kcal", "210 kcal"], correta:3},
    {estacao:3, nivel:"dificil", pergunta:"Qual grupo pode substituir carne para oferecer proteina vegetal?", opcoes:["Leguminosas como feijao e lentilha", "Refrigerantes comuns", "Oleos isolados", "Sal refinado"], correta:0},
    {estacao:3, nivel:"dificil", pergunta:"Qual conduta mais reduz a contaminacao cruzada ao manipular frango cru?", opcoes:["Reutilizar faca na salada", "Higienizar maos e utensilios depois", "Lavar carne e espalhar respingos", "Deixar cru ao lado do prato pronto"], correta:1},
    {estacao:4, nivel:"facil", pergunta:"Qual laticinio costuma ter MENOS gordura por 100 g?", opcoes:["Creme de leite", "Queijo parmesao", "Leite desnatado", "Manteiga"], correta:2},
    {estacao:4, nivel:"facil", pergunta:"Qual destes laticinios costuma ter MAIS proteina por 100 g?", opcoes:["Leite integral", "Iogurte natural tradicional", "Queijo parmesao", "Creme de leite"], correta:2},
    {estacao:4, nivel:"facil", pergunta:"Qual alimento geralmente tem MAIS de 300 kcal por 100 g?", opcoes:["Leite desnatado", "Iogurte natural", "Leite integral", "Queijo parmesao"], correta:3},
    {estacao:4, nivel:"facil", pergunta:"Qual cuidado e importante com leite aberto e perecivel?", opcoes:["Misturar a carne crua", "Deixar ao sol", "Guardar destampado no calor", "Refrigerar conforme orientacao"], correta:3},
    {estacao:4, nivel:"facil", pergunta:"A lactose e um tipo de:", opcoes:["Acucar do leite", "Gordura trans", "Mineral", "Vitamina"], correta:0},
    {estacao:4, nivel:"medio", pergunta:"Qual produto tende a ter MENOS calorias por 100 g?", opcoes:["Manteiga", "Queijo parmesao", "Leite desnatado", "Creme de leite"], correta:2},
    {estacao:4, nivel:"medio", pergunta:"Qual opcao costuma apresentar MAIS calcio por 100 g?", opcoes:["Leite integral", "Iogurte natural", "Creme de leite", "Queijo parmesao"], correta:3},
    {estacao:4, nivel:"medio", pergunta:"Qual laticinio tem MAIS gordura total por 100 g?", opcoes:["Leite desnatado", "Iogurte natural desnatado", "Leite integral", "Manteiga"], correta:3},
    {estacao:4, nivel:"medio", pergunta:"Qual diferenca existe entre intolerancia a lactose e alergia ao leite?", opcoes:["Envolvem mecanismos distintos", "Sao sempre a mesma condicao", "Nao exigem leitura do rotulo", "So existem em adultos"], correta:0},
    {estacao:4, nivel:"medio", pergunta:"Por que produtos lacteos pereciveis exigem cadeia de frio?", opcoes:["Para produzir mais lactose", "Para limitar multiplicacao microbiana", "Para aumentar acucar", "Para eliminar proteinas"], correta:1},
    {estacao:4, nivel:"dificil", pergunta:"Qual troca tende a reduzir MAIS a gordura sem retirar todo o calcio?", opcoes:["Leite desnatado por creme de leite", "Leite integral por leite desnatado", "Iogurte natural por manteiga", "Leite desnatado por manteiga"], correta:1},
    {estacao:4, nivel:"dificil", pergunta:"Qual laticinio apresenta MAIOR densidade energetica por 100 g?", opcoes:["Leite desnatado", "Iogurte natural", "Manteiga", "Leite integral"], correta:2},
    {estacao:4, nivel:"dificil", pergunta:"Qual medida atende melhor quem tem alergia confirmada a proteina do leite?", opcoes:["Evitar produtos com o alergeno e contato cruzado", "Escolher apenas sem lactose", "Ignorar avisos do rotulo", "Ferver qualquer queijo"], correta:0},
    {estacao:4, nivel:"dificil", pergunta:"Por que leite sem lactose pode continuar inadequado para alergia ao leite?", opcoes:["Contem apenas agua", "Pode conter proteinas do leite", "Nao possui minerais", "Tem sempre cafeina"], correta:1},
    {estacao:4, nivel:"dificil", pergunta:"Um preparo leva 2 porcoes de iogurte de 100 kcal e queijo 85. Total?", opcoes:["275 kcal", "265 kcal", "285 kcal", "300 kcal"], correta:2},
    {estacao:5, nivel:"facil", pergunta:"Qual bebida, em 100 ml, normalmente nao fornece calorias?", opcoes:["Refrigerante comum", "Suco de uva integral", "Leite integral", "Agua mineral"], correta:3},
    {estacao:5, nivel:"facil", pergunta:"Qual bebida geralmente tem MAIS acucar livre por 100 ml?", opcoes:["Agua mineral", "Cha sem acucar", "Refrigerante comum", "Cafe preto sem acucar"], correta:2},
    {estacao:5, nivel:"facil", pergunta:"Qual bebida costuma ter MENOS de 10 kcal em 100 ml?", opcoes:["Refrigerante comum", "Agua mineral", "Suco de uva integral", "Leite integral"], correta:1},
    {estacao:5, nivel:"facil", pergunta:"Por que a quantidade da porcao importa no rotulo de uma bebida?", opcoes:["Porque altera o total consumido", "Porque muda a cor", "Porque muda a marca", "Porque elimina calorias"], correta:0},
    {estacao:5, nivel:"facil", pergunta:"Qual bebida, quando pura, costuma ter zero kcal?", opcoes:["Suco adoçado", "Agua", "Refrigerante comum", "Vitamina com acucar"], correta:1},
    {estacao:5, nivel:"medio", pergunta:"Qual escolha tende a apresentar MENOS carboidratos por 100 ml?", opcoes:["Suco de laranja integral", "Refrigerante comum", "Agua mineral", "Leite integral"], correta:2},
    {estacao:5, nivel:"medio", pergunta:"Qual bebida geralmente oferece MAIS proteina por 100 ml?", opcoes:["Agua mineral", "Refrigerante comum", "Cha sem acucar", "Leite integral"], correta:3},
    {estacao:5, nivel:"medio", pergunta:"O que significa acucar adicionado em uma bebida?", opcoes:["Acucar colocado durante processamento ou preparo", "Todo mineral natural", "Fibra presente na fruta", "Toda agua da receita"], correta:0},
    {estacao:5, nivel:"medio", pergunta:"Uma bebida tem 80 kcal por 200 ml. Em 400 ml, sao:", opcoes:["120 kcal", "160 kcal", "180 kcal", "200 kcal"], correta:1},
    {estacao:5, nivel:"medio", pergunta:"Qual atitude e mais adequada para reduzir refrigerante na rotina?", opcoes:["Dobrar a porcao", "Adicionar xarope ao refrigerante", "Substituir parte do consumo por agua", "Trocar por bebida mais doce"], correta:2},
    {estacao:5, nivel:"dificil", pergunta:"Qual substituicao reduz MAIS o acucar adicionado de uma bebida?", opcoes:["Agua por refrigerante comum", "Cha sem acucar por cha adoçado", "Refrigerante comum por agua", "Cafe sem acucar por cafe adoçado"], correta:2},
    {estacao:5, nivel:"dificil", pergunta:"Qual bebida tende a apresentar MAIOR densidade energetica por 100 ml?", opcoes:["Agua mineral", "Cha sem acucar", "Cafe preto sem acucar", "Leite integral"], correta:3},
    {estacao:5, nivel:"dificil", pergunta:"Uma pessoa troca duas porcoes de suco de 110 kcal por agua. Economiza:", opcoes:["110 kcal", "220 kcal", "200 kcal", "240 kcal"], correta:1},
    {estacao:5, nivel:"dificil", pergunta:"Se um produto tem 8 g de acucar por 100 ml, em 350 ml ha:", opcoes:["30 g", "24 g", "28 g", "32 g"], correta:2},
    {estacao:5, nivel:"dificil", pergunta:"Ao comparar hidratacao e consumo de energia, qual frase esta correta?", opcoes:["Refrigerante nao contem acucar", "Toda bebida tem as mesmas calorias", "Suco coado sempre tem mais fibra", "Agua hidrata sem fornecer calorias"], correta:3}
];

buscar_alimento = function(_nome) {
    for (var i=0; i<array_length(banco_ingredientes); i++) {
        if (banco_ingredientes[i].nome == _nome) return banco_ingredientes[i];
    }
    return undefined;
};
tem_ingrediente = function(_nome) {
    for (var i=0; i<array_length(sacola); i++) if (sacola[i] == _nome) return true;
    return false;
};
coletar_ingrediente = function(_nome) {
    if (tem_ingrediente(_nome)) return false;
    array_push(sacola, _nome);
    ingredientes_coletados = array_length(sacola);
    return true;
};

sortear_pergunta = function(_nivel, _setor) {
    // Filtra pela estacao E pelo nivel de dificuldade da missao.
    var disponiveis = [];
    for (var i = 0; i < array_length(banco_perguntas); i++) {
        if (banco_perguntas[i].nivel != _nivel || banco_perguntas[i].estacao != _setor) continue;
        var usada = false;
        for (var j = 0; j < array_length(perguntas_usadas); j++) {
            if (perguntas_usadas[j] == i) { usada = true; break; }
        }
        if (!usada) array_push(disponiveis, i);
    }
    // Ao esgotar uma combinacao, limpa somente seu historico.
    if (array_length(disponiveis) == 0) {
        var restantes = [];
        for (var k = 0; k < array_length(perguntas_usadas); k++) {
            var usada_idx = perguntas_usadas[k];
            if (banco_perguntas[usada_idx].nivel != _nivel || banco_perguntas[usada_idx].estacao != _setor) {
                array_push(restantes, usada_idx);
            }
        }
        perguntas_usadas = restantes;
        for (var idx_pergunta = 0; idx_pergunta < array_length(banco_perguntas); idx_pergunta++) {
            if (banco_perguntas[idx_pergunta].nivel == _nivel && banco_perguntas[idx_pergunta].estacao == _setor) {
                array_push(disponiveis, idx_pergunta);
            }
        }
    }
    if (array_length(disponiveis) == 0) return undefined;
    var escolhido = disponiveis[irandom(array_length(disponiveis) - 1)];
    array_push(perguntas_usadas, escolhido);
    return banco_perguntas[escolhido];
};

// Avalia quantidades, energia e grupos de todos os ingredientes escolhidos.
avaliar_prato = function() {
    var m=missoes[indice_missao];
    var total_coletado = array_length(sacola);
    var minimo_exigido = (indice_missao == 8) ? m.quantidade_min : m.quantidade;
    if (total_coletado < minimo_exigido || total_coletado > m.quantidade) {
        var texto_quantidade = (indice_missao == 8) ? "Use de 7 a 8 ingredientes." : "Quantidade exigida: " + string(m.quantidade);
        return {aprovado:false, texto:texto_quantidade};
    }
    if (!m.livre) {
        for (var i=0;i<array_length(m.ingredientes);i++) {
            if (!tem_ingrediente(m.ingredientes[i])) return {aprovado:false,texto:"Falta ingrediente da receita."};
        }
        return {aprovado:true,texto:"Receita guiada completa!"};
    }
    var soma=0;
    var grupos=[];
    var qtd_vegetais=0;
    for (var s=0;s<array_length(sacola);s++) {
        var alimento=buscar_alimento(sacola[s]);
        if (is_undefined(alimento)) return {aprovado:false,texto:"Ingrediente nao cadastrado."};
        soma+=alimento.kcal;
        for (var v=0;v<array_length(alimento.grupos);v++) if(alimento.grupos[v]=="vegetal") qtd_vegetais++;
        for (var g=0;g<array_length(alimento.grupos);g++) {
            var grupo=alimento.grupos[g];
            var existe=false;
            for(var a=0;a<array_length(grupos);a++) if(grupos[a]==grupo) existe=true;
            if (!existe) array_push(grupos,grupo);
        }
    }
    if (indice_missao==8 && qtd_vegetais<2) return {aprovado:false,texto:"O Chef pediu pelo menos dois vegetais."};
    if (soma<m.kcal_min || soma>m.kcal_max) {
        return {aprovado:false,texto:"Energia " + string(soma) + " kcal. Meta: " + string(m.kcal_min) + "-" + string(m.kcal_max) + " kcal."};
    }
    for (var r=0;r<array_length(m.requisitos);r++) {
        var achou=false;
        for (var b=0;b<array_length(grupos);b++) if(grupos[b]==m.requisitos[r]) achou=true;
        if (!achou) return {aprovado:false,texto:"Falta grupo: " + m.requisitos[r] + " ("+string(soma)+" kcal)."};
    }
    return {aprovado:true,texto:"Prato aprovado! Energia: " + string(soma) + " kcal."};
};

// Seleciona ingrediente na estacao; a resposta pode ser obrigatoria ou nao.
iniciar_escolha_ingrediente = function(_indice, _setor) {
    indice_ingrediente_pendente = _indice;
    setor_atual = _setor;
    var m=missoes[indice_missao];
    if (m.nivel=="final") {
        iniciar_minigame_setor(_setor,_indice);
        mensagem="Desafio final: sem perguntas nem dicas!";
    } else {
        var q=sortear_pergunta(m.nivel, _setor);
        if (is_undefined(q)) { mensagem="Nenhuma pergunta cadastrada nesta estacao e nivel."; return; }
        pergunta=q.pergunta;
        opcoes=q.opcoes;
        correta=q.correta;
        pergunta_ativa=true;
        pergunta_bloqueio=2;
    }
};

// Lista ingredientes elegiveis de uma estacao nas fases livres.
abrir_estacao = function(_setor) {
    var m=missoes[indice_missao];
    if (array_length(sacola)>=m.quantidade) {
        mensagem="Sacola cheia! Va a bancada ou remova um ingrediente com R.";
        return;
    }
    if (!m.livre) {
        for(var i=0;i<array_length(m.ingredientes);i++) {
            var f=buscar_alimento(m.ingredientes[i]);
            if (!is_undefined(f) && f.setor==_setor && !tem_ingrediente(f.nome)) {
                iniciar_escolha_ingrediente(i,_setor); return;
            }
        }
        mensagem="Nenhum ingrediente pendente nesta estacao.";
        return;
    }
    selecao_opcoes=[];
    selecao_setor=_setor;
    for(var j=0;j<array_length(banco_ingredientes);j++) {
        var a=banco_ingredientes[j];
        if(a.setor==_setor && !tem_ingrediente(a.nome)) array_push(selecao_opcoes,j);
    }
    if (array_length(selecao_opcoes)==0) {mensagem="Todos os ingredientes desta estacao ja foram usados.";return;}
    selecao_ativa=true;
};
preparo_ativo = false;
etapa_preparo = 0;
mensagem_preparo = "";
// Escala de dificuldade: facil, medio, dificil e desafio final.
// Valores centralizados para facilitar a calibracao com os testes de usuarios.
nivel_minigame = function() {
    if (indice_missao < 3) return 0;
    if (indice_missao < 6) return 1;
    if (indice_missao < 8) return 2;
    return 3;
};
metas_frutas = [10, 13, 16, 20];
velocidades_corte = [2, 3, 4, 5];
velocidades_graos = [0.5, 0.7, 0.9, 1.0];
zonas_graos_inicio = [80, 82, 84, 85];
zonas_graos_fim = [90, 90, 90, 90];
tempos_proteina_seg = [5, 6, 7, 8];
zonas_proteina_inicio = [80, 81, 82, 82];
zonas_proteina_fim = [90, 89, 88, 87];
velocidades_laticinios = [0.65, 0.85, 1.0, 1.1];
zonas_laticinios_inicio = [75, 76, 77, 78];
zonas_laticinios_fim = [85, 83, 82, 82];
metas_bebidas = [10, 14, 18, 22];
metas_montagem = [4, 5, 6, 7];

// CORTE
corte_ativo = false;
corte_posicao = 0;
corte_velocidade = 2;
corte_direcao = 1;
corte_acertos = 0;
corte_erros = 0;
corte_zona_inicio = 40;
corte_zona_fim = 60;
brocolis_preparado = false;
// GRAOS
arroz_ativo = false;
arroz_preparado = false;
arroz_progresso = 0;
arroz_velocidade = 0.5;
arroz_zona_inicio = 80;
arroz_zona_fim = 90;
arroz_tentativas = 0;
// PROTEINAS
frango_ativo = false;
frango_preparado = false;
frango_temperatura = 40;
frango_zona_inicio = 80;
frango_zona_fim = 90;
frango_aquecimento = 0.35;
frango_ajuste = 1.2;
frango_tempo_ideal = 0;
frango_tempo_necessario = 300;
frango_dificuldade = 1;
frango_oscilacao = 0;
// MONTAGEM
montagem_ativa = false;
montagem_concluida = false;
montagem_sequencia = [];
montagem_posicao = 0;
montagem_erros = 0;
montagem_fase = 0;
montagem_tempo_memoria = 3 * room_speed;
montagem_tempo_jogo = 12 * room_speed;
montagem_cronometro = 0;
montagem_tamanho = 4;
mensagem_conclusao = "";
tempo_mensagem_conclusao = 0;
xp_inicio_missao = 0;
xp_ganho_missao = 0;
receita_concluida_nome = "";
classificacao_missao = "";
banco_montagem = [
    [2,2,1,1], [1,2,1,2], [3,4,3,4], [1,1,4,2], [4,2,3,1],
    [2,3,1,4], [3,3,4,1], [4,1,2,3], [2,4,4,1], [1,3,2,4]
];

// Limite de erros por tentativa. Ao esgotar, reinicia o minigame atual,
// sem apagar ingredientes coletados anteriormente. O relogio global continua.
limite_erros_minigame = function() {
    if (indice_missao < 3) return 3; // facil
    if (indice_missao < 6) return 2; // medio
    return 1;                        // dificil / final
};
mini_erros = 0;
mini_reinicios = 0;
frango_fora_frames = 0;
frango_iniciou_aquecimento = false;
mini_registrar_erro = function(_mensagem) {
    mini_erros++;
    if (mini_erros < limite_erros_minigame()) {
        mensagem_preparo = _mensagem + " (" + string(mini_erros) + "/" + string(limite_erros_minigame()) + ")";
        if (!corte_ativo) tocar_som(snd_erro, 0.7); // no corte, o som da faca ja avisa o erro
        return false;
    }
    mini_erros = 0;
    mini_reinicios++;
    tocar_som(snd_reinicio, 0.8);
    // Preserva o tipo de minigame atual, reiniciando so sua contagem.
    if (corte_ativo) {
        corte_acertos = 0; corte_erros = 0; corte_posicao = 0;
        corte_velocidade = velocidades_corte[nivel_minigame()];
    }
    if (arroz_ativo) {
        arroz_progresso = 0; arroz_tentativas = 0;
    }
    if (frango_ativo) {
        frango_temperatura = 40; frango_tempo_ideal = 0;
        frango_fora_frames = 0; frango_iniciou_aquecimento = false;
    }
    if (fruta_ativo) {
        fruta_acertos = 0; fruta_bonus_xp = 0;
        fruta_tempo = 20 * room_speed; fruta_alvo = irandom_range(0,9);
        fruta_aguardando_soltar = true;
    }
    if (leite_ativo) leite_nivel = 0;
    if (bebida_ativo) { bebida_progresso = 0; bebida_ultima_tecla = 0; }
    if (montagem_ativa) {
        montagem_posicao = 0; montagem_erros = 0; montagem_fase = 0;
        montagem_cronometro = montagem_tempo_memoria;
        som_montagem_idx = -1;
    }
    mensagem_preparo = "LIMITE DE ERROS! Contagem reiniciada. " + _mensagem;
    return true;
};

// ==========================================
// INTEGRACAO DOS MINIGAMES NAS ESTACOES
// ==========================================
minigame_ativo = false;
ingrediente_pendente = -1; // posicao do ingrediente na missao
setor_pendente = -1;
fruta_ativo = false;
fruta_alvo = 0;
fruta_tempo = 0;
fruta_aguardando_soltar = false;
fruta_acertos = 0;
fruta_meta = 10;
fruta_bonus_xp = 0;
leite_ativo = false;
leite_nivel = 0;
leite_velocidade = 0.65;
bebida_ativo = false;
bebida_progresso = 0;
bebida_ultima_tecla = 0;
bebida_meta = 10;
leite_zona_inicio = 75;
leite_zona_fim = 85;

// Inicia o desafio da estacao APOS acertar a pergunta.
iniciar_minigame_setor = function(_setor, _posicao) {
    setor_pendente = _setor;
    ingrediente_pendente = _posicao;
    var nivel_atual = nivel_minigame();
    fruta_meta = metas_frutas[nivel_atual];
    corte_velocidade = velocidades_corte[nivel_atual];
    arroz_velocidade = velocidades_graos[nivel_atual];
    arroz_zona_inicio = zonas_graos_inicio[nivel_atual];
    arroz_zona_fim = zonas_graos_fim[nivel_atual];
    frango_tempo_necessario = tempos_proteina_seg[nivel_atual] * room_speed;
    frango_zona_inicio = zonas_proteina_inicio[nivel_atual];
    frango_zona_fim = zonas_proteina_fim[nivel_atual];
    leite_velocidade = velocidades_laticinios[nivel_atual];
    leite_zona_inicio = zonas_laticinios_inicio[nivel_atual];
    leite_zona_fim = zonas_laticinios_fim[nivel_atual];
    bebida_meta = metas_bebidas[nivel_atual];
    mini_erros = 0; frango_fora_frames = 0; frango_iniciou_aquecimento = false;
    minigame_ativo = true;
    preparo_ativo = true; // bloqueia movimento durante o desafio
    corte_ativo = false;
    arroz_ativo = false;
    frango_ativo = false;
    fruta_ativo = false;
    leite_ativo = false;
    bebida_ativo = false;
    switch (_setor) {
        case 0: // Frutas: identificar a tecla indicada
            fruta_ativo = true;
            fruta_aguardando_soltar = true;
            fruta_alvo = irandom_range(0, 9);
            fruta_acertos = 0;
            fruta_bonus_xp = 0;
            fruta_tempo = 20 * room_speed;
            mensagem_preparo = "FRUTAS: acerte " + string(fruta_meta) + " numeros!";
            break;
        case 1: // Verduras: corte
            corte_ativo = true;
            corte_posicao = 0;
            corte_velocidade = velocidades_corte[nivel_atual];
            corte_direcao = 1;
            corte_acertos = 0;
            corte_erros = 0;
            mensagem_preparo = "CORTE: ESPACO na zona verde!";
            break;
        case 2: // Graos: cozimento
            arroz_ativo = true;
            arroz_progresso = 0;
            arroz_tentativas = 0;
            mensagem_preparo = "GRAOS: ESPACO no ponto ideal!";
            break;
        case 3: // Proteinas: temperatura
            frango_ativo = true;
            frango_temperatura = 40;
            frango_tempo_ideal = 0;
            frango_dificuldade = 1;
            mensagem_preparo = "PROTEINAS: controle com CIMA e BAIXO!";
            break;
        case 4: // Laticinios: dosagem
            leite_ativo = true;
            leite_nivel = 0;
            mensagem_preparo = "LATICINIOS: solte entre " + string(leite_zona_inicio) + " e " + string(leite_zona_fim) + "%!";
            break;
        case 5: // Bebidas: mistura
            bebida_ativo = true;
            bebida_progresso = 0;
            bebida_ultima_tecla = 0;
            mensagem_preparo = "BEBIDAS: alterne A e D ate " + string(bebida_meta) + " pontos!";
            break;
    }
};

// Conclui UM ingrediente (nao a missao inteira).
finalizar_ingrediente = function() {
    if (ingrediente_pendente < 0 || !missao_ativa) return;
    var m=missoes[indice_missao];
    var nome="";
    if(m.livre) nome=banco_ingredientes[ingrediente_pendente].nome;
    else nome=m.ingredientes[ingrediente_pendente];
    if(coletar_ingrediente(nome)) {
        tocar_som(snd_coleta, 0.9);
        var adicional=(setor_pendente==0)?fruta_bonus_xp:0;
        ganhar_xp(100+adicional);
        mensagem=nome+" coletado! +"+string(100+adicional)+" XP";
    }
    // A luz verde indica que a estacao participou da missao.
    concluidos[setor_pendente]=true;
    corte_ativo=false; arroz_ativo=false; frango_ativo=false;
    fruta_ativo=false; leite_ativo=false; bebida_ativo=false;
    fruta_bonus_xp=0; minigame_ativo=false; preparo_ativo=false;
    ingrediente_pendente=-1; setor_pendente=-1;
    // cargo atualizado dentro de ganhar_xp()
    if(ingredientes_coletados==m.quantidade || (indice_missao==8 && ingredientes_coletados>=m.quantidade_min)) {
        mensagem_missao=(indice_missao==8 && ingredientes_coletados<m.quantidade) ? "Ja pode finalizar com 7 ou coletar mais 1 ingrediente." : "Sacola completa! Confira o prato na bancada.";
    }
};

// Inicia apenas a montagem na bancada.
iniciar_montagem = function() {
    preparo_ativo = true;
    montagem_ativa = true;
    montagem_concluida = false;
    montagem_fase = 0;
    montagem_posicao = 0;
    montagem_erros = 0; mini_erros = 0;
    som_montagem_idx = -1;
    montagem_cronometro = montagem_tempo_memoria;
    // Sequencia dinamica; a quantidade de setas cresce com o nivel.
    montagem_tamanho = metas_montagem[nivel_minigame()];
    montagem_sequencia = [];
    for (var pos_seta = 0; pos_seta < montagem_tamanho; pos_seta++) {
        array_push(montagem_sequencia, irandom_range(1, 4));
    }
    mensagem_preparo = "Memorize as setas para montar o prato!";
};

// =============================================
// CRONOMETRO GLOBAL DAS 9 MISSOES (segundos)
// =============================================
// 5:00 -> 3:15 (reduz 15s por missao); desafio final retorna a 5:00.
limites_tempo_missoes = [300, 285, 270, 255, 240, 225, 210, 195, 300];
tempo_restante_missao = 0;
tempo_total_missao = 0;
tempo_missao_rodando = false;
falha_missao_visivel = 0;

falhar_missao_tempo = function() {
    tocar_som(snd_missao_falhou, 1);
    tempo_missao_rodando = false;
    tempo_restante_missao = 0;
    missao_ativa = false;
    missao_concluida = false;
    pergunta_ativa = false;
    selecao_ativa = false;
    preparo_ativo = false;
    minigame_ativo = false;
    corte_ativo = false;
    arroz_ativo = false;
    frango_ativo = false;
    fruta_ativo = false;
    leite_ativo = false;
    bebida_ativo = false;
    montagem_ativa = false;
    montagem_concluida = false;
    ingrediente_pendente = -1;
    setor_pendente = -1;
    setor_atual = -1;
    fruta_bonus_xp = 0;
    sacola = [];
    ingredientes_coletados = 0;
    frigorifico_verificado = false;
    fogao_verificado = false;
    for (var f = 0; f < array_length(concluidos); f++) concluidos[f] = false;
    mensagem = "MISSAO FALHOU! TEMPO ESGOTADO! Fale com o Chef para tentar novamente.";
    mensagem_missao = "Tempo esgotado! Reinicie esta receita com o Chef.";
    falha_missao_visivel = 4;
};

// ========================================
// ANIMACOES DO CHEF
// ========================================

chef_sprite = spr_chef_normal;
chef_frame = 0;

// Velocidade dos quadros
chef_vel_anim = 0.04;

// Controle dos comportamentos
chef_estado = 0;
chef_tempo = 0;

// Duracao inicial: 4 segundos
chef_duracao = room_speed *6;


// =====================================================================
// ECONOMIA, PROGRESSAO E LOJA DE SKINS  (Integrante 2)
// Tudo que e numero de balanceamento fica neste bloco.
// =====================================================================

// ---------- CONFIGURACAO ----------
// XP total necessario para cada cargo. O XP por ingrediente (100) e o bonus
// das frutas continuam em finalizar_ingrediente; o bonus da missao vem de m.bonus.
cargos_xp = [
    { xp: 0,    nome: "Estagiario" },
    { xp: 1000, nome: "Assistente de cozinha" },
    { xp: 3000, nome: "Cozinheiro" },
    { xp: 6000, nome: "Chef de cozinha" }
];

// Se false, o XP volta a zero a cada abertura do jogo (so as moedas e a loja persistem).
persistir_xp = true;
// Cada usuario tem o proprio arquivo de save. Sem login (ex.: testando a room direto), usa "convidado".
nome_jogador = (variable_global_exists("usuario") && global.usuario != "") ? global.usuario : "convidado";
arquivo_save = "save_" + nome_jogador + ".json";

// Moedas ganhas ao concluir uma missao, conforme a dificuldade dela.
moedas_da_missao = function(_m) {
    switch (_m.nivel) {
        case "facil":   return 40;
        case "medio":   return 80;
        case "dificil": return 120;
        case "final":   return 250;
    }
    return 40;
};

// Categorias da loja. So "roupa" tem itens por enquanto (as 5 skins + o visual padrao).
categorias_loja = [
    { id: "roupa",     nome: "Roupas"     },
    { id: "chapeu",    nome: "Chapeus"    },
    { id: "oculos",    nome: "Oculos"     },
    { id: "acessorio", nome: "Acessorios" }
];

// Cada item tem uma sprite por direcao (64x64, origem 32,64, 4 frames).
itens_loja = [
    { id: "padrao", nome: "Estagiario (padrao)", cat: "roupa", preco: 0,
      spr: { baixo: spr_player_baixo, cima: spr_player_cima, direita: spr_player_direita, esquerda: spr_player_esquerda } },
    { id: "cozinheiro", nome: "Cozinheiro", cat: "roupa", preco: 100,
      spr: { baixo: spr_skin_cozinheiro_baixo, cima: spr_skin_cozinheiro_cima, direita: spr_skin_cozinheiro_direita, esquerda: spr_skin_cozinheiro_esquerda } },
    { id: "urbano", nome: "Urbano", cat: "roupa", preco: 150,
      spr: { baixo: spr_skin_urbano_baixo, cima: spr_skin_urbano_cima, direita: spr_skin_urbano_direita, esquerda: spr_skin_urbano_esquerda } },
    { id: "oriental", nome: "Oriental", cat: "roupa", preco: 200,
      spr: { baixo: spr_skin_oriental_baixo, cima: spr_skin_oriental_cima, direita: spr_skin_oriental_direita, esquerda: spr_skin_oriental_esquerda } },
    { id: "academico", nome: "Academico", cat: "roupa", preco: 250,
      spr: { baixo: spr_skin_academico_baixo, cima: spr_skin_academico_cima, direita: spr_skin_academico_direita, esquerda: spr_skin_academico_esquerda } },
    { id: "lendario", nome: "Lendario", cat: "roupa", preco: 400,
      spr: { baixo: spr_skin_lendario_baixo, cima: spr_skin_lendario_cima, direita: spr_skin_lendario_direita, esquerda: spr_skin_lendario_esquerda } }

    // Exemplo para quando existirem sprites de chapeu/oculos/acessorio (mesmo formato 64x64,
    // origem 32,64, 4 frames, uma sprite por direcao). Basta descomentar e ajustar:
    // ,{ id: "chapeu_chef", nome: "Chapeu de Chef", cat: "chapeu", preco: 120,
    //   spr: { baixo: spr_chapeu_chef_baixo, cima: spr_chapeu_chef_cima, direita: spr_chapeu_chef_direita, esquerda: spr_chapeu_chef_esquerda } }
];

// ---------- ESTADO E SAVE ----------
moedas_ganhas_missao = 0;
aviso_cargo = "";
aviso_cargo_tempo = 0;
loja_aberta = false;
loja_cat = 0;
loja_sel = 0;
loja_msg = "";

economia_estado_inicial = function() {
    return {
        xp: 0,
        moedas: 0,
        missao: 0,
        comprados: ["padrao"],
        equipado: { roupa: "padrao", chapeu: "", oculos: "", acessorio: "" }
    };
};

carregar_economia = function() {
    var _s = economia_estado_inicial();
    if (!file_exists(arquivo_save)) return _s;
    try {
        var _f = file_text_open_read(arquivo_save);
        var _txt = "";
        while (!file_text_eof(_f)) { _txt += file_text_read_string(_f); file_text_readln(_f); }
        file_text_close(_f);
        var _d = json_parse(_txt);
        if (is_struct(_d)) {
            if (variable_struct_exists(_d, "xp") && is_real(_d.xp)) _s.xp = _d.xp;
            if (variable_struct_exists(_d, "moedas") && is_real(_d.moedas)) _s.moedas = _d.moedas;
            if (variable_struct_exists(_d, "missao") && is_real(_d.missao)) _s.missao = _d.missao;
            if (variable_struct_exists(_d, "comprados") && is_array(_d.comprados)) {
                for (var i = 0; i < array_length(_d.comprados); i++) {
                    if (!array_contains(_s.comprados, _d.comprados[i])) array_push(_s.comprados, _d.comprados[i]);
                }
            }
            if (variable_struct_exists(_d, "equipado") && is_struct(_d.equipado)) {
                var _cats = ["roupa", "chapeu", "oculos", "acessorio"];
                for (var c = 0; c < array_length(_cats); c++) {
                    if (!variable_struct_exists(_d.equipado, _cats[c])) continue;
                    var _v = variable_struct_get(_d.equipado, _cats[c]);
                    // so aceita item que o jogador realmente tem
                    if (is_string(_v) && array_contains(_s.comprados, _v)) variable_struct_set(_s.equipado, _cats[c], _v);
                }
            }
        }
    } catch (_e) {
        // arquivo corrompido: comeca do zero
        _s = economia_estado_inicial();
    }
    return _s;
};

salvar_economia = function() {
    var _d = {
        xp: persistir_xp ? xp : 0,
        moedas: global.save.moedas,
        missao: indice_missao,
        comprados: global.save.comprados,
        equipado: global.save.equipado
    };
    var _f = file_text_open_write(arquivo_save);
    file_text_write_string(_f, json_stringify(_d));
    file_text_close(_f);
};

// ---------- XP E CARGO ----------
nivel_cargo = function(_xp) {
    var _i = 0;
    for (var n = 0; n < array_length(cargos_xp); n++) {
        if (_xp >= cargos_xp[n].xp) _i = n;
    }
    return _i;
};

atualizar_cargo = function() {
    cargo = cargos_xp[nivel_cargo(xp)].nome;
};

// Faixa de XP do cargo atual, usada pela barra de XP do HUD.
xp_faixa = function() {
    var _i = nivel_cargo(xp);
    if (_i >= array_length(cargos_xp) - 1) {
        return { inicio: cargos_xp[_i].xp, meta: cargos_xp[_i].xp, maximo: true };
    }
    return { inicio: cargos_xp[_i].xp, meta: cargos_xp[_i + 1].xp, maximo: false };
};

ganhar_xp = function(_qtd) {
    var _antes = nivel_cargo(xp);
    xp += _qtd;
    atualizar_cargo();
    if (nivel_cargo(xp) > _antes) {
        // troca imediata para o mentor do novo nivel
        chef_sprite = chef_sprite_do_estado(chef_estado);
        chef_frame = 0;
        aviso_cargo = "NOVO CARGO: " + cargo + "!   Mentor: " + chef_atual().nome;
        aviso_cargo_tempo = room_speed * 4;
        tocar_som(snd_cargo, 1);
    }
    salvar_economia();
};

// ---------- MOEDAS ----------
ganhar_moedas = function(_qtd) {
    global.save.moedas += _qtd;
    salvar_economia();
};

gastar_moedas = function(_qtd) {
    if (global.save.moedas < _qtd) return false;
    global.save.moedas -= _qtd;
    salvar_economia();
    return true;
};

// ---------- ITENS: COMPRA, EQUIPAR, DESEQUIPAR ----------
item_buscar = function(_id) {
    for (var i = 0; i < array_length(itens_loja); i++) {
        if (itens_loja[i].id == _id) return itens_loja[i];
    }
    return undefined;
};

itens_da_categoria = function(_cat) {
    var _lista = [];
    for (var i = 0; i < array_length(itens_loja); i++) {
        if (itens_loja[i].cat == _cat) array_push(_lista, itens_loja[i]);
    }
    return _lista;
};

item_comprado = function(_id) {
    return array_contains(global.save.comprados, _id);
};

item_equipado = function(_id) {
    var _it = item_buscar(_id);
    if (_it == undefined) return false;
    return variable_struct_get(global.save.equipado, _it.cat) == _id;
};

item_equipar = function(_id) {
    if (!item_comprado(_id)) return { ok: false, erro: "Compre o item primeiro." };
    var _it = item_buscar(_id);
    // equipa um item por categoria; categorias diferentes ficam equipadas juntas
    variable_struct_set(global.save.equipado, _it.cat, _id);
    salvar_economia();
    return { ok: true, msg: "Equipado!" };
};

item_desequipar = function(_cat) {
    // roupa volta para o visual padrao; as demais categorias ficam vazias
    variable_struct_set(global.save.equipado, _cat, (_cat == "roupa") ? "padrao" : "");
    salvar_economia();
};

item_comprar = function(_id) {
    var _it = item_buscar(_id);
    if (_it == undefined)     return { ok: false, erro: "Item nao existe." };
    if (item_comprado(_id))   return { ok: false, erro: "Voce ja tem este item." };
    if (!gastar_moedas(_it.preco)) return { ok: false, erro: "Moedas insuficientes." };
    array_push(global.save.comprados, _id);
    salvar_economia();
    item_equipar(_id); // ao comprar, ja equipa
    return { ok: true, msg: "Comprado e equipado!" };
};

// Enter na loja: equipa se estiver sem usar, tira se estiver equipado.
item_alternar = function(_id) {
    if (!item_equipado(_id)) return item_equipar(_id);
    var _it = item_buscar(_id);
    if (_id == "padrao") return { ok: false, erro: "Este ja e o visual padrao." };
    item_desequipar(_it.cat);
    return { ok: true, msg: "Removido." };
};

// ---------- DESENHO DO PERSONAGEM COM OS ITENS EQUIPADOS ----------
dir_do_sprite = function(_spr) {
    if (_spr == spr_player_cima) return "cima";
    if (_spr == spr_player_direita) return "direita";
    if (_spr == spr_player_esquerda) return "esquerda";
    return "baixo";
};

// _equip: struct { roupa, chapeu, oculos, acessorio } com os ids equipados.
// A ordem garante: corpo/roupa embaixo e os acessorios por cima.
desenhar_personagem = function(_x, _y, _esc, _dir, _frame, _equip) {
    var _ordem = ["roupa", "oculos", "chapeu", "acessorio"];
    for (var i = 0; i < array_length(_ordem); i++) {
        var _id = variable_struct_get(_equip, _ordem[i]);
        if (_id == "" && _ordem[i] == "roupa") _id = "padrao";
        if (_id == "") continue;
        var _it = item_buscar(_id);
        if (_it == undefined) continue;
        draw_sprite_ext(variable_struct_get(_it.spr, _dir), _frame, _x, _y, _esc, _esc, 0, c_white, 1);
    }
};

// ---------- LOJA: ABRIR E NAVEGAR (chamada todo frame no Step) ----------
economia_step = function() {
    if (aviso_cargo_tempo > 0) aviso_cargo_tempo--;

    if (!loja_aberta) {
        // so abre entre missoes, para nao roubar tempo do cronometro
        if (keyboard_check_pressed(ord("L")) && !missao_ativa && !pergunta_ativa && !preparo_ativo && !selecao_ativa) {
            loja_aberta = true;
            tocar_som(snd_loja_abrir, 0.8);
            loja_cat = 0;
            loja_sel = 0;
            loja_msg = "";
        }
        return;
    }

    if (keyboard_check_pressed(vk_escape) || keyboard_check_pressed(ord("L"))) {
        tocar_som(snd_menu_nav, 0.6);
        loja_aberta = false;
        return;
    }

    var _nc = array_length(categorias_loja);
    if (keyboard_check_pressed(vk_right) || keyboard_check_pressed(ord("D"))) {
        loja_cat = (loja_cat + 1) mod _nc; loja_sel = 0; loja_msg = ""; tocar_som(snd_menu_nav, 0.5);
    }
    if (keyboard_check_pressed(vk_left) || keyboard_check_pressed(ord("A"))) {
        loja_cat = (loja_cat - 1 + _nc) mod _nc; loja_sel = 0; loja_msg = ""; tocar_som(snd_menu_nav, 0.5);
    }

    var _lista = itens_da_categoria(categorias_loja[loja_cat].id);
    var _n = array_length(_lista);
    if (_n == 0) return;

    if (keyboard_check_pressed(vk_down) || keyboard_check_pressed(ord("S"))) { loja_sel = (loja_sel + 1) mod _n; loja_msg = ""; tocar_som(snd_menu_nav, 0.5); }
    if (keyboard_check_pressed(vk_up)   || keyboard_check_pressed(ord("W"))) { loja_sel = (loja_sel - 1 + _n) mod _n; loja_msg = ""; tocar_som(snd_menu_nav, 0.5); }

    if (keyboard_check_pressed(vk_enter) || keyboard_check_pressed(vk_space)) {
        var _it = _lista[loja_sel];
        var _era = item_comprado(_it.id);
        var _r = _era ? item_alternar(_it.id) : item_comprar(_it.id);
        loja_msg = _r.ok ? _r.msg : _r.erro;
        if (!_r.ok) tocar_som(snd_erro, 0.6);
        else if (!_era) tocar_som(snd_moeda, 0.9);   // compra
        else tocar_som(snd_menu_ok, 0.7);            // equipar / remover
    }
};

// ---------- INICIALIZACAO ----------
global.save = carregar_economia();
xp = persistir_xp ? global.save.xp : 0;
atualizar_cargo();
// Retoma da missao salva. Se o jogador ja tinha terminado todas, comeca um novo ciclo (XP, moedas e itens ficam).
indice_missao = global.save.missao;
if (indice_missao < 0 || indice_missao >= array_length(missoes)) indice_missao = 0;


// =====================================================================
// MENTOR POR NIVEL: o chef da cozinha muda conforme o cargo do jogador
// Ordem = nivel do cargo (0 Estagiario, 1 Assistente, 2 Cozinheiro, 3 Chef).
// Para trocar a ordem, basta reordenar os itens da lista.
// =====================================================================
chefs_por_nivel = [
    { nome: "CHEF",    normal: spr_chef_normal,    pensando: spr_chef_pensando,    orientando: spr_chef_orientando,    cruzados: spr_chef_bracos_cruzados },
    { nome: "GENNARO", normal: spr_gennaro_normal, pensando: spr_gennaro_pensando, orientando: spr_gennaro_orientando, cruzados: spr_gennaro_bracos_cruzados },
    { nome: "HIRO",    normal: spr_hiro_normal,    pensando: spr_hiro_pensando,    orientando: spr_hiro_orientando,    cruzados: spr_hiro_bracos_cruzados },
    { nome: "SOFIA",   normal: spr_sofia_normal,   pensando: spr_sofia_pensando,   orientando: spr_sofia_orientando,   cruzados: spr_sofia_bracos_cruzados }
];

chef_atual = function() {
    return chefs_por_nivel[min(nivel_cargo(xp), array_length(chefs_por_nivel) - 1)];
};

// Estados da animacao: 0 normal, 1 pensando, 2 orientando, 3 bracos cruzados
chef_sprite_do_estado = function(_estado) {
    var _c = chef_atual();
    switch (_estado) {
        case 1: return _c.pensando;
        case 2: return _c.orientando;
        case 3: return _c.cruzados;
    }
    return _c.normal;
};

// Ao abrir o jogo, ja comeca com o mentor do nivel salvo
chef_sprite = chef_sprite_do_estado(chef_estado);
