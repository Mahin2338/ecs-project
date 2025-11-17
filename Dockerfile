FROM node:18-alpine AS builder

WORKDIR /app

RUN npm install -g pnpm

COPY package.json pnpm-lock.yaml ./

RUN pnpm install

COPY . .


#stage2

FROM node:18-alpine
WORKDIR /app
RUN npm install -g pnpm
COPY package.json pnpm-lock.yaml ./
RUN pnpm install --prod
COPY --from=builder /app/.next ./.next
COPY --from=builder /app/public ./public 
EXPOSE 3000
CMD ["pnpm", "start"]