# -*- coding: utf-8 -*-
import pandas as pd
import numpy as np
import sqlalchemy
from sqlalchemy import create_engine
import re
import yaml
import json

with open('../config/mysql.conf', 'r') as f:
    config = yaml.load(f)

# Conexion a base mysql
engine = create_engine(
    "mysql://" + config["username"] + ":" + config["password"] +
    "@" + config["host"] + "/nombres?charset=utf8mb4",
    pool_recycle=3600)


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
df = pd.read_csv('../data/nombres1922a2015conpp.csv',
                 header=None,
                 dtype={'0': str,
                        '1': np.int32,
                        '2': np.int32,
                        '3': str,
                        '4': np.float64})

df.columns = ['name', 'quantity', 'year', 'gender', 'percentage']
df = df.groupby(('name', 'year', 'gender')).agg(
    {'quantity': sum, 'percentage': sum}).reset_index()

# Escribir dataframe a base
# df.to_sql('nombres', engine, flavor='mysql',
#           if_exists='replace', chunksize=20000)
# print("Terminamos de escribir nombres a la base")

# --- Start calculos de top anuales ---

# Agrupar nombres por anio
# df_by_year = df.groupby('year')

# # Iterar por los años y generar jsons anuales dividos por genero
# for name, group in df_by_year:
#     year = format_name(str(name))
#     top_year = {}
#     df_by_gender = group.groupby('gender')
#     for name, group in df_by_gender:
#         gender = name.lower()
#         df_year_gender = group.sort_values(by=['quantity'], ascending=False)[
#             ['name', 'quantity']].head(10)
#         df_year_gender['name'] = df_year_gender[
#             'name'].apply(lambda x: format_name(x))
#         top_year[gender] = df_year_gender.to_dict('records')

#     file_url = '../public/years/' + year + '.json'
#     with open(file_url, 'w') as fp:
#         json.dump(top_year, fp)

# Para debug
# print('--------- termino anios ----------')

# --- Start calculos de top por decadas ---

# Agregar columna para decada
df['decade'] = df['year'] // 10 * 10

dfgd = df.groupby(('decade', 'gender', 'name')).agg({'quantity': sum})
dfgdd = dfgd.groupby(level=0)
for name, group in dfgdd:
    decade = format_name(str(name))
    top_decade = {}
    dfg_gender = group.groupby(level=[0, 1])
    for name, group in dfg_gender:
        gender = name[1].lower()
        gender_group = group.reset_index().sort_values(
            by=['quantity'], ascending=False)[['name', 'quantity']].head(10)
        gender_group['name'] = gender_group[
            'name'].apply(lambda x: format_name(x))
        top_decade[gender] = gender_group.to_dict('records')

    file_url = '../public/years/decada-' + decade + '.json'
    with open(file_url, 'w') as fp:
        json.dump(top_decade, fp)

# Para debug
# print('---------- termino decadas ------------')

# --- Start procesamiento de nombres

# Sacar distinct de nombres para hacer el cruce cartesiano luego
all_unique_names = df.groupby(('name', 'gender')).agg(
    {'percentage': 'sum'}).reset_index()
all_unique_names = all_unique_names.sort_values('percentage', ascending=False)
all_unique_names = all_unique_names[['name', 'gender']].head(300)

# Crear dataframe de anios para hacer el cruce cartesiano luego
years = pd.DataFrame({'year': list(range(1922, 2016))})
years['year'] = years['year'].astype(np.int32)

# Crear key en comun para hacer cartesian product
all_unique_names['tmp_key'] = 1
years['tmp_key'] = 1

# Especificar dtype para hacer mas eficiente el cruce
all_unique_names['tmp_key'] = all_unique_names['tmp_key'].astype(np.int32)
years['tmp_key'] = years['tmp_key'].astype(np.int32)

# Dividir nombres unicos en chunks para aliviar el procesamiento
split_unique_names = np.array_split(all_unique_names, 1)

# Iterar por los chunks
for index, unique_names in enumerate(split_unique_names):
    # Realizar cruce cartesiano
    cross_names_years = pd.merge(
        unique_names, years, on='tmp_key', how='outer')
    cross_names_years = cross_names_years[['name', 'gender', 'year']]
    todos_con_todos = pd.merge(cross_names_years, df, on=[
                               'name', 'gender', 'year'], how='left')
    todos_con_todos = todos_con_todos.fillna(0)
    todos_con_todos['quantity'] = todos_con_todos['quantity'].astype(int)
    todos_con_todos['gender'] = todos_con_todos['gender'].str.lower()

    if index == 0:
        todos_con_todos.to_sql('cruce_nombres_anios',
                               engine, flavor='mysql', index=False,
                               if_exists='replace',
                               dtype={'name': sqlalchemy.NVARCHAR(length=255),
                                      'gender':
                                      sqlalchemy.types.NVARCHAR(length=1),
                                      'year': sqlalchemy.types.Integer,
                                      'percentage':
                                      sqlalchemy.types.Float(precision=10,
                                                             asdecimal=True),
                                      'quantity': sqlalchemy.types.BigInteger,
                                      'decade': sqlalchemy.types.Integer})
    else:
        todos_con_todos.to_sql('cruce_nombres_anios',
                               engine, flavor='mysql', index=False,
                               if_exists='append')

    # names_group = todos_con_todos.groupby('name')

    # Escribir jsons de nombres
    # for name, group in names_group:
    #     file_url = '../public/names/' + format_name(str(name)) + '.json'
    #     print(file_url)
    #     list_name = group.reset_index(
    #     )[['gender', 'year', 'percentage', 'quantity']].to_dict('records')

    #     with open(file_url, 'w') as fp:
    #         json.dump(list_name, fp)
