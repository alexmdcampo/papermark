# ================================
# Stage 1 - Builder
# ================================
FROM node:20-alpine AS builder

WORKDIR /app

# dependências necessárias
RUN apk add --no-cache libc6-compat

# instalar pnpm
RUN npm install -g pnpm

# copiar projeto inteiro (IMPORTANTE pro Prisma)
COPY . .

# =========================================
# 🔥 FIX GLOBAL DO ERRO DO NEXT (HOST HEADER)
# =========================================
RUN echo "🔧 Fixing Next.js host header issue..."

# corrige TODOS os arquivos js/mjs do projeto
RUN find . \( -name "*.js" -o -name "*.mjs" \) \
  -exec sed -i 's/type:[[:space:]]*"host"/type: "host", value: ".*"/g' {} \;

RUN find . \( -name "*.js" -o -name "*.mjs" \) \
  -exec sed -i "s/type:[[:space:]]*'host'/type: 'host', value: '.*'/g" {} \;

# debug opcional (pode remover depois)
RUN echo "🔍 Verificando ocorrências restantes..." && grep -r 'type: "host"' . || true

# =========================================
# instalar dependências (com prisma)
# =========================================
RUN pnpm install --unsafe-perm

# =========================================
# build Next.js
# =========================================
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
