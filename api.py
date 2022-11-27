from flask import make_response
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
        open_cv_image = np.array(img_light)
        scale_percent = 200 # percent of original size
        width = int(open_cv_image.shape[1] * scale_percent / 100)
        height = int(open_cv_image.shape[0] * scale_percent / 100)
        dim = (width, height)
        large = cv2.resize(open_cv_image,dim, interpolation = cv2.INTER_CUBIC)
        #large = cv2.resize(open_cv_image, None, fx=4, fy=4, interpolation=cv2.INTER_CUBIC)
        gray1 = cv2.cvtColor(large , cv2.COLOR_BGR2GRAY) 
        ret, thresh2 = cv2.threshold(gray1, 0, 255, cv2.THRESH_BINARY + cv2.THRESH_OTSU)
        rotated = cv2.rotate(thresh2, cv2.ROTATE_90_CLOCKWISE)
            
              
        image_to_text1 = pytesseract.image_to_string(large, lang='eng')
        image_to_text2 = pytesseract.image_to_string(rotated , lang='eng')

        dx=[]
        if len(image_to_text1)>len(image_to_text2):
            dx.append(image_to_text1)
        else:
            dx.append(image_to_text2)

        rx=str(dx)
            
        image_to_text=rx.replace('\n',' ')
        dr = re.findall(r'(Dr\.\s\S+\s\S+\b)', image_to_text , re.IGNORECASE)
        email = re.findall(r'[\w\.-]+@[\w\.-]+', image_to_text )
        phones = re.findall('(?:\+ *)?\d[\d\- ]{6,}\d', image_to_text)
        phone_number=[phone.replace('-', '').replace(' ', '') for phone in phones]
        MobileNo = [phone for phone in phone_number if len(phone)==10 or len(phone)==13]
        LandLineNo = [phone for phone in phone_number if len(phone)==8 or len(phone)==11 ]
        #Landlinewithcode = [phone for phone in phone_number if len(phone)==11 ]
        #Mobilewith91 = [phone for phone in phone_number if len(phone)==13]
        time1 = re.findall(r'\s(\d{1,2}\.\d{1,2}\s?(?:AM|PM|am|pm|A.M|P.M|a.m|p.m|A.M.|P.M.|pM.|Noon))', image_to_text) 
        time2 = re.findall(r'\s(\d{1,2}\:\d{1,2}\s?(?:AM|PM|am|pm|A.M|P.M|a.m|p.m|A.M.|P.M.|pM.|Noon))', image_to_text)  
        hospital = re.findall(r'(\w\S+\s+)(?=hospital|clinic|hos|hosp|hospi|hospit|clini|clinics|hospitals){1}' , image_to_text , re.IGNORECASE)
        #splitby\n for hospital
        Hospital_name_by_split=[]
        hosp = ['Hospital' , 'Clinic', 'hospital','clinic','clinics','centre' ,'Hospit@l' , 'Hospitl' , 'Nursing' , 'Home']
        for x in image_to_text1.split('\n'):
            a_match = [True for match in hosp if match in x]
            if True in a_match:
                Hospital_name_by_split.append(x) or Hospital_name_by_split.append(hospital)
            else:
                Hospital_name_by_split.append(hospital)
            break
        
        data=[]
        replacedtext = image_to_text1.replace('\n','.')
        #for x in replacedtext.split('.'):
        #    if [str.isdigit() for str in x].count(True)==(6|7):
         #       data=x
       # Address = data
        AddressbyString= re.findall(r'(\w\S+\s+\S+\s+\S+\s+\S+\s+\S+\s+\S+\s+)(?=Andhra Pradesh|Arunachal Pradesh|Assam|Bihar|Chhattisgarh|Goa|Gujarat|Haryana|Himachal Pradesh|Jharkhand|Karnataka|Kerala|Madhya Pradesh|Maharashtra|Manipur|Meghalaya|Mizoram|Nagaland|Odisha|Punjab|Rajasthan|Sikkim|Tamil Nadu|Telangana|Tripura|Uttar Pradesh|Uttarakhand|West Bengal|Andaman and Nicobar Islands|Chandigarh|Dadra & Nagar Haveli and Daman & Diu|Delhi|Jammu and Kashmir|Lakshadweep|Puducherry|Ladakh|Hyderabad|Itanagar|Dispur|Patna|Raipur|Panaji|Gandhinagar|Chandigarh|Shimla|Ranchi|Bengaluru|Bangalore|Thiruvananthapuram|Bhopal|Mumbai|Imphal|Shillong|Aizawl|Kohima|Bhubaneswar|Jaipur|Gangtok|Chennai|Hyderabad|Agartala|Lucknow|Dehradun|Kolkata|Port Blair|Daman|New Delhi|Srinagar|Kavaratti|Pondicherry|Leh)', image_to_text)
        Department = re.findall(r'(\w\S+\s+)(?=Department){3}', image_to_text)

        #splitby\n for Department
        Department_by_split=[]
        Departments = ['Department']
        for x in image_to_text1.split('\n'):
            a_match = [True for match in Departments if match in x]
            if True in a_match:
                Department_by_split.append(x) or  Department_by_split.append(Department)
                
            else:
                Department_by_split.append(Department)
            break
        
        ClosingDay = re.findall(r'(\w\S+\s+)(?=Closed){1}' , image_to_text)
        myjson={
            "Status":200,
            "data":image_to_text,
            "DoctorName":dr,
            "Email": email,
            "MobileNo":MobileNo,
            "LandLineNo":LandLineNo,
            "HospitalName":Hospital_name_by_split,
            #"HospitalName2":Hospital_name_by_split,
            #"time1":time1,
            #"time2":time2,
            #"Address":Address,
            "Address":AddressbyString,
            "Department":Department_by_split,
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
