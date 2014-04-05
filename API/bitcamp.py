#!/usr/bin/env python

from flask import Flask, Response, session, redirect, url_for, escape, request, render_template, flash, make_response
from werkzeug.utils import secure_filename
from functions import *


app = Flask(__name__)
app.secret_key = os.environ['sk']
dev = (os.getenv('dev','False') == 'True' or app.config['TESTING'] == True)


@app.route('/user/<userid>.json')
@crossdomain(origin='*')
def user(userid):
	method = request.args.get('method', 'GET')
	if method == 'GET':
		return Response(response=get_user_json(userid), status=200, mimetype="application/json")
	elif method == 'CREATE':
		return Response(response=create_user_json(), status=200, mimetype="application/json")
	elif method == 'SET':
		return Response(response=set_user_json(userid, request.args.get('data')), status=200, mimetype="application/json")

@app.route('/photo/<userid>.json', methods=['POST'])
@crossdomain(origin='*')
def photo(userid):
	f = request.files['file']
	if f:
		extension = secure_filename(f.filename).rsplit('.', 1)[1]
		return Response(response=s3_upload(f, extension, userid), status=200, mimetype="application/json")
	else:
		return Response(response=json.dumps({"status": "error"}), status=200, mimetype="application/json")


if __name__ == '__main__':
	if os.environ.get('PORT'):
		app.run(host='0.0.0.0',port=int(os.environ.get('PORT')),debug=dev)
	else:
		app.run(host='0.0.0.0',port=5000,debug=dev)
