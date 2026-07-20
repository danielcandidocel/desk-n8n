# Virtual Agent Contract

## Entrada da fila

Fila:

- `virtual-agent-requests`

Payload esperado:

```json
{
  "company_id": 1,
  "company": {
    "id": 1,
    "name": "Desk",
    "trade_name": "Desk",
    "slug": "desk"
  },
  "agent": {
    "name": "Stark",
    "model": "gpt-4.1-mini",
    "temperature": 0.2,
    "system_prompt": "Você é Stark...",
    "knowledge_base": "Base técnica da empresa..."
  },
  "conversation_id": 10,
  "message_id": 123,
  "external_chat_id": "5511999999999@s.whatsapp.net",
  "contact": {
    "id": 20,
    "name": "Cliente",
    "phone": "+55 11 99999-9999"
  },
  "customer": {
    "id": 30,
    "name": "Cliente",
    "phone": "+55 11 99999-9999"
  },
  "conversation": {
    "subject": "Atendimento",
    "channel": "whatsapp",
    "status_id": 1,
    "team_group_id": 2,
    "assigned_user_id": null,
    "assigned_to": null
  },
  "message": {
    "id": 123,
    "body": "Olá",
    "direction": "inbound",
    "message_type": "text",
    "status": "received",
    "sender_name": "Cliente",
    "sent_at": "2026-05-18T12:00:00Z",
    "attachments": []
  },
  "knowledge_matches": [
    {
      "index": 1,
      "title": "Procedimento de login",
      "content": "Passo a passo...",
      "score": 3
    }
  ],
  "timeline": []
}
```

## Como o n8n usa esse payload

O workflow `Virtual Agent - Automatic Replies`:

- recebe a mensagem na fila `virtual-agent-requests`
- monta o prompt com `company`, `agent`, `knowledge_matches` e `timeline`
- usa o nó `AI Agent` com um `OpenAI Chat Model`
- publica a resposta final na fila `virtual-agent-responses`

## Saída da fila

Fila:

- `virtual-agent-responses`

Payload esperado pela aplicação:

```json
{
  "company_id": 1,
  "conversation_id": 10,
  "external_message_id": "virtual-agent-response:123",
  "reply": "Olá, como posso ajudar?",
  "handoff_to_human": false,
  "assistant_name": "Stark"
}
```

### Campos importantes

- `handoff_to_human = true` faz a aplicação tratar a conversa como humana.
- `handoff_to_human = false` faz a aplicação marcar a conversa como `Conversas do bot`.
- `external_message_id` deve ser único para evitar duplicidade.

## Copiloto

O fluxo de copiloto usa a mesma base de conversa e conhecimento, mas o objetivo muda:

- Entrada: `copilot-requests`
- Saída: `copilot-responses`

Payload de saída esperado pela aplicação:

```json
{
  "company_id": 1,
  "conversation_id": 10,
  "external_message_id": "copilot-response:123",
  "suggestion": "Olá, bom dia! Você pode ir em Pacientes > Novo cadastro e preencher os dados obrigatórios.",
  "assistant_name": "Copiloto",
  "confidence": 0.92,
  "summary": "Cliente pediu ajuda para cadastrar um paciente.",
  "notes": "Sugestão pronta para o atendente revisar antes de enviar."
}
```

O `Desk` usa essa sugestão para preencher o composer, sem enviar automaticamente a mensagem ao cliente.
