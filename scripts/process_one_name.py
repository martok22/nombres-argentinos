# -*- coding: utf-8 -*-
import pandas as pd
import numpy as np
import json
import re


def format_name(name):
    """ Function que formatea un nombre para el nombre del json"""
    formated_name = re.sub('▒~V~R~V~R~A', 'a', name)
    formated_name = re.sub('▒~V~R~I', 'e', formated_name)
    formated_name = re.sub('▒~V~R~M', 'i', formated_name)
    formated_name = re.sub('▒~V~R~S', 'o', formated_name)
    formated_name = re.sub('▒~V~R~Z', 'u', formated_name)
    formated_name = re.sub('▒~V~R~Q', 'n', formated_name)
    formated_name = re.sub('[^\sa-zA-Z\d]+', ' ', formated_name)
    formated_name = re.sub('\s+', '_', formated_name)
    formated_name = re.sub('^_+', '', formated_name)
    formated_name = re.sub('_+$', '', formated_name)
    return formated_name.lower()


# Load csv into dataframe
df = pd.read_csv('./data/nombres1922a2015conpp.csv',
                 header=None,
                 dtype={'0': str,
                        '1': np.int32,
                        '2': np.int32,
                        '3': str,
                        '4': np.float64})

print('-------------- termino loading csv --------------')

df.columns = ['name', 'quantity', 'year', 'gender', 'percentage']

# Reemplazar por nombre en cuestión
df = df[df['name'] == 'MICKEY']
df = df.groupby(('name', 'year', 'gender')).agg(
    {'quantity': sum, 'percentage': sum}).reset_index()

print(df.head())

print('-------------- termino de agrupar por año --------------')
# --- Start procesamiento de nombres

# Sacar distinct de nombres para hacer el cruce cartesiano luego
all_unique_names = df.groupby(('name', 'gender')).count().reset_index()
all_unique_names = all_unique_names[['name', 'gender']]

# Crear dataframe de anios para hacer el cruce cartesiano luego
years = pd.DataFrame({'year': list(range(1922, 2016))})
years['year'] = years['year'].astype(np.int32)

# Crear key en comun para hacer cartesian product
all_unique_names['tmp_key'] = 1
years['tmp_key'] = 1

# # Especificar dtype para hacer mas eficiente el cruce
all_unique_names['tmp_key'] = all_unique_names['tmp_key'].astype(np.int32)
years['tmp_key'] = years['tmp_key'].astype(np.int32)

print('-------------- arranco cruce cartesiano --------------')

# Realizar cruce cartesiano
cross_names_years = pd.merge(
    all_unique_names, years, on='tmp_key', how='outer')
cross_names_years = cross_names_years[['name', 'gender', 'year']]
todos_con_todos = pd.merge(cross_names_years, df, on=[
                           'name', 'gender', 'year'], how='left')
todos_con_todos = todos_con_todos.fillna(0)
todos_con_todos['quantity'] = todos_con_todos['quantity'].astype(int)
todos_con_todos['gender'] = todos_con_todos['gender'].str.lower()

names_group = todos_con_todos.groupby('name')

print(todos_con_todos.head())

# Escribir jsons de nombres
for name, group in names_group:
    file_url = 'public/names/' + format_name(str(name)) + '.json'
    print(file_url)
    list_name = group.reset_index(
    )[['gender', 'year', 'percentage', 'quantity']].to_dict('records')

    with open(file_url, 'w') as fp:
        json.dump(list_name, fp)
