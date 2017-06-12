FROM node:8

# port
EXPOSE 8080

# environment variables
ENV PORT 8080
ENV NODE_ENV production

# prepare the app
RUN mkdir -p /usr/src/app
WORKDIR /usr/src/app

# install packages
COPY package.json /usr/src/app/
RUN npm install

# add source
COPY .  /usr/src/app

# entry point
CMD ["npm", "start"]