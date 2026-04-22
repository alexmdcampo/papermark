# ================================
# Stage 1 - Builder
# ================================
FROM node:20-alpine AS builder

WORKDIR /app

# deps necessárias
RUN apk add --no-cache libc6-compat

# instalar pnpm
RUN npm install -g pnpm

# copiar apenas deps primeiro (cache)
COPY package.json pnpm-lock.yaml* ./

RUN pnpm install

# copiar resto do projeto
COPY . .

# 🔧 FIX do erro do Next (host header)
RUN sed -i 's/type: "host"/type: "host", value: ".*"/g' next.config.mjs || true
RUN sed -i "s/type: 'host'/type: 'host', value: '.*'/g" next.config.mjs || true

# build
RUN pnpm build

# ================================
# Stage 2 - Runner
# ================================
FROM node:20-alpine

WORKDIR /app

ENV NODE_ENV=production

# instalar pnpm
RUN npm install -g pnpm

# copiar apenas o necessário
COPY --from=builder /app ./

EXPOSE 3000

CMD ["pnpm", "start"]
