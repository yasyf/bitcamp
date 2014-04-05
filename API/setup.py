import pymongo,os

client = pymongo.MongoClient(os.environ['db'])
db = client.bitcamp
nearby = db.nearby