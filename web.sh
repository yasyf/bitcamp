cd API

if [ "$dev" == "True" ]; then
        python bitcamp.py
else
		gunicorn -b "0.0.0.0:$PORT" bitcamp:app
fi