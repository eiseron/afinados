---
title: Usando a interface
description: Um tour guiado pelos controles da ferramenta de dimensionamento de admissão.
---

# Usando a interface

## O gráfico

O gráfico ocupa a área principal. O eixo horizontal é a rotação do motor (RPM); o vertical é o diâmetro do venturi (mm). Cada linha horizontal é um tamanho comercial: 10 mm, 12 mm, 14 mm, …, 60 mm.

Ao longo de cada linha, a **cor muda conforme o RPM**:

- **verde vivo**: ideal nessa rotação, dentro da faixa de trabalho do motor;
- **verde escuro**: velocidade ideal mas o motor normalmente não trabalha aí;
- **azul claro / azul escuro**: velocidade baixa nessa rotação (carb grande demais);
- **amarelo / amarelo escuro**: restringe nessa rotação (carb pequeno demais).

A linha fica **mais grossa** nas rotações ideais e **mais fina** no resto, pra o olho pegar os trechos verdes primeiro.

Uma **legenda** abaixo do gráfico associa cada cor ao seu significado, e mostra o contraste viva-versus-escura junto da etiqueta do "regime de trabalho".

Se os parâmetros são inválidos (por exemplo cilindrada 0), o gráfico é substituído por uma mensagem curta. Corrija o valor pra trazer o gráfico de volta.

## O formulário

O formulário fica do lado do gráfico (barra lateral à esquerda no desktop, abaixo no celular) e tem duas seções.

### Básica

- **Tipo de motor**: moto, carro, ferramenta motorizada, estacionário ou ciclomotor. Define a faixa de RPM que o gráfico usa pra colorir as linhas.
- **Cilindrada (cm³)**: cilindrada total do motor.
- **Número de cilindros**.
- **Número de carburadores**: total de corpos de carburador. Num 4-cilindros com um único Weber, é 1.

### Avançado (recolhido por padrão)

Abra **Avançado** pra ajuste fino:

- **Perfil de aplicação** (fator K): variação original, esportiva ou competição pro tipo de motor escolhido. K maior coloca o venturi ideal num diâmetro menor.
- **Corpos por carburador**: 1 (maioria), 2 (DCOE, IDF, 2E).
- **Defasagem do virabrequim**: graus entre explosões de cilindros consecutivos — ativo só quando cilindros compartilham carburador. Padrão 180° (4 cilindros com firing alternado). Use 360° pra paralela inglesa clássica, 90° pra V8, etc.
- **Pressão de turbo (bar)**: pra blow-through. 0 pra aspirado.
- **Eficiência volumétrica máxima**: slider de 50% a 115%. Diminuir aperta o leque de diâmetros que o gráfico considera; aumentar empurra a borda superior pra cima (mais respiração).

## Barra superior

O nome ("Afinados") leva de volta ao hub de ferramentas. O alternador de tema troca entre claro e escuro; a escolha fica salva.
