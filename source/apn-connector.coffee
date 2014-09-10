express = require 'express'
https = require 'https'
mongoose = require 'mongoose'
Schema = mongoose.Schema
fs = require 'fs'
bodyParser = require 'body-parser'
join = require('path').join
pfx = join(__dirname, '../_certs/pfx.p12')
apnagent = require 'apnagent'
agent = module.exports = new apnagent.Agent()
agent
  .set('pfx file', pfx)
  .set('passphrase','666666')
  .enable 'sandbox'
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
  #console.log "Connected-Regist"
  phone = req.body.phone
  token = req.body.token
  Account = mongoose.model 'Account'
  Account.findOne
    'phone': phone
    , (err,account) ->
      if err
        return console.log err.toString()
      if !account
        console.log "No such account exist"
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
          #console.log "Account token update Success"

app.post '/send_apn', (req, res) ->
  buddies = req.body.buddies
  source = req.body.source
  message = req.body.message

  console.log source+" send to "+buddies+": "+message
  Account = mongoose.model 'Account'
  Account.findOne
    'phone': phone
    , (err,account) ->
      if err
        return console.log err.toString()
      if !account
        return


agent.connect (err) ->
  # gracefully handle auth problems
  if err
    console.log err.toString()
    return


  # it worked!
  env = if agent.enabled('sandbox') then 'sandbox' else 'production'

  console.log 'apnagent [%s] gateway connected', env


# Bind https to port:8000
https.createServer(options, app)
  .listen(8000)

console.log 'Listening Https at 8000'
