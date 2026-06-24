---
title: Dimensionamento de admissão
description: O que a ferramenta faz, os conceitos principais e como usar.
---

# Dimensionamento de admissão

Esta ferramenta estima o **tamanho ideal de venturi** do carburador para um motor e mostra como os tamanhos comerciais se encaixam na faixa de RPM em que o motor trabalha. Ela traça o diâmetro do venturi em função da rotação e colore cada diâmetro comercial conforme a velocidade dos gases que ele entregaria no RPM típico do motor.

Veja [Usando a interface](interface.md) para um tour pelos controles, e [O modelo](model.md) para a fórmula e as aproximações conhecidas.

## Como funciona a admissão no carburador

Um motor ciclo Otto é uma bomba de vácuo. A cada admissão ele puxa ar pelo carburador; o carburador estreita o caminho do ar no **venturi**, e o ar acelera ali. Ar mais rápido cai a pressão (princípio de Bernoulli), e essa baixa pressão é o que suga o combustível dos gicleurs. Então dimensionar venturi é, no fundo, escolher **qual velocidade dos gases** você quer no RPM de trabalho do motor.

Dois extremos a evitar:

- **Venturi pequeno demais.** O ar chega a velocidade muito alta, a queda de pressão fica enorme e o próprio venturi **restringe a vazão**. O motor respira por um canudo — a potência de cima morre.
- **Venturi grande demais.** O ar mal acelera, a queda de pressão fica fraca e o combustível **atomiza mal**. A resposta de acelerador fica preguiçosa, o motor afoga em baixa e média, e a mistura nunca fica homogênea.

Entre os dois existe uma faixa saudável (aproximadamente **60–130 m/s** de velocidade de pico) onde a atomização é boa e a restrição é baixa. O gráfico existe pra te mostrar, pra cada tamanho comercial e pra cada RPM, onde você cai nessa faixa.

A demanda de ar escala com **cilindrada × RPM × eficiência volumétrica** e diminui conforme **quantos cilindros dividem cada carburador**. Por isso o venturi "ideal" de um motor é errado pra outro, e o mesmo venturi pode ser ideal num RPM e restritivo em outro.

## Conceitos principais

### O gráfico

Cada linha horizontal no gráfico é um tamanho de venturi comercial (em mm). A cor da linha ao longo do eixo X (RPM) diz como aquele venturi se comporta naquela rotação:

- **verde**: ideal — velocidade dos gases na faixa saudável (60–130 m/s);
- **azul claro**: velocidade baixa (carb grande demais pra essa rotação, combustível não atomiza bem);
- **amarelo**: restringe (carb pequeno demais pra essa rotação, vira gargalo).

A linha fica **mais grossa** nas rotações onde o venturi é ideal e **mais fina** no resto.

### Regime de trabalho do motor

As mesmas cores aparecem em duas tonalidades. As vivas (verde vivo, azul claro, amarelo) cobrem a faixa de RPM onde o motor realmente trabalha — sua faixa típica de operação. As escuras (verde escuro, azul escuro, amarelo escuro) cobrem RPMs fora dessa faixa, pra você ainda ver a tendência mas sem dar o mesmo peso.

A faixa de RPM depende do tipo de motor escolhido:

- Moto: 2.500–14.000 rpm
- Ciclomotor: 3.000–10.000 rpm
- Ferramenta motorizada (motosserra, roçadeira): 6.000–13.000 rpm
- Motor estacionário (gerador, bomba): 2.900–3.700 rpm
- Carro: 1.500–6.500 rpm

### O slider

Um slider de **eficiência volumétrica máxima** fica na seção avançada. É a VE de pico que o motor atinge sob carga (rua típico: ~85–95%; preparação leve: ~95–105%; competição com admissão/escape ressonantes: ~105–115%). O gráfico calcula a velocidade dos gases de cada venturi comercial nesse pico de VE. Subir o slider aumenta a velocidade que cada carburador vê em cada RPM, empurrando as cores pro lado restritivo (amarelo) e afastando do anêmico (azul).

## Como usar

1. Escolha o **tipo de motor** (moto, carro, etc.). Isso define a faixa de RPM usada pra colorir o gráfico.
2. Informe **cilindrada (cm³)**, **número de cilindros** e **número de carburadores**.
3. Leia o gráfico: procure os tamanhos de venturi cujas linhas estão **verde vivo e grossas** dentro do seu RPM típico. Esses são os venturis que respiram bem na faixa de trabalho do motor.
4. Abra **Avançado** pra ajustar:
   - **Perfil de aplicação**: K original, esportivo ou competição pra esse tipo de motor.
   - **Corpos por carburador**: 1 para motos típicas, 2 para Weber DCOE/IDF, 4 para Quadrajet/Holley 4-corpos.
   - **Intervalo entre explosões (graus do virabrequim)**: só aparece quando cilindros compartilham carburador. Considera a sobreposição de pulsos quando vários cilindros alimentam o mesmo venturi.
   - **Pressão de turbo (bar)**: para setups blow-through.
   - **Eficiência volumétrica máxima**: vai de 50% (motor cansado, restritivo) a 115% (race com admissão/escape ressonantes).

## Lendo os resultados

Algumas regras práticas pra interpretar o gráfico:

- **Escolha o tamanho que fica verde em todo o seu RPM típico.** Se vários servem, o menor costuma dar resposta de acelerador melhor, o maior costuma dar mais potência de pico.
- **Se nenhum tamanho fica verde inteiro**, decida qual compromisso aceita. Linha verde em cima e amarela embaixo é uma escolha "de cima" — faz potência mas fica preguiçosa na saída. Linha verde embaixo e azul em cima é uma escolha "dócil" — crisp em baixa mas perde fôlego em cima.
- **Amarelo dentro da sua faixa = pequeno demais.** Esse venturi vai gargalar nos RPMs em que você usa o motor.
- **Azul dentro da sua faixa = grande demais.** Esse venturi atomiza mal e o motor vai sentir fraco/afogado.
- **Cores escuras estão fora da faixa de trabalho** — servem de contexto, mas não decida o venturi por elas.

Ajuste o **Perfil de aplicação** e a **Eficiência volumétrica máxima** ao estado do motor: cabeçote original, gasolina comum → deixe os padrões; cabeçote preparado, comando grande, escape de competição → suba os dois. O gráfico se ajusta.
