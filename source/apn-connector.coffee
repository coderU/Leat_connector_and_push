express = require 'express'
https = require 'https'
mongoose = require 'mongoose'
Schema = mongoose.Schema
fs = require 'fs'
bodyParser = require 'body-parser'

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
app.use bodyParser()

app.post '/regist_apn', (req, res) ->
  console.log "Success"
  phone = req.body.phone
  token = req.body.token
  Account = mongoose.model 'Account'
  Account.findOne
    'phone': phone
    , (err,account) ->
      if err
        return console.log err.toString()
      if !account
        Account = mongoose.model 'Account'
        account = new Account()
        account.phone = phone
        account.token = token
        account.save (err) ->
          if err
            return console.log err.toString()
      else
        account.update "token":token
        , (err) ->
          if err
            return console.log err.toString()

# Bind https to port:8000
https.createServer(options, app)
  .listen(8000)

console.log 'Listening Https at 8000'
