FROM node:14-alpine

WORKDIR /app

ENV PATH /app/node_modules/.bin:$PATH

#Install needed packages
COPY package.json ./
COPY package-lock.json ./
RUN npm install --silent
RUN npm install react-scripts@3.4.1 -g --silent

#Copy files to target directory
COPY . ./

CMD ["npm", "start"]