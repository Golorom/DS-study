import streamlit as st
import requests
import time
import datetime
from datetime import date, timedelta
import pandas as pd
import numpy as np
import matplotlib.pyplot as plt

st.set_page_config(
    page_title='Cryptocurrency Price Fluctuation',
    layout='wide'
)

# Fetch list of assets from Coincap API
assets_json = requests.get('https://api.coincap.io/v2/assets').json()
assets = {a['symbol']:a['id'] for a in assets_json['data']}

# Allow user to select asset
st.sidebar.title('Select Asset and Date Range')
selected_asset = st.sidebar.selectbox('Select an asset', list(assets.keys()))

# Allow user to select date range
default_date = date.today() - timedelta(days=7)
start_date = st.sidebar.date_input('Date from', default_date)
end_date = st.sidebar.date_input('Date to')

start_timestamp = int(time.mktime(start_date.timetuple())) * 1000
end_timestamp = int(time.mktime(end_date.timetuple())) * 1000

# Allow user to select interval ('m1', 'm5', 'm15', 'm30')
interval_options = ['d1', 'h12', 'h6', 'h2', 'h1']
interval = st.sidebar.selectbox('Select interval', interval_options)

# Allow user to adjust size of the plot and bars
width = st.sidebar.slider('Plot width', 10, 30, 20)
height = st.sidebar.slider('Plot height', 5, 15, 10)
bar_width = st.sidebar.slider('Bar width', 0.2, 0.8, 0.5, 0.1)

# Fetch historical data for selected asset and date range from Coincap API
url = f'https://api.coincap.io/v2/assets/{assets[selected_asset]}/history?interval={interval}&start={start_timestamp}&end={end_timestamp}'
# print(url)
response = requests.get(url)
# print(response.status_code)

# If response is positive create a dataframe
if response.status_code != 200:
    st.write(
        'An error occurred while trying to fetch the data. Please check the input values.'
    )
else:
    json_data = response.json()
    df = pd.DataFrame(json_data['data'])
    df = df[['time', 'priceUsd']]
    df['time'] = pd.to_datetime(df['time'] / 1000, unit='s')
    df['priceUsd'] = np.round(df['priceUsd'].apply(float), decimals=2)
    
# Calculate leeway, used for better readability
leeway = (df['priceUsd'].max() - df['priceUsd'].min()) * 0.1
bott = df['priceUsd'].min() - leeway
top = df['priceUsd'].max() + leeway

# Draw a plot
x = df['time']
y = df['priceUsd']
fig = plt.figure(figsize=(width, height))
plt.style.use('dark_background')
plt.bar(
    x, y,
    width=bar_width,
    edgecolor='blue',
    linewidth=1
)
plt.ylim(bott, top)
plt.xlabel('Time')
plt.ylabel('Price (USD)')
st.pyplot(fig)