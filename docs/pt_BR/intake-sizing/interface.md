---
title: Usando a interface
description: Um tour guiado pelos controles da ferramenta de dimensionamento de admissão.
---

# Usando a interface

## O gráfico

O gráfico ocupa a área principal. O eixo horizontal é a rotação do motor (RPM); o vertical é o diâmetro do venturi (mm). Cada linha horizontal é um tamanho comercial: 10 mm, 12 mm, 14 mm, …, 60 mm.

Ao longo de cada linha, a **cor muda conforme o RPM**:

- **verde vivo / verde escuro**: ideal — velocidade fica dentro da faixa saudável com folga das duas bordas (escuro = fora da faixa de trabalho);
- **ciano / ciano escuro** (só carburador): *aceitável* — velocidade está logo acima do anêmico e abaixo de ~60 m/s, a fronteira clássica pra sinal de carburador firme. Injeção não tem ciano porque atomização vem do bico (escuro = fora da faixa de trabalho);
- **azul claro / azul escuro**: velocidade baixa nessa rotação (carburador grande demais);
- **amarelo / amarelo escuro**: restringe nessa rotação (carburador pequeno demais).

A linha fica **mais grossa** nas rotações ideais e **mais fina** no resto, pra o olho pegar os trechos verdes primeiro.

Uma **legenda** abaixo do gráfico associa cada cor ao seu significado, e mostra o contraste viva-versus-escura junto da etiqueta do "regime de trabalho".

Se os parâmetros são inválidos (por exemplo cilindrada 0), o gráfico é substituído por uma mensagem curta. Corrija o valor pra trazer o gráfico de volta.

## O formulário

O formulário fica do lado do gráfico (barra lateral à esquerda no desktop, abaixo no celular) e tem duas seções.

### Básica

- **Tipo de motor**: moto, carro, kart, jet ski, motor de popa, motosserra, estacionário ou ciclomotor. Define o contexto amplo de RPM que o gráfico usa pra colorir as linhas.
- **Aplicação**: como o motor vai ser usado de verdade, não o estilo do veículo. Uma CG é *urbana*, não "naked"; uma Harley é *cruiser* (rodovia, otimizada pra torque); uma R1 é *esportiva* na rua e *pista* num circuito. A maioria das opções é compartilhada entre moto e carro; algumas são específicas (cruiser, hard enduro e motocross só em moto; rodovia só em carro — mesmo conceito do cruiser, label diferente por convenção). Fica desabilitado (não some) quando o tipo tem uma única aplicação canônica (ex.: estacionário → síncrono).
- **Sistema de admissão**: carburador ou injeção eletrônica. Ajusta a tolerância de velocidade e os rótulos dos campos relacionados.
- **Cilindrada (cm³)**: cilindrada total do motor.
- **Número de cilindros**.
- **Número de carburadores / corpos de borboleta**: total de corpos. Num 4-cilindros com um único Weber, é 1.

### Avançado (recolhido por padrão)

Abra **Avançado** pra ajuste fino:

- **Perfil de aplicação** (fator K): variação original, esportiva ou competição pro tipo de motor escolhido. K maior coloca o venturi ideal num diâmetro menor.
- **Corpos por carburador**: 1 (maioria), 2 (DCOE, IDF, 2E).
- **Defasagem do virabrequim**: graus entre explosões de cilindros consecutivos — ativo só quando cilindros compartilham carburador. Padrão 180° (4 cilindros com firing alternado). Use 360° pra paralela inglesa clássica, 90° pra V8, etc.
- **Pressão de turbo (bar)**: pra blow-through. 0 pra aspirado.
- **Eficiência volumétrica máxima**: slider de 50% a 115%. Diminuir aperta o leque de diâmetros que o gráfico considera; aumentar empurra a borda superior pra cima (mais respiração).

## Barra superior

O nome ("Afinados") leva de volta ao hub de ferramentas. O alternador de tema troca entre claro e escuro; a escolha fica salva.
