#!/bin/env python3

import os
import json
from quart import Quart, g, request, jsonify
from quart.helpers import make_response

# defaults
USERDIR="./build/users"

app = Quart(__name__)

@app.route('/', methods=["GET"])
async def hello():
  return 'hello'

# get/select
@app.get('/user/<username>')
async def user_get(username):
  resp={}
  with open (f"{USERDIR}/{username}/data.json", "r") as ff:
    resp=json.loads(ff.read())
  return await make_response(jsonify(resp), 200)

# create/insert
@app.put('/user/<username>')
async def user_put(username):
  resp={}
  try:
    os.mkdir(f"{USERDIR}/{username}")
  except Exception as e:
    resp["status"]= "KO"
    resp["error"] = f"Error creando user dir: {str(e)}"
    return await make_response(jsonify(resp), 400)
  data=await request.get_json()
  data["username"]=username
  with open (f"{USERDIR}/{username}/data.json", "w") as ff:
    ff.write(json.dumps(data))

  resp["status"]="OK"
  return await make_response(jsonify(resp), 200)

@app.delete('/user/<username>')
async def user_delete(username):
  resp={}
  try:
    os.remove(f"{USERDIR}/{username}/data.json")
    os.rmdir(f"{USERDIR}/{username}")
  except Exception as e:
    resp["status"]= "KO"
    resp["error"] = f"Error borrando user dir: {str(e)}"
    return await make_response(jsonify(resp), 400)
  resp["status"]="OK"
  return await make_response(jsonify(resp), 200)

@app.patch('/user/<username>')
async def user_patch(username):
    resp = {}
    try:
        with open(f"{USERDIR}/{username}/data.json", "r") as ff:
            user_data = json.loads(ff.read())
        patch_data = await request.get_json()
        for key, value in patch_data.items():
            user_data[key] = value
        with open(f"{USERDIR}/{username}/data.json", "w") as ff:
            ff.write(json.dumps(user_data))
        resp["status"] = "OK"
    except Exception as e:
        resp["status"] = "KO"
        resp["error"] = f"Error actualizando usuario: {str(e)}"
        return await make_response(jsonify(resp), 400)
    return await make_response(jsonify(resp), 200)

if __name__ == "__main__":
    app.run(host='localhost', 
        port=5000)
        
#app.run()
