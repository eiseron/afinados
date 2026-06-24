---
title: Modelo do dimensionamento de admissão
description: O que a ferramenta calcula, a fórmula, as aproximações conhecidas e as fontes.
---

# O modelo

A ferramenta dá uma **estimativa geométrica** do diâmetro de venturi que atende à demanda de ar do motor. É uma ferramenta comparativa para apoiar a escolha do carburador, não uma recomendação validada de gicleagem. Faça acerto por sua conta e risco.

## A fórmula

O diâmetro é calculado a partir de uma equação de dimensionamento derivada de Bernoulli:

```
D = K × √(Vt × RPM × VE / (N × 1000 × P_abs))
```

Onde:

- **D** — diâmetro do venturi (mm)
- **Vt** — cilindrada total (cm³)
- **RPM** — rotação do motor
- **VE** — eficiência volumétrica (0,5 a 1,15)
- **N** — *divisor de pulsos*, em função de cilindros, gargantas, corpos e intervalo de explosões (ver abaixo)
- **P_abs** — pressão absoluta (1 + turbo em bar)
- **K** — constante do perfil de aplicação (0,50–0,88, conforme o tipo de motor)

O fator K codifica implicitamente a velocidade-alvo dos gases no venturi. K maior mira velocidade menor, o que dá um carburador menor para o mesmo motor; K menor mira velocidade maior (preparação de competição).

## O divisor de pulsos

Para cada diâmetro comercial o gráfico desenha uma janela de RPM. O limite depende de quantos cilindros alimentam cada venturi:

```
N = max(gargantas, cilindros / concurrent)
concurrent = max(1, 240 / (intervalo × gargantas))
```

O fator `concurrent` cuida da **sobreposição de pulsos** quando vários cilindros compartilham o carburador. Se o intervalo de explosões por garganta é menor que a duração da admissão (~240° do virabrequim), os pulsos se sobrepõem e o pico efetivo de demanda sobe.

Em setups típicos com 1 carb por cilindro, `N = gargantas = carbs × corpos`.

## Velocidade dos gases para a cor

Cada linha comercial é colorida pela **velocidade pico dos gases** na rotação típica do motor:

```
v = Vt × VE × RPM / (10 × N × π × D²)   (m/s)
```

Limites:

- **< 60 m/s**: velocidade baixa — combustível não atomiza bem, o carburador é grande demais pra essa rotação.
- **60–130 m/s**: suficiente — faixa saudável de operação.
- **> 130 m/s**: restringe — o venturi vira gargalo.

## O que NÃO é calculado

- **Vazão** efetivamente medida em banco de fluxo. A fórmula usa hipóteses geométricas e de respiração, não coeficientes de descarga.
- Efeitos transientes (inércia dos gases no coletor, ressonância da admissão).
- Qualidade de atomização do combustível, distribuição da mistura ou AFR.
- Perdas no corpo do carburador fora do venturi (corte da gaveta, geometria da garganta).

## Aproximações conhecidas

- **Duração da admissão** assumida em ~240° do virabrequim. Cames reais variam de 200° a 280°.
- **Sobreposição de pulsos** modelada com escala linear simples — pulsos sobrepostos dividem o carburador proporcionalmente à duração da sobreposição. Motores reais têm ondas de pressão mais complexas.
- **Ordem de explosão** assume firing par (`720° ÷ cilindros`). Motores de firing ímpar (paralela 270°, V8 cross-plane) podem ser aproximados ajustando o intervalo manualmente.
- **VE_min** é derivada de VE_max menos 30 pontos percentuais, uma queda típica ao longo da faixa de rotação. Motores muito preparados seguram VE por mais tempo (queda menor); setups restritivos caem mais.

## Fontes

Os presets de K e as velocidades-alvo vêm de literatura comum de carburação: David Vizard, Graham Bell, e os guias oficiais Dellorto. Os tamanhos reais de carburador usados pra validar o modelo (Honda CG 125, VW Fusca, Ford Maverick V8, Harley-Davidson Evo 1340, entre outros) vêm dos manuais de fábrica e referências de preparação.
