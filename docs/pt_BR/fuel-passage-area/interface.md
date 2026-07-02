---
title: Usando a interface
description: Um tour guiado pela interface da ferramenta de área de passagem.
---

# Usando a interface

## Barra superior

A marca ("Afinados") leva de volta ao hub de ferramentas. O botão de tema alterna entre claro e escuro, e a escolha fica salva. Sem escolha, o tema segue o seu sistema operacional. O seletor de idioma (PT/EN), ao lado do tema, troca o idioma da interface; a escolha fica salva.

## O gráfico

A curva ocupa o topo da tela. No celular ela fica fixa enquanto os controles rolam embaixo; em tela larga os controles viram uma barra lateral à esquerda.

O botão **Ver por** alterna o eixo X entre **acelerador (%)** e **curso da agulha (mm)**. Ele mostra o eixo para onde você vai, não o atual. Cada eixo mostra sua unidade na ponta (%, mm, mm²), e as linhas de grade dão a escala.

Se o acerto for inválido (por exemplo um gicle em 0), o gráfico é trocado por uma mensagem curta. Corrija o valor para a curva voltar.

## Os controles

A agulha e o difusor são escolhidos do catálogo (listas). Gicle de alta, gicle de baixa, calço e venturi recebem números. O clip é uma lista limitada à quantidade de clips da agulha, então não dá para escolher uma posição inválida.

**Salvar acerto** guarda o acerto atual.

## Acertos salvos

O painel **Acertos salvos** fica acima do formulário. É colapsável e continua visível mesmo vazio, com uma contagem.

- Cada acerto salvo mostra suas peças (gicles, agulha, clip).
- **Comparar:** marque um acerto para sobrepor a curva dele. O checkbox no topo da lista marca ou desmarca todos.
- **Carregar:** clique num acerto para carregá-lo. A barra de endereço muda para a URL própria do acerto (`/carburetion/setups/:id`), que dá para favoritar.
- **Apagar:** o × remove um acerto, após uma confirmação.

## Avisos

Salvar ou apagar mostra um aviso curto no canto inferior direito (largura total no celular). Feche no × ou deixe sumir.

## Compartilhar

A URL de um acerto salvo só resolve no navegador que o criou, já que os acertos são privados da sua sessão. Abrir a URL de um acerto desconhecido redireciona de volta à ferramenta com um aviso de "não encontrado".
