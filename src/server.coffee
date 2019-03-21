koa = require 'koa'
router = require 'koa-router'
parser = require 'koa-body'

app = new koa()
r = new router()

db = {}

url = 'mongodb://localhost:27017/mock'

r.get '/', (ctx) ->
    ctx.body = "
        <html>
            <head>
                <title>HTML Forms are Cool!</title>
            </head>
            <body>
                <form action=\"/subscribe\" method=\"post\">
                    <input type=\"text\" name=\"email\" placeholder=\"Email Address\">
                    <input type=\"submit\">
                </form>
            </body>
        </html>
    "

r.post '/subscribe', parser(), (ctx) ->
    email = ctx.request.body.email
    if not email
        ctx.status = 400
        ctx.body = "missing email"
    else
        await db.collection('subs').insert {
            email: email
        }
        ctx.body = "success"

r.get '/subscribers', (ctx) ->
    ctx.body = await db.collection('subs').find()
        .project {_id: 0, email: 1}
        .toArray (err, docs) ->
            return docs


app.use r.routes()

require('mongo-mock').MongoClient.connect url, {}, (err,_db) ->
    db = _db
    app.listen 5000, (e) ->
        console.log "listening on 5000"