---
title: Modelo da área de passagem
description: O que a ferramenta de área de passagem calcula, o que não calcula, as aproximações conhecidas e as fontes.
---

# O modelo

A ferramenta de área de passagem calcula **área geométrica**, não vazão. É uma estimativa comparativa para apoiar decisões de acerto, não uma recomendação validada de gicleagem. Acerte por sua conta e risco.

## O que é calculado

A área livre de passagem de combustível (mm²) ao longo do acelerador, a partir de:

- o **perfil da agulha** dentro do furo do difusor (a área anular entre agulha e difusor);
- o **gicle de alta**, modelado como restrição **em série** com a passagem anular. A área efetiva tende ao gicle de alta, mas nunca atinge um teto duro.
- o **gicle de baixa**, modelado como um **piso** constante presente em toda a curva;
- o **venturi**, que define o curso da agulha e, portanto, até onde a curva vai. Não muda o formato do trecho comum.

A curva começa na marcha lenta, com a agulha ancorada no início do cone, e sobe com o acelerador.

## O que NÃO é calculado

- **Vazão.** Transformar área em vazão exige o coeficiente de descarga, a densidade do combustível e a queda de pressão, que estão fora do escopo aqui.
- Efeitos transientes e dinâmicos, o recorte (cutaway) do pistonete do lado do ar, e temperatura.

## Aproximações conhecidas

- A área do **gicle de baixa** é tomada proporcional à numeração; a constante de calibração depende de dados de bancada.
- O **gicle de alta** é aproximado pelo diâmetro nominal.
- O **venturi** é aproximado pelo curso da agulha.
- Outras marcas de carburador (ex.: Keihin) são modeladas a partir do catálogo próprio; a equivalência entre marcas é aproximada.

## Fontes

- Dados do catálogo (agulhas, difusores e gicles Mikuni) do [jetsrus.com](https://www.jetsrus.com/).
