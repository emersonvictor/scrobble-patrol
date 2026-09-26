# scrobble-patrol

## Configuração da API Last.fm

1. Copie `ScrobblePatrol/Configuration/Secrets.example.xcconfig` para `ScrobblePatrol/Configuration/Secrets.xcconfig`.
2. Preencha localmente `LASTFM_API_KEY = sua_chave` (sem aspas).
3. Abra `ScrobblePatrol/ScrobblePatrol.xcodeproj` e execute o app.

`Secrets.xcconfig` é ignorado pelo Git. Nunca coloque a chave no arquivo de exemplo.
Debug e Release usam `App.xcconfig`, que inclui a configuração local.
A chave é inserida no Info.plist durante o build e pode ser lida com
`Bundle.main.object(forInfoDictionaryKey: "LASTFM_API_KEY")`.
Sem a configuração local, a chave fica vazia; preencha-a antes de integrar a API.
Essa configuração evita versionar a chave, mas não a torna secreta dentro do app distribuído.

## Networking

`ScrobblePatrol/ScrobblePatrol/Networking/` contém `LastFmEndpoint` (método e parâmetros),
`LastFmClient` (request HTTP, tratamento de erros e decodificação para DTOs) e
`LastFmService` (conversão para models e entrega por completion com `Result`).
Ambos recebem suas dependências pelo inicializador e expõem protocolos.
A consulta recebe username, página e limite. A configuração da chave permanece
fora do client: leia-a do Info.plist ao montar as dependências do app.
