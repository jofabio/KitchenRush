/// KITCHENRUSH | CREATE | INTERFACE V3
/// A jogabilidade continua em coordenadas logicas 960 x 640.
/// Apenas o desenho foi expandido para um palco visual 1280 x 720.
/// Se houver outros objetos Draw GUI, reveja a ordem de desenho entre eles.

// Maximiza a GUI para cobrir TODA a janela (inclusive faixas pretas).
// O fator garante que as coordenadas virtuais sejam sempre 1280 x 720.

/// INICIALIZA O SORTEIO ALEATORIO
randomize();

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
        return false;
    }
    mini_erros = 0;
    mini_reinicios++;
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
        var adicional=(setor_pendente==0)?fruta_bonus_xp:0;
        xp+=100+adicional;
        mensagem=nome+" coletado! +"+string(100+adicional)+" XP";
    }
    // A luz verde indica que a estacao participou da missao.
    concluidos[setor_pendente]=true;
    corte_ativo=false; arroz_ativo=false; frango_ativo=false;
    fruta_ativo=false; leite_ativo=false; bebida_ativo=false;
    fruta_bonus_xp=0; minigame_ativo=false; preparo_ativo=false;
    ingrediente_pendente=-1; setor_pendente=-1;
    if (xp>=500) cargo="Chef de cozinha";
    else if (xp>=250) cargo="Cozinheiro";
    else if (xp>=100) cargo="Assistente de cozinha";
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

