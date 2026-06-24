---
title: Dimensionamento de admissão
description: O que a ferramenta faz, os conceitos principais e como usar.
---

# Dimensionamento de admissão

Esta ferramenta estima o **tamanho ideal do venturi do carburador ou da borboleta de injeção** para um motor e mostra como os tamanhos comerciais se encaixam na faixa de RPM em que o motor trabalha. Ela traça o diâmetro da garganta em função da rotação e colore cada diâmetro comercial conforme a velocidade dos gases que ele entregaria no RPM típico do motor. Funciona pra carburação e injeção — o campo **Sistema de admissão** no avançado diz ao modelo qual dos dois você está dimensionando.

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
- Kart: 9.000–14.500 rpm
- Jet ski: 5.000–9.000 rpm
- Motor de popa: 3.000–6.500 rpm
- Motosserra: 6.000–13.000 rpm
- Motor estacionário (gerador, bomba): 2.900–3.700 rpm
- Carro: 1.500–6.500 rpm

### O slider

Um slider de **eficiência volumétrica máxima** fica na seção avançada. É a VE de pico que o motor atinge sob carga (rua típico: ~85–95%; preparação leve: ~95–105%; competição com admissão/escape ressonantes: ~105–115%). O gráfico calcula a velocidade dos gases de cada venturi comercial nesse pico de VE. Subir o slider aumenta a velocidade que cada carburador vê em cada RPM, empurrando as cores pro lado restritivo (amarelo) e afastando do anêmico (azul).

## Como usar

1. Escolha o **tipo de motor** (moto, carro, etc.). Isso define a faixa de RPM usada pra colorir o gráfico.
2. Escolha o **sistema de admissão**: *Carburador* (padrão) ou *Injeção Eletrônica*. Carburador precisa de velocidade do ar pra atomizar combustível no venturi via Bernoulli, então a faixa saudável tem piso significativo (~alvo − 30 m/s). Injeção (TBI, MPFI, corpos individuais) injeta combustível depois da borboleta, então atomização não depende da velocidade na garganta e o piso cai (~alvo − 40 m/s). Teto de restrição fica igual — o limite físico de vazão não muda.
3. Informe **cilindrada (cm³)**, **número de cilindros** e **número de carburadores**.
4. Leia o gráfico: procure os tamanhos cujas linhas estão **verde vivo e grossas** dentro do seu RPM típico. Esses são os venturis que respiram bem na faixa de trabalho do motor.
5. Abra **Avançado** pra ajustar:
   - **Perfil de aplicação**: K original, esportivo ou competição pra esse tipo de motor.
   - **Corpos por carburador**: 1 para motos típicas, 2 para Weber DCOE/IDF, 4 para Quadrajet/Holley 4-corpos.
   - **Coletor de admissão**: *Dedicado* (par DCOE, CB400 four, IDA em V8) — cada carb alimenta um subgrupo dedicado de cilindros. *Compartilhado* (Weber single num 4cyl, Quadrajet, Holley single) — todos os carbs descarregam num coletor comum; mais carbs reduzem a velocidade de pico por carb linearmente.
   - **Defasagem do virabrequim**: graus entre explosões de cilindros consecutivos. Ativo só quando cilindros compartilham carburador. Considera a sobreposição de pulsos quando vários cilindros alimentam o mesmo venturi.
   - **Pressão de turbo (bar)**: para setups blow-through.
   - **Combustível**: Gasolina (padrão), Etanol, Metanol, Nitrometano ou GNV. Em modo injeção aparece uma sexta opção, **Flex** (~+3%, mistura típica brasileira gasolina-etanol). Álcoois evaporam endotermicamente e esfriam a carga de admissão, aumentando a VE efetiva (~+5% etanol, ~+10% metanol, ~+30% nitrometano). GNV chega gasoso no coletor, então não esfria a carga — em vez disso, desloca um pouco do ar da admissão (fator ~0.95). O gráfico escala a velocidade dos gases por esses fatores.
   - **Eficiência volumétrica máxima**: vai de 50% (motor cansado, restritivo) a 115% (competição com admissão/escape ressonantes).

## Lendo os resultados

Algumas regras práticas pra interpretar o gráfico:

- **Escolha o tamanho que fica verde em todo o seu RPM típico.** Se vários servem, o menor costuma dar resposta de acelerador melhor, o maior costuma dar mais potência de pico.
- **Se nenhum tamanho fica verde inteiro**, decida qual compromisso aceita. Linha verde em cima e amarela embaixo é uma escolha "de cima" — faz potência mas fica preguiçosa na saída. Linha verde embaixo e azul em cima é uma escolha "dócil" — crisp em baixa mas perde fôlego em cima.
- **Amarelo dentro da sua faixa = pequeno demais.** Esse venturi vai gargalar nos RPMs em que você usa o motor.
- **Azul dentro da sua faixa = grande demais.** Esse venturi atomiza mal e o motor vai sentir fraco/afogado.
- **Cores escuras estão fora da faixa de trabalho** — servem de contexto, mas não decida o venturi por elas.

Ajuste o **Perfil de aplicação** e a **Eficiência volumétrica máxima** ao estado do motor: cabeçote original, gasolina comum → deixe os padrões; cabeçote preparado, comando grande, escape de competição → suba os dois. O gráfico se ajusta.
