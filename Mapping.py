#!/usr/bin/env python
# coding: utf-8

# In[11]:


from similarity.jarowinkler import JaroWinkler
from similarity.cosine import Cosine
import pyodbc
import pandas as pd
import numpy as np
import itertools
from fuzzywuzzy import fuzz, process
import time
start_time = time.time()
conn = pyodbc.connect("Driver={SQL Server Native Client 11.0};"
                      "Server=DESKTOP-290QJ8I\PRG_RAJENDRA;"
                      "Database=Original_Data;"
                      "Trusted_Connection=yes;")

cursor = conn.cursor()
master=pd.read_sql_query("select sku as MasterSKU,MRP as MRP,Pack as Pack,Strength as Strength from [Master Data] where sku is not null and sku<>' '",conn)
hub=pd.read_sql_query("select sku as Item_Name,MRP as MRP,Pack as Pack,Strength as Strength from Hub_Data",conn)
master=master[:300]
hub=hub[:20]
data = pd.DataFrame()
df = pd.MultiIndex.from_product([hub["Item_Name"], master["MasterSKU"]], names=["Item_Name", "SKU"]).to_frame(index=False)
cosine = Cosine(3)
df["p0"] = df["Item_Name"].apply(lambda s: cosine.get_profile(s)) 
df["p1"] = df["SKU"].apply(lambda s: cosine.get_profile(s)) 
df["cosine_sim"] = [cosine.similarity_profiles(p0,p1) for p0,p1 in zip(df["p0"],df["p1"])]
data['Similarity']=(df.groupby(['Item_Name'], sort=False)['cosine_sim'].max())*100
df['SimilarityInPercentage']=df['cosine_sim']*100
data=pd.merge(hub, data, on=['Item_Name', 'Item_Name'])
df=df.drop(["p0", "p1"], axis=1)
data


Hub_SKU=[]
Master_SKU=[]
HubSimilarity=[]
for i in data.index:
    for j in df.index:
        hubsku=data['Item_Name'][i]
        hubmrp=data['MRP'][i]
        hubsimilarity=data['Similarity'][i]
        masterSimilarity=df['SimilarityInPercentage'][j]
        mastersku=df['SKU'][j]
        masterhubsku=df['Item_Name'][j]
        if hubsimilarity>0:
            if hubsku==masterhubsku:
                if (hubsimilarity==masterSimilarity):
                    Hub_SKU.append(hubsku)
                    Master_SKU.append(mastersku)
                    HubSimilarity.append(hubsimilarity)
                    df['Hub_SKU']=pd.Series(Hub_SKU)
                    df['Master_SKU']=pd.Series(Master_SKU)
                    df['HubSimilarity']=pd.Series(HubSimilarity)
                    
data=df.drop(['SKU','Item_Name','cosine_sim','SimilarityInPercentage'],axis=1)
data=data.dropna()
data=pd.concat([data, hub], axis=1, join='outer')
data=data.drop(['Item_Name'],axis=1)
data

MappData = pd.DataFrame()
HubPack=[]
MasterPack=[]
Mappmastersku=[]
MappingSimilarity=[]
Hub_SKU1=[]
Master_SKU1=[]
HubSimilarity1=[]
HubStrength=[]
MasterStrength=[]

for k in data.index:
    for w in master.index:
        hubsku=data['Hub_SKU'][k]
        masterskufromdata=data['Master_SKU'][k]
        hubsimilarity=data['HubSimilarity'][k]
        hubmrp=data['MRP'][k]
        hubpack=data['Pack'][k]
        hubstrength=data['Strength'][k]
        mastersku=master['MasterSKU'][w]
        mastermrp=master['MRP'][w]
        masterpack=master['Pack'][w]
        masterstrength=master['Strength'][w]
        if masterskufromdata==mastersku:
            if hubmrp==mastermrp:
                HubPack.append(hubpack)
                MasterPack.append(masterpack)
                MappData['HubPack']=pd.Series(HubPack)
                MappData['MasterPack']=pd.Series(MasterPack)
                if (hubpack==MasterPack).all():
                    Hub_SKU1.append(hubsku)
                    Master_SKU1.append(mastersku)
                    HubSimilarity1.append(hubsimilarity)
                    MappData['Hub_SKU1']=pd.Series(Hub_SKU1)
                    MappData['Master_SKU1']=pd.Series(Master_SKU1)
                    MappData['HubSimilarity1']=pd.Series(HubSimilarity1)
                HubStrength.append(hubstrength)
                MasterStrength.append(masterstrength)
                if HubStrength==MasterStrength:
                    Hub_SKU1.append(hubsku)
                    Master_SKU1.append(mastersku)
                    HubSimilarity1.append(hubsimilarity)
                    MappData['Hub_SKU1']=pd.Series(Hub_SKU1)
                    MappData['Master_SKU1']=pd.Series(Master_SKU1)
                    MappData['HubSimilarity1']=pd.Series(HubSimilarity1)
                    
                
MappData=MappData.drop(['HubPack','MasterPack'],axis=1)
MappData=MappData.dropna()
MappData

for index,row in MappData.iterrows():
    cursor.execute('Update Hub_Data set Master_SKU=? where SKU=?',
                   row['Master_SKU1'],
                   row['Hub_SKU1'])
conn.commit()
print("Update Successfully")


# In[ ]:





# In[ ]:




