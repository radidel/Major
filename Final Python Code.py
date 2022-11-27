#!/usr/bin/env python
# coding: utf-8

# In[1]:


pip install pyodbc


# In[47]:


import pyodbc
import pandas as pd
import numpy as np
from fuzzywuzzy import process, fuzz
import matplotlib.pyplot as plt
import time
start_time = time.time()
from sqlalchemy import create_engine


# In[57]:


conn = pyodbc.connect("Driver={SQL Server Native Client 11.0};"
                      "Server=DESKTOP-290QJ8I\PRG_RAJENDRA;"
                      "Database=Prg;"
                      "Trusted_Connection=yes;")

cursor = conn.cursor()


# In[59]:


Master_Data= pd.read_sql_query('select*from [Master Data] where Product_ID in (select Product_ID from [Master Data] group by Product_ID having count(*)=1)',conn)
Hub_Data = pd.read_sql_query('with a as ( select Hub_Data.Name as HubName,[Master Data].Name As MasterName from Hub_Data,[Master Data] where Hub_Data.Name=[Master Data].Name) select*from Hub_Data where Name not in (select HubName from a)',conn)


# In[60]:


df=Master_Data
df_1= Hub_Data


# In[61]:


df_1


# In[52]:


import recordlinkage
indexer = recordlinkage.Index()
indexer.full()
candidates = indexer.index(df, df_1)
print(len(candidates))


# In[62]:


df_1.info()


# In[63]:


df['Name'] = df['Name'].str.strip()
df['Name']=df['Name'].str.lower()
df_1['Name'] = df_1['Name'].str.strip()
df_1['Name']=df_1['Name'].str.lower()

print(df)


# In[64]:


similarity = []
for i in df_1.Name :     
    if pd.isnull( i ) :          
        
        similarity.append(np.null)     
    else :          
        ratio = process.extract( i, df .Name, limit=1)
        
        similarity.append(ratio[0][1]) 

df_1['similarity'] = pd.Series(similarity) 


# In[65]:


df_1


# In[23]:


df['Name'] = df['Name'].str.strip()
df['Name']=df['Name'].str.lower()
df_1['Name'] = df_1['Name'].str.strip()
df_1['Name']=df_1['Name'].str.lower()


# In[24]:


df.sort_values("Name", inplace = True)
df_1.sort_values("Name", inplace = True)


# In[25]:


df.drop_duplicates(subset ="Name", 
                     keep = False, inplace = True)
df_1.drop_duplicates(subset ="Name", 
                     keep = False, inplace = True)


# In[59]:


conn_str = (
    r'Driver={SQL Server Native Client 11.0};'
    r'Server=DESKTOP-290QJ8I\PRG_RAJENDRA;'
    r'Database=Master;'
    r'Trusted_Connection=yes;'
)
cnxn = pyodbc.connect(conn_str)

cursor = cnxn.cursor()


# In[35]:


df_1.replace([np.inf, -np.inf], np.nan, inplace = True)
df_1 = df_1.fillna(0)


# In[39]:


df_1.info()


# In[41]:


df_1.to_excel(r'C:\Users\RX91-7\Desktop\Indian Medicine.com files\Practise\HubclosingStockDump.xlsx', index = False)


# In[60]:


for index,row in df_1.iterrows():
    cursor.execute('INSERT INTO HubclosingStockDump([ItemID],[Company],[ItemCode],[Name],[HSNCode],[LocalTax],[SGST],[CGST],[CentralTax],[IGST],[HsnName],[OldTax],[Rate],[AddLess],[P#Rate],[M#R#P#],[Stock],[Tax Diff#],[Category],[Salt],[df_1Name],[similarity]) values (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)', 
                    row['ItemID'], 
                    row['Company'], 
                    row['ItemCode'],
                    row['Name'],
                    row['HSNCode'],
                    row['LocalTax'],
                    row['SGST'],
                    row['CGST'],
                    row['CentralTax'],
                    row['IGST'],
                    row['HsnName'],
                    row['OldTax'],
                    row['Rate'],
                    row['AddLess'],
                    row['P#Rate'],
                    row['M#R#P#'],
                    row['Stock'],
                    row['Tax Diff#'],
                    row['Category'],
                    row['Salt'],
                    row['df_1Name'],
                    row['similarity'])
    cnxn.commit()
cursor.close()
cnxn.close()

# see total time to do insert
print("%s seconds ---" % (time.time() - start_time))


# In[ ]:




