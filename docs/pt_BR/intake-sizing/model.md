---
title: Modelo do dimensionamento de admissão
description: O que a ferramenta calcula, a fórmula, as aproximações conhecidas e as fontes.
---

# O modelo

A ferramenta dá uma **estimativa geométrica** de quão bem cada venturi comercial respira pra um motor, calculando a velocidade de pico dos gases no estrangulamento. É uma ferramenta comparativa pra apoiar a escolha do carburador, não uma recomendação validada de gicleagem. Acerte por sua conta e risco.

## A velocidade dos gases é o sinal primário

Para qualquer diâmetro comercial em qualquer RPM, a velocidade de pico é:

```
v = Vt × VE × RPM / (10 × N × π × D²)   (m/s)
```

Onde:

- **v** — velocidade de pico no estrangulamento do venturi (m/s)
- **Vt** — cilindrada total (cm³)
- **VE** — eficiência volumétrica de pico (0,5 a 1,15)
- **RPM** — rotação do motor
- **N** — *divisor de pulso*, função de cilindros, carburadores, corpos e intervalo entre explosões (ver abaixo)
- **D** — diâmetro do venturi (mm)

Dois extremos importam:

- **Muito baixa** → combustível atomiza mal, a distribuição da mistura piora.
- **Muito alta** → o próprio venturi restringe a vazão e o motor não respira em cima.

Cada linha comercial no gráfico é colorida pela velocidade que ela entrega em cada RPM.

## Velocidade-alvo via perfil de aplicação (K)

O **perfil de aplicação** (original, esportivo, competição — uma constante K por opção) codifica qual velocidade de pico a montagem está mirando. Substituindo a clássica fórmula de dimensionamento via Bernoulli na fórmula de velocidade, todas as variáveis do motor se cancelam e sobra uma relação limpa:

```
v_target = 100 × P_abs / (π × K²)   (m/s)
```

Onde **P_abs** = 1 + turbo (bar). Ou seja, K é, na prática, um seletor de velocidade-alvo:

- Moto original (K=0,70): ~65 m/s
- Moto esportiva (K=0,72): ~61 m/s
- Moto competição (K=0,75): ~57 m/s
- Carro original (K=0,60): ~88 m/s
- Carro competição (K=0,70): ~65 m/s

A faixa saudável do gráfico fica centrada na **v_target** com meia-largura fixa de ±30 m/s. Trocar o perfil de aplicação desloca a faixa e re-pinta o gráfico.

## O divisor de pulso

O divisor `N` converte a demanda total do motor na demanda de pico que um venturi vê:

```
N = max(venturis, cilindros / concurrent)
concurrent = max(1, 240 / (intervalo_entre_explosões × venturis))
```

O fator `concurrent` cuida da **sobreposição de pulsos** quando múltiplos cilindros dividem um carburador. Se o intervalo entre explosões por venturi é menor que a duração da admissão (~240° de virabrequim), os pulsos se sobrepõem e a demanda efetiva de pico sobe.

Para setups típicos de 1 carburador por cilindro, `N = venturis = carburadores × corpos`.

## O que NÃO é calculado

- **Vazão** medida em banco de fluxo. A fórmula usa hipóteses geométricas e de respiração, não coeficientes de descarga.
- Efeitos transientes (inércia dos gases no coletor, ressonância da admissão).
- Qualidade da atomização, distribuição da mistura ou AFR.
- Perdas no corpo do carburador fora do venturi (cutaway, formato da garganta).

## Aproximações conhecidas

- **Duração da admissão** assumida em ~240° de virabrequim. Comandos reais variam de 200° a 280°.
- **Sobreposição de pulsos** modelada com escala linear simples — pulsos sobrepostos dividem o carburador proporcionalmente à sobreposição. Motores reais têm ondas de pressão mais complexas.
- **Intervalo entre explosões** é um campo manual, com padrão de **180°** (explosão uniforme de um 4 cilindros). Ele não deriva do número de cilindros: para outras contagens de cilindros ou motores de explosão desigual (twins 270°, V8 cross-plane), ajuste o intervalo manualmente.
- **VE** é o valor de *pico* (slider único). O gráfico avalia velocidade neste pico; motores reais veem VE menor fora da rotação de pico.

## Fontes

Os presets de K vêm da literatura comum de carburação: David Vizard, Graham Bell, guias oficiais da Dellorto. Tamanhos reais de carburador usados pra validar o modelo (Honda CG 125, VW Fusca, Ford Maverick V8, Harley-Davidson Evo 1340, entre outros) vêm de manuais de serviço dos fabricantes e referências de competição.
