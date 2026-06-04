---
title: Área de passagem de combustível
description: O que a ferramenta de área de passagem faz, os conceitos principais e como usá-la.
---

# Área de passagem de combustível

Esta ferramenta estima a **área de passagem de combustível** de um carburador, a seção disponível para o combustível passar, ao longo da posição do acelerador. Mais área significa que mais combustível pode passar; comparar acertos mostra como uma mudança (agulha, clip, gicles, venturi) remodela a curva.

Veja [Usando a interface](interface.md) para um tour completo dos controles, e [O modelo](model.md) para o que é calculado e as aproximações conhecidas.

## Conceitos principais

### Acerto

Um acerto é a combinação de peças do catálogo e numerações de gicle para um carburador: agulha, posição do clip, calço, difusor, gicle de alta, gicle de baixa e venturi.

### A curva

A ferramenta plota a área livre de passagem de combustível (mm²) contra um eixo X que você pode alternar:

- **Acelerador (%):** abertura do pistonete, 0 a 100% (o input do piloto).
- **Curso da agulha (mm):** deslocamento da agulha desde a marcha lenta. Todos os acertos começam alinhados em 0, então só o venturi define a largura.

Cada eixo mostra sua unidade na ponta, e as linhas de grade dão a escala em mm².

### Comparar acertos

Salve acertos e sobreponha para comparar. Com dois acertos, a diferença entre as curvas é destacada com sinal: verde onde o acerto atual tem mais área, vermelho onde tem menos.

## Como usar

1. Escolha uma agulha e um difusor do catálogo.
2. Defina os gicles de alta e baixa, o clip, o calço e o venturi.
3. Leia a curva, alternando o eixo X entre acelerador e curso da agulha conforme precisar.
4. **Salve** o acerto para guardá-lo. Cada acerto salvo ganha uma URL própria (`/carburetion/setups/:id`), dá pra favoritar.
5. Marque acertos para **comparar** e sobrepor as curvas.
