Python 3.8.7 (tags/v3.8.7:6503f05, Dec 21 2020, 17:59:51) [MSC v.1928 64 bit (AMD64)] on win32
Type "help", "copyright", "credits" or "license()" for more information.
>>> from flask import make_response
from flask import request
from datetime import datetime
from flask import render_template
from flask import Flask, jsonify
from flask import abort 
import pyodbc
import pandas as pd
import re
import urllib
import numpy as np
import cv2
import itertools
import json
import time
import PIL
from PIL import Image
import requests
import pytesseract
import numpy as np
from PIL import Image, ImageEnhance
pytesseract.pytesseract.tesseract_cmd = r'C:\Program Files (x86)\Tesseract-OCR\tesseract.exe'
start_time = time.time()
app = Flask(__name__) 

tasks = [
    {
        'id': 1,
        'title': u'Buy groceries',
        'description': u'Milk, Cheese, Pizza, Fruit, Tylenol', 
        'done': False
    },
    {
        'id': 2,
        'title': u'Learn Python',
        'description': u'Need to find a good Python tutorial on the web', 
        'done': False
    }
]
#GET Method
@app.route('/data/tasks/<int:task_id>', methods=['GET'])


def get_task(task_id):
    task = [task for task in tasks if task['id'] == task_id]
    if len(task) == 0:
        abort(404)
    return jsonify({'task': task[0]})
@app.errorhandler(404)
def not_found(error):
    return make_response(jsonify({'error': 'New Ko Server hi nhi mile rha hai to kahan se show krga, Id Number to lgao'}), 404)



#POST method,

@app.route('/hub/mapper', methods=['POST'])
def create_task():
    try:
        if not request.json or not 'title' in request.json:
            abort(400)
        MasterMapperID = request.json['title']
        server = '45.249.111.12'
        database = 'indiachemist_demo_indianchemist'
        username = 'indianchemist_com_indianchemist'
        password = '[Db@PORTAL1]'
        myjson={
                "Status": 400,
                "Message": MasterMapperID  ,
                "Data":""
            }
        return jsonify({'MasterMapperID': myjson})
    except:
        myjson={
                "Status": 400,
                "Message": "Error occured"  ,
                "Data":""
            }
        return jsonify(myjson);
    
@app.route('/file_upload', methods=['POST'])
def fileUpload():
    try:
        if not request.json or not 'url' in request.json:
            abort(400)
        url = request.json['url']
        image=Image.open(requests.get(url, stream=True).raw)
        enhancer = ImageEnhance.Brightness(image) 
	img_light = enhancer.enhance(.90) 
	enhancer = ImageEnhance.Brightness(image) 
	img_light = enhancer.enhance(.90) 
	open_cv_image = np.array(img_light)
	large = cv2.resize(open_cv_image, None, fx=4, fy=4, interpolation=cv2.INTER_CUBIC)
	image_to_text1 = pytesseract.image_to_string(large , lang='eng')
	gray1 = cv2.cvtColor(large , cv2.COLOR_BGR2GRAY) 
	ret, thresh2 = cv2.threshold(gray1, 0, 255, cv2.THRESH_BINARY + cv2.THRESH_OTSU)     
	image_to_text2 = pytesseract.image_to_string(thresh2 , lang='eng')
	gray1 = cv2.cvtColor(large , cv2.COLOR_BGR2GRAY) 
	ret, thresh2 = cv2.threshold(gray1, 0, 255, cv2.THRESH_BINARY + cv2.THRESH_OTSU)     
	image_to_text2 = pytesseract.image_to_string(thresh2 , lang='eng')

	if len(image_to_text1)>len(image_to_text2):
    	image_to_text=image_to_text1.replace('\n',' ')
    	dr = re.findall(r'(Dr\.\s\S+\s\S+\s\S+\b)', image_to_text , re.IGNORECASE)
    	email = re.findall(r'[\w\.-]+@[\w\.-]+', image_to_text )
    	phones = re.findall('(?:\+ *)?\d[\d\- ]{7,}\d', image_to_text)
    	phone_number=[phone.replace('-', '').replace(' ', '') for phone in phones]
    	MobileNo = [phone for phone in phone_number if len(phone)==10]
    	LandLineNo = [phone for phone in phone_number if len(phone)==11]
	#hospital = re.findall(r'(\w\S+\s+)(?=hospital){1}' , image_to_text , re.IGNORECASE)
    	data=[]
    	replacedtext = image_to_text1.replace('\n','.')
    	for x in replacedtext.split('.'):
            if [str.isdigit() for str in x].count(True)==6:
                data=x
    	Address = data
    	Department = re.findall(r'(\w\S+\s+)(?=Department){3}', image_to_text)
    	OpenTime = 'Not Found '
    	CloseTime = 'Not Found'
    	ClosingDay = re.findall(r'(\w\S+\s+)(?=Closed){1}' , image_to_text)
    
    
	else:
    	image_to_text=image_to_text2.replace('\n',' ')
    	dr = re.findall(r'(Dr\.\s\S+\s\S+\s\S+\b)', image_to_text , re.IGNORECASE)
    	email = re.findall(r'[\w\.-]+@[\w\.-]+', image_to_text )
    	phones = re.findall('(?:\+ *)?\d[\d\- ]{7,}\d', image_to_text)
    	phone_number=[phone.replace('-', '').replace(' ', '') for phone in phones]
    	MobileNo = [phone for phone in phone_number if len(phone)==10]
    	LandLineNo = [phone for phone in phone_number if len(phone)==11]
	#hospital = re.findall(r'(\w\S+\s+)(?=hospital){1}' , image_to_text , re.IGNORECASE)
    	data=[]
    	replacedtext = image_to_text1.replace('\n','.')
    	for x in replacedtext.split('.'):
            if [str.isdigit() for str in x].count(True)==6:
                data=x
   	 Address = data
    	Department = re.findall(r'(\w\S+\s+)(?=Department){3}', image_to_text)
    	OpenTime = 'Not Found '
    	CloseTime = 'Not Found'
    	ClosingDay = re.findall(r'(\w\S+\s+)(?=Closed){1}' , image_to_text)
        myjson={
            "Status":200,
            "data":image_to_text,
            "DoctorName":dr,
            "Email": email,
            #"ContactNumber": phone_number,
            "MobileNo":MobileNo,
            
            "LandLineNo":LandLineNo,
            "Address":Address,
            "Department":Department,
            "OpenTime":OpenTime,
            "CloseTime": CloseTime,
            "ClosingDay":ClosingDay
            }
        return jsonify(myjson)
    except Exception as e:
        myjson={
                "Status": 400,
                "Message": "type error:"+str(e)
            }
        return jsonify(myjson);
    
@app.errorhandler(400)
def not_found(error):
    return make_response(jsonify({'error': 'Id is Not Found'}), 400)

@app.route('/ic/ocr', methods=['POST'])
def ocr_task():
    try:
        if not request.json or not 'title' in request.json:
            abort(400)
        imageurl = request.json['imageurl']         
        myjson={
                "Status": 200,
                "Message": imageurl  ,
                "Data":"OCR"
            }
        return jsonify({'MasterMapperID': myjson})
    except:
        myjson={
                "Status": 400,
                "Message": "Error occured"  ,
                "Data":""
            }
        return jsonify(myjson);
@app.errorhandler(400)
def not_found(error):
    return make_response(jsonify({'error': 'url not found'}), 400)



if __name__ == '__main__':
    app.run(debug=True)
