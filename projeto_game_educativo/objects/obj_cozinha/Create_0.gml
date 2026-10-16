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
// Centros das seis estacoes, em duas fileiras.
est_x = [130, 270, 410, 550, 690, 830];
est_y = [200, 200, 200, 200, 200, 200];


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



// MISSOES E INVENTARIO
sacola = [];
ingredientes_coletados = 0;
indice_missao = 0;
missao_ativa = false;
missao_concluida = false;
jogo_concluido = false;
indice_pergunta = 0;
mensagem_missao = "Fale com o Chef para iniciar a missao.";

missoes = [
    {
        nome: "Refeicao equilibrada",
        ingredientes: ["Arroz", "Frango", "Brocolis"],
        setores: [2, 3, 1],
        bonus: 150,
        dica: "Proteina + Grao + Verdura"
    },
    {
        nome: "Cafe da manha nutritivo",
        ingredientes: ["Banana", "Leite", "Aveia"],
        setores: [0, 4, 2],
        bonus: 200,
        dica: "Fruta + Laticinio + Cereal"
    },
    {
        nome: "Almoco saudavel",
        ingredientes: ["Peixe", "Batata", "Cenoura"],
        setores: [3, 1, 1],
        bonus: 250,
        dica: "Proteina + Tuberculo + Legume"
    },
    {
        nome: "Lanche energetico",
        ingredientes: ["Morango", "Iogurte", "Aveia"],
        setores: [0, 4, 2],
        bonus: 300,
        dica: "Fruta + Laticinio + Cereal"
    },
    {
        nome: "Prato do Chef",
        ingredientes: ["Frango", "Arroz", "Cenoura"],
        setores: [3, 2, 1],
        bonus: 400,
        dica: "Proteina + Grao + Legume"
    },
    {
        nome: "Cafe tropical",
        ingredientes: ["Manga", "Iogurte", "Suco de laranja"],
        setores: [0, 4, 5],
        bonus: 450,
        dica: "Fruta + Laticinio + Bebida"
    },
    {
        nome: "Almoco colorido",
        ingredientes: ["Peixe", "Brocolis", "Arroz integral"],
        setores: [3, 1, 2],
        bonus: 500,
        dica: "Proteina + Verdura + Grao integral"
    },
    {
        nome: "Desafio final do Chef",
        ingredientes: ["Frango grelhado", "Batata-doce", "Vitamina de banana"],
        setores: [3, 1, 5],
        bonus: 600,
        dica: "Proteina + Tuberculo + Bebida"
    }
];
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
perguntas_missao = [
    { pergunta:"Qual nutriente e mais associado ao arroz?", opcoes:["Carboidratos","Proteinas","Vitamina B12"], correta:0 },
    { pergunta:"Qual nutriente o frango fornece em boa quantidade?", opcoes:["Acucar","Proteinas","Fibra alimentar"], correta:1 },
    { pergunta:"O brocolis e uma fonte de:", opcoes:["Gordura trans","Alcool","Fibras e vitaminas"], correta:2 },
    { pergunta:"A banana e conhecida por fornecer:", opcoes:["Potassio","Colesterol","Alcool"], correta:0 },
    { pergunta:"O leite e uma fonte importante de:", opcoes:["Cafeina","Calcio","Gordura trans"], correta:1 },
    { pergunta:"A aveia e rica em:", opcoes:["Sodio","Colesterol","Fibras"], correta:2 },
    { pergunta:"O peixe pode fornecer:", opcoes:["Proteinas","Acucar refinado","Gordura trans"], correta:0 },
    { pergunta:"A batata fornece principalmente:", opcoes:["Vitamina B12","Carboidratos","Alcool"], correta:1 },
    { pergunta:"A cenoura e conhecida por conter:", opcoes:["Cafeina","Colesterol","Betacaroteno"], correta:2 },

    // =====================================
    // MISSAO 4 - LANCHE ENERGETICO
    // =====================================
    
    // MORANGO
    {
        pergunta: "Qual beneficio o consumo de morango pode oferecer?",
        opcoes: [
            "Aumentar o colesterol",
            "Fornecer antioxidantes",
            "Substituir todas as refeicoes"
        ],
        correta: 1
    },
    
    // IOGURTE
    {
        pergunta: "O iogurte natural pode fornecer:",
        opcoes: [
            "Calcio e proteinas",
            "Alcool",
            "Gordura trans obrigatoriamente"
        ],
        correta: 0
    },
    
    // AVEIA
    {
        pergunta: "A aveia contribui para a alimentacao por conter:",
        opcoes: [
            "Cafeina",
            "Colesterol",
            "Fibras alimentares"
        ],
        correta: 2
    },
    
    // =====================================
    // MISSAO 5 - PRATO DO CHEF
    // =====================================
    
    // FRANGO
    {
        pergunta: "O frango e uma boa fonte de:",
        opcoes: [
            "Acucar refinado",
            "Proteinas",
            "Alcool"
        ],
        correta: 1
    },
    
    // ARROZ
    {
        pergunta: "O arroz fornece principalmente:",
        opcoes: [
            "Carboidratos",
            "Vitamina B12",
            "Colesterol"
        ],
        correta: 0
    },
    
    // CENOURA
    {
        pergunta: "O betacaroteno presente na cenoura pode ser convertido em:",
        opcoes: [
            "Cafeina",
            "Vitamina C",
            "Vitamina A"
        ],
        correta: 2
    },

    // MISSAO 6 - CAFE TROPICAL
    {
        pergunta: "Qual vitamina a manga pode fornecer por conter betacaroteno?",
        opcoes: ["Vitamina A", "Vitamina B12", "Vitamina D"],
        correta: 0
    },
    {
        pergunta: "Qual ingrediente transforma leite em iogurte por fermentacao?",
        opcoes: ["Acucar refinado", "Culturas de bacterias", "Sal de cozinha"],
        correta: 1
    },
    {
        pergunta: "Qual escolha conserva mais fibras da laranja?",
        opcoes: ["Suco coado", "Refrigerante de laranja", "Comer a fruta inteira"],
        correta: 2
    },

    // MISSAO 7 - ALMOCO COLORIDO
    {
        pergunta: "Qual cuidado ajuda a preparar peixe com seguranca?",
        opcoes: ["Deixar horas ao sol", "Cozinhar adequadamente", "Guardar fora da geladeira"],
        correta: 1
    },
    {
        pergunta: "Qual preparo ajuda a preservar nutrientes do brocolis?",
        opcoes: ["Cozimento rapido no vapor", "Ferver por varias horas", "Fritar ate queimar"],
        correta: 0
    },
    {
        pergunta: "Por que o arroz integral costuma ter mais fibras que o branco?",
        opcoes: ["Recebe mais acucar", "Contem mais sal", "Preserva parte do farelo"],
        correta: 2
    },

    // MISSAO 8 - DESAFIO FINAL DO CHEF
    {
        pergunta: "Qual pratica reduz o risco de contaminacao ao preparar frango?",
        opcoes: ["Usar a mesma tabua para salada", "Cozinhar bem e higienizar utensilios", "Deixar cru em temperatura ambiente"],
        correta: 1
    },
    {
        pergunta: "A batata-doce fornece energia principalmente por meio de:",
        opcoes: ["Carboidratos", "Alcool", "Cafeina"],
        correta: 0
    },
    {
        pergunta: "Como preparar uma vitamina de banana com menos acucar adicionado?",
        opcoes: ["Adicionar refrigerante", "Adicionar calda doce", "Usar banana madura sem acucar extra"],
        correta: 2
    }
];
preparo_ativo = false;
etapa_preparo = 0;
mensagem_preparo = "";
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

// Inicia o desafio da estacao APOS acertar a pergunta.
iniciar_minigame_setor = function(_setor, _posicao) {
    setor_pendente = _setor;
    ingrediente_pendente = _posicao;
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
            mensagem_preparo = "FRUTAS: pressione o numero indicado!";
            break;
        case 1: // Verduras: corte
            corte_ativo = true;
            corte_posicao = 0;
            corte_velocidade = 2;
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
            mensagem_preparo = "LATICINIOS: segure ESPACO e solte entre 75 e 85%!";
            break;
        case 5: // Bebidas: mistura
            bebida_ativo = true;
            bebida_progresso = 0;
            bebida_ultima_tecla = 0;
            mensagem_preparo = "BEBIDAS: alterne A e D ate 10 pontos!";
            break;
    }
};

// Conclui UM ingrediente (nao a missao inteira).
finalizar_ingrediente = function() {
    if (ingrediente_pendente < 0 || !missao_ativa) return;
    var m = missoes[indice_missao];
    var nome = m.ingredientes[ingrediente_pendente];
    if (coletar_ingrediente(nome)) {
        var bonus_recebido = 0;
        if (setor_pendente == 0) bonus_recebido = fruta_bonus_xp;
        xp += 100 + bonus_recebido;
        mensagem = nome + " preparado e coletado! +" + string(100 + bonus_recebido) + " XP!";
    }
    // Uma estacao so fica verde quando nao ha mais ingrediente pendente nela.
    var falta_nesta_estacao = false;
    for (var t = 0; t < array_length(m.ingredientes); t++) {
        if (m.setores[t] == setor_pendente && !tem_ingrediente(m.ingredientes[t])) {
            falta_nesta_estacao = true;
        }
    }
    concluidos[setor_pendente] = !falta_nesta_estacao;
    corte_ativo = false;
    arroz_ativo = false;
    frango_ativo = false;
    fruta_ativo = false;
    fruta_bonus_xp = 0;
    leite_ativo = false;
    bebida_ativo = false;
    minigame_ativo = false;
    preparo_ativo = false;
    ingrediente_pendente = -1;
    setor_pendente = -1;
    if (xp >= 500) cargo = "Chef de cozinha";
    else if (xp >= 250) cargo = "Cozinheiro";
    else if (xp >= 100) cargo = "Assistente de cozinha";
    if (ingredientes_coletados == array_length(m.ingredientes)) {
        mensagem_missao = "Tudo pronto! Va a bancada montar o prato!";
    }
};

// Inicia apenas a montagem na bancada.
iniciar_montagem = function() {
    preparo_ativo = true;
    montagem_ativa = true;
    montagem_concluida = false;
    montagem_fase = 0;
    montagem_posicao = 0;
    montagem_erros = 0;
    montagem_cronometro = montagem_tempo_memoria;
    var sorteio = irandom(array_length(banco_montagem) - 1);
    montagem_sequencia = banco_montagem[sorteio];
    montagem_tamanho = array_length(montagem_sequencia);
    mensagem_preparo = "Memorize as setas para montar o prato!";
};

// =============================================
// CRONOMETRO GLOBAL DAS 8 MISSOES (segundos)
// =============================================
limites_tempo_missoes = [200, 180, 160, 140, 120, 110, 100, 90];
tempo_restante_missao = 0;
tempo_total_missao = 0;
tempo_missao_rodando = false;
falha_missao_visivel = 0;

falhar_missao_tempo = function() {
    tempo_missao_rodando = false;
    tempo_restante_missao = 0;
    missao_ativa = false;
    missao_concluida = false;
    pergunta_ativa = false;
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

