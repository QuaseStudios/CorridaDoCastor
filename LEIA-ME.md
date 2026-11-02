# Corrida do Castor: versão de trabalho em Godot

Conversão do jogo original (Macromedia Director, 2002) para **Godot 4.7**, sem depender do Director nem do Flash.
O nome é provisório. Toda a arte e os sons ainda são os originais, só para comparar.

> **Não publique esta versão.** Ela ainda mostra a marca e o coelho. Antes de lançar, troque tudo que está em `PARA_TROCAR.csv`.

## Como abrir

1. Abra a Godot 4.7, clique em **Importar** e escolha o arquivo `project.godot`.
2. Espere a importação inicial das imagens e aperte **F5** para jogar.
3. Abra esta pasta no VS Code para editar os scripts e as fases. A extensão **godot-tools** ajuda no GDScript.

**Controles:** setas ou A/D/W/S, espaço também pula, Esc abre o menu.

**Atalhos de teste** (só rodando pelo editor): **F1** mostra as caixas de colisão, **F2** vai ao próximo checkpoint, **F3** conclui a fase.

## Onde fica cada coisa

| Pasta | O que tem |
|---|---|
| `arte/<mundo>/<nome>/` | Um visual: os PNGs e a cena `visual.tscn` com as animações |
| `arte/idioma_pt`, `arte/idioma_es`, `arte/intro` | Imagens das telas |
| `sons/<mundo>/`, `sons/comum/` | Sons, procurados primeiro no mundo atual |
| `fases/*.json` | As seis fases: objetos, posições, colisões e checkpoints |
| `dados/catalogo.json` | Liga cada tipo ao comportamento, aos pontos e ao som |
| `dados/textos.json` | Textos dos menus em português e espanhol |
| `scripts/motor/` | Motor: `jogo.gd` (regras), `camera_jogo.gd`, `colisao.gd`, `som.gd`, `visual.gd` |
| `scripts/objetos/` | Comportamentos: `jogador.gd`, `inimigo_caminhante.gd`, `rolante.gd` etc. |
| `scripts/telas/` | Placar, menu, instruções, final, recordes |
| `testes/` | Testes automáticos |

## Como modernizar

### Trocar uma sprite
- **Mesma quantidade de quadros:** substitua os PNGs mantendo os nomes, como `arte/comum/jogador/correndo_001.png`.
- **Outra quantidade:** abra o `visual.tscn` na Godot, selecione o nó e edite os quadros no painel **SpriteFrames**. Mantenha o nome das animações, porque o código chama cada uma pelo nome.
- **Outro tamanho:** ajuste na raiz da cena o `offset` e os metadados `tamanho` e `registro`. O ponto de registro é onde ficam os pés do personagem.

Depois confira as caixas com **F1**. Se a forma do personagem mudou, ajuste `colisoes` no JSON da fase.

### Trocar um vilão
Para o urubu virar outro bicho, por exemplo:
1. Troque a arte em `arte/deserto/buitre/` e `arte/final/buitre/`.
2. Se quiser, mude o som e os pontos de `urubu` em `dados/catalogo.json`.

O comportamento continua igual. Para mudar também o comportamento, aponte `"script"` no catálogo para outro arquivo de `scripts/objetos/`.

### Trocar fundo e temática
- **Fundo:** `arte/<mundo>/fondo/imagem.png`.
- **Cor do céu:** `cor_fundo` no JSON da fase.
- **Cenário:** objetos do tipo `paisagem`, com `z` negativo para o fundo. Quanto menor o `z`, mais devagar o objeto se move.
- **Painel de progresso:** `arte/<mundo>/cartel/` e `arte/<mundo>/marcador_progresso/`.

### Alterar uma fase
Cada objeto ocupa uma linha em `objetos`:

```json
{"tipo": "escorpiao", "x": 3200, "y": 131, "z": 0, "visual": "res://arte/deserto/escorpion/visual.tscn", "colisao": "escorpionInfo", "params": {"velocidade": 5}}
```

`y` cresce para cima. A ordem das fases está em `FASES`, no início de `scripts/motor/jogo.gd`.

### Ajustar o movimento
Os valores ficam em constantes no início de `scripts/objetos/jogador.gd`, como `FORCA_PULO` e `VELOCIDADE_MAXIMA`, em passos de 1/30 de segundo.
Pulos mais realistas podem mudar o alcance, e aí as fases precisam de ajuste. Teste em uma fase antes de mudar o resto.

Para um movimento mais suave, experimente ligar **Physics Interpolation** nas configurações do projeto. Essa opção ainda não foi testada neste jogo.

## O que mudou em relação ao original

- **Animações em Flash:** viraram sequências de PNG.
- **Menus:** agora usam botões da Godot, no lugar dos botões em Flash.
- **Abertura:** foi simplificada para três imagens com som (`tela_intro.gd`).
- **Fonte:** os números do placar usam a fonte padrão da Godot.
- **Tela final:** dura 4 segundos, valor escolhido por não ter sido possível confirmar o tempo original.
- **Velocidade:** 30 passos por segundo, lidos da configuração do projeto original.
- **Código:** a lógica foi reescrita em GDScript, e tipos com o mesmo comportamento foram unidos. Os 60 scripts de objetos viraram 34.

A conversão **ainda não foi comparada lado a lado com o jogo original**, que não pôde ser executado aqui. Sensação de jogo e pequenas diferenças de animação precisam ser avaliadas jogando.

## Testes

Com a Godot no terminal, rode na pasta do projeto:

```
godot --headless res://testes/teste_fluxo.tscn -- --sem-intro
godot --headless res://testes/teste_fases.tscn -- --sem-intro
```

## Direitos

Antes de publicar, confira no documento do seu tio se o código pode ser modificado e vendido, se ele pode autorizar esse uso e se as fases estão cobertas. Se não estiverem, as fases também precisam ser refeitas.
