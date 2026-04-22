# ================================
# Stage 1 - Builder
# ================================
FROM node:20-alpine AS builder

WORKDIR /app

RUN apk add --no-cache libc6-compat

# instalar pnpm
RUN npm install -g pnpm

# ⚠️ copia tudo primeiro (IMPORTANTE pro Prisma)
COPY . .

# 🔧 FIX Next.js (erro do host)
RUN sed -i 's/type: "host"/type: "host", value: ".*"/g' next.config.mjs || true
RUN sed -i "s/type: 'host'/type: 'host', value: '.*'/g" next.config.mjs || true

# instalar deps
RUN pnpm install

# build
RUN pnpm build

# ================================
# Stage 2 - Runner
# ================================
FROM node:20-alpine

WORKDIR /app

ENV NODE_ENV=production

RUN npm install -g pnpm

COPY --from=builder /app ./

EXPOSE 3000

CMD ["pnpm", "start"]
