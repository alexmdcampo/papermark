# ================================
# Stage 1 - Builder
# ================================
FROM node:20-alpine AS builder

WORKDIR /app

# deps necessárias
RUN apk add --no-cache libc6-compat

# instalar pnpm
RUN npm install -g pnpm

# copiar projeto inteiro (IMPORTANTE pro Prisma)
COPY . .

# 🔍 Debug opcional (pode remover depois)
RUN echo "🔎 Procurando arquivos next.config..." && find . -name "next.config.*"

# 🔧 FIX Next.js (corrige TODOS os casos de host inválido)
RUN find . -type f -name "next.config.*" -exec sed -i 's/{ *type: *"host" *}/{ type: "host", value: ".*" }/g' {} \; || true
RUN find . -type f -name "next.config.*" -exec sed -i "s/{ *type: *'host' *}/{ type: 'host', value: '.*' }/g" {} \; || true

# 🔍 Debug (verifica se ainda existe erro)
RUN grep -r "type: \"host\"" . || true

# instalar deps (agora com prisma schema presente)
RUN pnpm install

# build Next.js
RUN pnpm build

# ================================
# Stage 2 - Runner
# ================================
FROM node:20-alpine

WORKDIR /app

ENV NODE_ENV=production

# instalar pnpm
RUN npm install -g pnpm

# copiar build pronto
COPY --from=builder /app ./

EXPOSE 3000

CMD ["pnpm", "start"]
