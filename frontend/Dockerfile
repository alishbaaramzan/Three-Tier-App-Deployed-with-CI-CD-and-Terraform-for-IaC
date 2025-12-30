FROM node:18-alpine

WORKDIR /app

COPY package.json .

RUN npm install

COPY . .

ENV REACT_APP_BACKEND_URL=""

CMD ["npm", "start"]