FROM node

WORKDIR /usr/src/app

COPY package*.json ./
COPY server.js ./
COPY ./img ./img
COPY ./test ./test
COPY ./Makefile ./Makefile

RUN npm install

EXPOSE 5000
CMD [ "npm", "start" ]