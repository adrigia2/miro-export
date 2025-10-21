# Usa Node.js 22 come base image (richiesto dal progetto)
FROM node:22-slim

# Installa le dipendenze necessarie per Puppeteer e Chromium
RUN apt-get update && apt-get install -y \
    chromium \
    fonts-liberation \
    libasound2 \
    libatk-bridge2.0-0 \
    libatk1.0-0 \
    libatspi2.0-0 \
    libcups2 \
    libdbus-1-3 \
    libdrm2 \
    libgbm1 \
    libgtk-3-0 \
    libnspr4 \
    libnss3 \
    libwayland-client0 \
    libxcomposite1 \
    libxdamage1 \
    libxfixes3 \
    libxkbcommon0 \
    libxrandr2 \
    xdg-utils \
    ca-certificates \
    --no-install-recommends \
    && rm -rf /var/lib/apt/lists/*

# Crea un utente non-root per eseguire l'applicazione
RUN groupadd -r mirouser && useradd -r -g mirouser -G audio,video mirouser \
    && mkdir -p /home/mirouser/Downloads \
    && chown -R mirouser:mirouser /home/mirouser

# Crea la directory dell'applicazione
WORKDIR /app

# Copia i file di configurazione delle dipendenze
COPY package.json ./

# Installa le dipendenze
RUN npm install --production=false

# Copia il resto dei file del progetto
COPY . .

# Compila il progetto TypeScript
RUN npm run build

# Configura Puppeteer per usare Chromium installato dal sistema
# e aggiungi gli argomenti necessari per Docker
ENV PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true \
    PUPPETEER_EXECUTABLE_PATH=/usr/bin/chromium \
    PUPPETEER_ARGS="--no-sandbox --disable-setuid-sandbox --disable-dev-shm-usage"

# Crea una directory per gli output e dai i permessi all'utente
RUN mkdir -p /output && chown -R mirouser:mirouser /output /app

# Cambia all'utente non-root
USER mirouser

# Imposta il working directory per gli output
WORKDIR /output

# Imposta il entrypoint sul CLI di miro-export
ENTRYPOINT ["node", "/app/build/cli.js"]

# Help di default se nessun argomento viene passato
CMD ["--help"]
