---
title: Modelo da área de passagem
nav_title: O modelo
description: O que a ferramenta de área de passagem calcula, o que não calcula, as aproximações conhecidas e as fontes.
---

# O modelo

A ferramenta de área de passagem calcula **área geométrica**, não vazão. É uma estimativa comparativa para apoiar decisões de acerto, não uma recomendação validada de gicleagem. Acerte por sua conta e risco.

## O que é calculado

A área livre de passagem de combustível (mm²) ao longo do acelerador, como **soma** de duas contribuições paralelas:

- o circuito **principal**: a passagem anular entre agulha e difusor **em série** com o gicle de alta. A área efetiva tende ao gicle de alta, mas nunca atinge um teto duro;
- o circuito do **gicle de baixa**, somado em paralelo como uma contribuição constante presente em toda a curva.

O **venturi** define o curso da agulha e, portanto, até onde a curva vai. Não muda o formato do trecho comum.

A curva começa na marcha lenta — já com a contribuição do circuito principal no ponto de idle somada à do gicle de baixa — e sobe com o acelerador conforme a agulha levanta e a área anular abre.

O catálogo cobre Mikuni e Keihin (FCR 28-41mm, PWK/PJ 34-39mm). Cópias drop-in como NIBBI, KOSO e OKO compartilham as mesmas dimensões dos originais, então o mesmo catálogo se aplica a elas.

## O que NÃO é calculado

- **Vazão.** Transformar área em vazão exige o coeficiente de descarga, a densidade do combustível e a queda de pressão, que estão fora do escopo aqui.
- Efeitos transientes e dinâmicos, o recorte (cutaway) do pistonete do lado do ar, e temperatura.

## Aproximações conhecidas

- A área do **gicle de baixa** Keihin é derivada do diâmetro nominal (numeração em centésimos de mm). A do Mikuni é tomada proporcional à numeração como placeholder; a constante de calibração depende de dados de bancada.
- O **gicle de alta** é aproximado pelo diâmetro nominal (idem para Mikuni round-head e Keihin).
- O **venturi** é aproximado pelo curso da agulha.
- Cada fabricante é modelado a partir do seu próprio catálogo; a equivalência de numeração entre marcas é aproximada.

## Fontes

- Dados do catálogo (agulhas e difusores Mikuni e Keihin) do [jetsrus.com](https://www.jetsrus.com/).
- Geometria das agulhas Keihin FCR/PWK dos PDFs oficiais Keihin (keihin-na.com).
