# AL UI/runtime contract (v0)

The Quickshell HUD is a client. It must not own audio, inference, intent routing, or skill execution.

## Runtime states

- `idle`
- `listening`
- `processing`
- `speaking`
- `running_action`
- `confirmation_required`
- `success`
- `error`

## Event envelope

Each local IPC message is a UTF-8 JSON object with a required `type` and optional `request_id`.

- `state`: `{"type":"state","state":"listening"}`
- `user_transcript`: `{"type":"user_transcript","text":"What time is it?"}`
- `assistant_message`: `{"type":"assistant_message","text":"It's 8:30 AM."}`
- `action_proposal`: `{"type":"action_proposal","skill":"open_settings","arguments":{}}`
- `confirmation_required`: `{"type":"confirmation_required","request_id":"...","summary":"Open system settings?"}`
- `action_result`: `{"type":"action_result","request_id":"...","ok":true,"summary":"Settings opened."}`

## Safety

- IPC stays on the local machine, with restrictive permissions.
- The runtime validates every message and skill argument; the UI cannot execute commands.
- Consequential actions require runtime-side confirmation. The UI's confirmation is only a user signal, never authorization by itself.
- Never send audio, transcripts, model prompts, or machine data to a remote service.
- Ignore unknown event types and malformed JSON; show a recoverable error rather than crashing.
