# ================================
# Stage 1 - Builder
# ================================
FROM node:20-alpine AS builder

WORKDIR /app

RUN apk add --no-cache libc6-compat
RUN npm install -g pnpm

# copiar projeto inteiro
COPY . .

# 🔧 FIX direto no arquivo correto (monorepo papermark)
RUN sed -i 's/has: \[{ type: "host" }\]/has: [{ type: "host", value: ".*" }]/g' apps/web/next.config.mjs || true
RUN sed -i "s/has: \[{ type: 'host' }\]/has: [{ type: 'host', value: '.*' }]/g" apps/web/next.config.mjs || true

# 🔍 debug (pra garantir)
RUN grep -r "type: \"host\"" apps/web || true

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
