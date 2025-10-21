# Docker Setup per Miro Export

Questa guida spiega come utilizzare miro-export con Docker.

## Build dell'immagine

### Opzione 1: Build locale

```bash
docker build -t miro-export .
```

### Opzione 2: Pull dalla repository

```bash
docker pull ghcr.io/adrigia2/miro-export:latest
```

## Utilizzo

### Metodo 1: Docker Run diretto

Esporta un frame specifico:

```bash
docker run --rm -v ${PWD}/exports:/output miro-export \
  -t YOUR_MIRO_TOKEN \
  -b YOUR_BOARD_ID \
  -f "Frame Name" \
  -o "output.svg"
```

Esporta l'intera board:

```bash
docker run --rm -v ${PWD}/exports:/output miro-export \
  -t YOUR_MIRO_TOKEN \
  -b YOUR_BOARD_ID \
  -o "board.svg"
```

Esporta in formato JSON:

```bash
docker run --rm -v ${PWD}/exports:/output miro-export \
  -t YOUR_MIRO_TOKEN \
  -b YOUR_BOARD_ID \
  -f "Frame Name" \
  -e json \
  -o "output.json"
```

Esporta multipli frame:

```bash
docker run --rm -v ${PWD}/exports:/output miro-export \
  -t YOUR_MIRO_TOKEN \
  -b YOUR_BOARD_ID \
  -f "Frame 1" "Frame 2" "Frame 3" \
  -o "{frameName}.svg"
```

### Metodo 2: Docker Compose

#### Con build locale (docker-compose.yml):

1. Modifica il file `docker-compose.yml` e inserisci il tuo comando nella sezione `command`
2. Oppure crea un file `.env` con le tue credenziali:

```env
MIRO_TOKEN=your_token_here
MIRO_BOARD_ID=your_board_id_here
```

3. Esegui:

```bash
docker-compose run --rm miro-export -t $MIRO_TOKEN -b $MIRO_BOARD_ID -f "Frame Name" -o "output.svg"
```

#### Con immagine pre-buildada (docker-compose.prod.yml):

1. Usa il file `docker-compose.prod.yml` che scarica l'immagine dalla repository
2. Crea un file `.env` con le tue credenziali:

```env
MIRO_TOKEN=your_token_here
MIRO_BOARD_ID=your_board_id_here
```

3. Esegui:

```bash
docker-compose -f docker-compose.prod.yml run --rm miro-export -t $MIRO_TOKEN -b $MIRO_BOARD_ID -f "Frame Name" -o "output.svg"
```

### Metodo 3: Bash/PowerShell Script

#### Linux/Mac (bash):

```bash
#!/bin/bash
docker run --rm -v ${PWD}/exports:/output miro-export "$@"
```

Salva come `miro-export.sh`, rendi eseguibile con `chmod +x miro-export.sh` e usa:

```bash
./miro-export.sh -t TOKEN -b BOARD_ID -f "Frame" -o "output.svg"
```

#### Windows (PowerShell):

```powershell
docker run --rm -v ${PWD}/exports:/output miro-export $args
```

Salva come `miro-export.ps1` e usa:

```powershell
.\miro-export.ps1 -t TOKEN -b BOARD_ID -f "Frame" -o "output.svg"
```

## Note importanti

1. **Token di autenticazione**: Per board private, devi ottenere il token dai cookie del browser (vedi README.md principale)

2. **Directory output**: I file vengono salvati nella directory `./exports` (creala se non esiste)

3. **Volume mounting**: Il parametro `-v ${PWD}/exports:/output` monta la directory locale `exports` nel container

4. **Rimozione automatica**: Il flag `--rm` rimuove automaticamente il container dopo l'esecuzione

5. **Configurazione Puppeteer**: L'immagine Docker è configurata per eseguire Chromium con i flag `--no-sandbox` e `--disable-setuid-sandbox` necessari per l'ambiente containerizzato

## Troubleshooting

### Errore "Permission denied" su Linux

```bash
# Aggiungi i permessi alla directory exports
chmod 777 exports
```

### Il container non trova Chromium

L'immagine Docker include già Chromium. Se riscontri problemi, verifica che l'immagine sia stata costruita correttamente:

```bash
docker build --no-cache -t miro-export .
```

### Windows PowerShell - Problemi con i volumi

In Windows PowerShell, usa il percorso completo:

```powershell
docker run --rm -v C:\Users\tuoUtente\path\to\exports:/output miro-export -t TOKEN -b BOARD_ID -o "output.svg"
```

## Esempi pratici

### Backup automatico di una board

```bash
#!/bin/bash
DATE=$(date +%Y%m%d)
docker run --rm -v ${PWD}/exports:/output miro-export \
  -t $MIRO_TOKEN \
  -b $MIRO_BOARD_ID \
  -o "backup-${DATE}.svg"
```

### Export di tutti i frame con nomi personalizzati

```bash
docker run --rm -v ${PWD}/exports:/output miro-export \
  -t $MIRO_TOKEN \
  -b $MIRO_BOARD_ID \
  -f "Design 1" "Design 2" "Design 3" \
  -o "export-{frameName}.svg"
```
