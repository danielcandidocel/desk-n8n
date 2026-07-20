# Desk N8N

Projeto local para criar e testar os fluxos do agente virtual do Desk.

## O que este ambiente sobe

- `n8n` para orquestrar os fluxos.
- `Postgres` para persistir credenciais, workflows e execuções.
- Conexão com o `RabbitMQ` que já está rodando na aplicação Desk.

## Subir o ambiente

1. Copie `.env.example` para `.env`.
2. Ajuste `N8N_ENCRYPTION_KEY` com uma chave forte.
3. Se você quiser usar a LLM do agente, defina `OPENAI_API_KEY` no `.env`. O container gera automaticamente a credencial `Desk OpenAI` na inicialização.
4. Rode:

```bash
docker compose up -d
```

5. Abra o n8n em `http://localhost:5678`.
6. Credenciais padrão:
- usuário: `admin`
- senha: `admin123`

Na primeira subida, o container importa automaticamente os arquivos `.json` da pasta `workflows`.
Se houver arquivos em `credentials/`, eles também entram no banco antes dos workflows.

## Filas usadas

- `virtual-agent-requests`
- `virtual-agent-responses`
- `copilot-requests`
- `copilot-responses`

As filas usam o exchange `desk.events` no RabbitMQ compartilhado com a aplicação.

## Fluxos previstos

### 1. Agente virtual

Entrada:
- consome da fila `virtual-agent-requests`

Saída:
- publica na fila `virtual-agent-responses`

Arquivo pronto para importar:
- `workflows/virtual-agent-automatic-replies.json`

### 2. Retorno ao Desk

Entrada:
- consome da fila `virtual-agent-responses`

Saída:
- envia a resposta final para a aplicação Desk pela mesma fila, usando o formato de payload que o backend já espera.

### 3. Copiloto

Entrada:
- consome da fila `copilot-requests`

Saída:
- publica a sugestão final na fila `copilot-responses`

Arquivo pronto para importar:
- `workflows/copilot-squid-rabbit.json`

## Contrato de payload

Veja [docs/virtual-agent-contract.md](docs/virtual-agent-contract.md).

O Desk envia para o workflow o contexto do cliente, o perfil do agente e os trechos mais relevantes da base técnica da empresa. Assim, cada empresa usa o seu próprio agente sem precisar duplicar fluxo.

## Observação importante

O projeto não sobe um RabbitMQ local; ele usa o broker já existente da aplicação.
Você ainda pode ajustar o fluxo dentro da interface do n8n se quiser trocar a lógica de resposta.
Se quiser, eu também posso te deixar o segundo workflow exportado em JSON depois, para o retorno ao Desk.
