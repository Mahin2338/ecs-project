FROM node:18-alpine AS builder

WORKDIR /app

RUN npm install -g pnpm

COPY package.json pnpm-lock.yaml ./

RUN pnpm install

COPY . .

ENV DATABASE_URL="postgresql://user:pass@localhost:5432/umami"

RUN pnpm build


#stage2

FROM node:18-alpine
WORKDIR /app

ENV NODE_ENV=production

RUN npm install -g pnpm
COPY package.json pnpm-lock.yaml ./
RUN pnpm install --prod
COPY --from=builder /app/.next ./.next
COPY --from=builder /app/public ./public 
EXPOSE 3000
CMD ["pnpm", "start"]