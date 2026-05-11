# =========================
# Base
# =========================
FROM node:22-alpine AS base

RUN apk add --no-cache libc6-compat

RUN npm install -g pnpm

# =========================
# Dependencies
# =========================
FROM base AS deps

WORKDIR /app

COPY package.json pnpm-lock.yaml pnpm-workspace.yaml* ./

RUN pnpm install --frozen-lockfile --ignore-scripts

# =========================
# Builder
# =========================
FROM base AS builder

WORKDIR /app

COPY --from=deps /app/node_modules ./node_modules
COPY . .

RUN pnpm build

# =========================
# Runner
# =========================
FROM node:22-alpine AS runner

WORKDIR /app

RUN apk add --no-cache libc6-compat

RUN npm install -g pnpm

ENV NODE_ENV=production

COPY --from=builder /app ./

EXPOSE 3001

CMD ["pnpm", "start"]