express = require 'express'
https = require 'https'
mongoose = require 'mongoose'
Schema = mongoose.Schema
fs = require 'fs'

users = mongoose.connect 'mongodb://localhost/users'

Accounts = new Schema
  phone:
    type: String, required: true, unique: true
  token:
    type: String, required: true

AccountModel = mongoose.model 'Account',Accounts

options =
  key: fs.readFileSync '../keys/privatekey.pem'
  cert: fs.readFileSync '../keys/certificate.pem'

app = express()

app.post '/regist_apn', (req, res) ->
  console.log "Success"

# Bind https to port:8000
https.createServer(options, app)
  .listen(8000)

console.log 'Listening Https at 8000'
