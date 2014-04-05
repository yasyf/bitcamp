#!/usr/bin/env python

from setup import *
from flask import make_response, request, current_app, render_template, redirect, url_for, session, abort, flash
from functools import update_wrapper
from bson.objectid import ObjectId
import json
import datetime

def crossdomain(origin=None, methods=None, headers=None,
				max_age=21600, attach_to_all=True,
				automatic_options=True):
	if methods is not None:
		methods = ', '.join(sorted(x.upper() for x in methods))
	if headers is not None and not isinstance(headers, basestring):
		headers = ', '.join(x.upper() for x in headers)
	if not isinstance(origin, basestring):
		origin = ', '.join(origin)
	if isinstance(max_age, datetime.timedelta):
		max_age = max_age.total_seconds()

	def get_methods():
		if methods is not None:
			return methods

		options_resp = current_app.make_default_options_response()
		return options_resp.headers['allow']

	def decorator(f):
		def wrapped_function(*args, **kwargs):
			if automatic_options and request.method == 'OPTIONS':
				resp = current_app.make_default_options_response()
			else:
				resp = make_response(f(*args, **kwargs))
			if not attach_to_all and request.method != 'OPTIONS':
				return resp

			h = resp.headers

			h['Access-Control-Allow-Origin'] = origin
			h['Access-Control-Allow-Methods'] = get_methods()
			h['Access-Control-Max-Age'] = str(max_age)
			if headers is not None:
				h['Access-Control-Allow-Headers'] = headers
			return resp

		f.provide_automatic_options = False
		return update_wrapper(wrapped_function, f)
	return decorator



def get_user_json(userid):
	user = nearby.find_one({'_id': ObjectId(userid)})
	user['_id'] = str(user['_id'])
	return json.dumps(user)

def create_user_json():
	user = nearby.insert({})
	return json.dumps({"userid": str(user)})

def set_user_json(userid, data):
	data = json.loads(data)
	nearby.update({'_id': ObjectId(userid)}, data)
	return json.dumps({"status": "success"})
