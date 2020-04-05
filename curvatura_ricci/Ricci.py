#!/usr/bin/env python
# coding: utf-8

# In[ ]:





import pandas as pd
import numpy as np
import networkx as nx
from datetime import datetime, timedelta
import plotly
import plotly.graph_objects as go



def formanCurvature(G, verbose=False):

    for (v1, v2) in G.edges():
        if G.is_directed():
            v1_nbr = set(list(G.predecessors(v1)) + list(G.successors(v1)))
            v2_nbr = set(list(G.predecessors(v2)) + list(G.successors(v2)))
        else:
            v1_nbr = set(G.neighbors(v1))
            v1_nbr.remove(v2)
            v2_nbr = set(G.neighbors(v2))
            v2_nbr.remove(v1)
        face = v1_nbr & v2_nbr

        prl_nbr = (v1_nbr | v2_nbr) - face


        G[v1][v2]["formanCurvature"] = len(face) + 2 - len(prl_nbr)
        if verbose:
            print("Source: %s, target: %d, Forman-Ricci curvature = %f  " % (v1, v2, G[v1][v2]["formanCurvature"]))


    for n in G.nodes():
        fcsum = 0  
        if G.degree(n) != 0:
            for nbr in G.neighbors(n):
                if 'formanCurvature' in G[n][nbr]:
                    fcsum += G[n][nbr]['formanCurvature']

            
            G.nodes[n]['formanCurvature'] = fcsum / G.degree(n)
        if verbose:
            print("node %d, Forman Curvature = %f" % (n, G.nodes[n]['formanCurvature']))
    if verbose:
        print("Forman curvature computation done.")

    return G



def corr_dataframe(data):
    corr_df = data.corr(method='pearson') 
    corr_df.reset_index()
    return corr_df


def graph_2(df,t0,t1,e=2):
    M=np.array(corr_dataframe(df[t0-1:t1+1]))
    F=[[M[i][j] if M[i][j]>1-e else 0 for i in range(len(M))] for j in range(len(M))]
    G=nx.from_numpy_array(np.array(F))
    return G


def remove_selfloops(G):
    for i in G.nodes():
        if G.has_edge(i,i):
            G.remove_edge(i,i)

            

def my_range(start, end, step):
    while start <= end:
        yield start
        start += step



def analisys_ricci_frame_no_filtre_mundial(df,tim_wind,mov_avg):
    LIST_PERID=[]
    for j in df[6:].index:
        start=str(j)
        date = datetime.strptime(start, "%m/%d/%y") #(OBS.:  "%Y-%m-%d" é o formato da data que tá entrando (Year-Month-Day, com os traços)
        Datastart = datetime.strftime(date, "%d %b") #(OBS.: "%d %b" é o formato "Dia Mês_3primeiras_letras")
        LIST_PERID.append(Datastart)
    
    LIST_SUM_EPIC=list(df[6:].sum(axis=1))
    LIST_RICCI=[]

    for i in my_range(1,len(df)-tim_wind+1,mov_avg):
        
        G=graph_2(df,i,i+tim_wind - 2,e=2)
        remove_selfloops(G)
        H=formanCurvature(G).copy()
        
        coef_ricci=np.mean(list(nx.get_edge_attributes(H,'formanCurvature').values()))
        LIST_RICCI.append(coef_ricci)
        
    LIST_RICCI=np.array(LIST_RICCI)
    LIST_RICCI=np.nan_to_num(LIST_RICCI,nan = 2.0)
    return (list(LIST_RICCI), LIST_SUM_EPIC, LIST_PERID)





def analisys_ricci_frame_no_filtre_brasil(df,tim_wind,mov_avg):
    LIST_RICCI=[]
    LIST_SUM_EPIC=[]
    LIST_PERID=[]
    for i in DF[6:].index:
        start=str(i)
        date = datetime.strptime(start, "%Y-%m-%d") #(OBS.:  "%Y-%m-%d" é o formato da data que tá entrando (Year-Month-Day, com os traços)
        Datastart = datetime.strftime(date, "%d %b") #(OBS.: "%d %b" é o formato "Dia Mês_3primeiras_letras")
        LIST_PERID.append(Datastart)

    for i in my_range(1,len(df)-tim_wind+1,mov_avg):
        
        G=graph_2(df,i,i+tim_wind - 2,e=2)
        remove_selfloops(G)
        H=formanCurvature(G).copy()
        
        coef_ricci=np.mean(list(nx.get_edge_attributes(H,'formanCurvature').values()))
        LIST_RICCI.append(coef_ricci)
    
        sum_of_epdimic_wind=df[i-1:i+tim_wind-1].sum().sum()
        LIST_SUM_EPIC.append(sum_of_epdimic_wind)
        
        
    LIST_RICCI=np.array(LIST_RICCI)
    LIST_RICCI=np.nan_to_num(LIST_RICCI,nan = 2.0)
    return (list(LIST_RICCI), LIST_SUM_EPIC, LIST_PERID)


url='https://raw.githubusercontent.com/CSSEGISandData/COVID-19/master/csse_covid_19_data/csse_covid_19_time_series/time_series_covid19_confirmed_global.csv'

df = pd.read_csv(url)

df1=df.set_index('Country/Region')

df1=df1.T

df1=df1.drop(['Province/State','Lat','Long'])

df1=df1.fillna(0)

df1=df1.astype('int32')

df2=df1.groupby(level=0, axis=1).sum()

(X,Y,Z)=analisys_ricci_frame_no_filtre_mundial(df2,7,1)



df3=pd.DataFrame({'forman_ricci':X,'sum_epic':Y,'periodo':Z})

df3.to_csv('forman_ricci_mundial.csv',index=False)


url2='https://raw.githubusercontent.com/wcota/covid19br/master/cases-brazil-states.csv'

df4=pd.read_csv(url2)

df5 = df4.drop(['country', 'city','deaths','totalCases'], axis = 1) 
df5 = df5.sort_values(by = 'state', ascending = False)
df5 = df5.set_index(list(df5)[1])
df5 = df5.drop(['TOTAL'], axis = 0)
df5['UF'] = list(df5.index)

ds = datetime.strptime(df5['date'].min(), "%Y-%m-%d")
de = datetime.strptime(df5['date'].max(), "%Y-%m-%d")

dd = [datetime.strftime(ds + timedelta(days=x), "%Y-%m-%d") for x in range((de-ds).days + 1)]
DF = pd.DataFrame(columns = dd)

for i in list(dict.fromkeys(list(df5.index))):
    UF=list(dict.fromkeys(list(df5.index)))
    UF.remove(i)
    df6 = df5.drop(UF, axis = 0)
    df6 = df6.sort_values(by = list(df6)[0], ascending = True)
    df6 = df6.set_index('date')
    df6 = df6.rename(columns = {list(df6)[0]:df6['UF'][0]})
    df6 = df6.drop('UF', axis = 1)
    df6 = df6.T
    DF = DF.append(df6, sort=True)

DF = DF.fillna(0)
DF=DF.T

(A,B,C)=analisys_ricci_frame_no_filtre_brasil(DF,7,1)

df7=pd.DataFrame({'forman_ricci':A,'sum_epic':B,'periodo':C})

df7.to_csv('forman_ricci_brasil.csv',index=False)


print('forman_ricci_mundial.csv')
print('forman_ricci_brasil.csv')


def Plot_Forman_ricci(df_text):
    df = pd.read_csv(df_text)
    d = datetime.today()
    d = d.strftime('%d/%m/%Y às %H:%M')
    
    if df_text == 'forman_ricci_brasil.csv':
        prefix = 'COVID-19 Brasil: ' 
        font_date = "IRRD/PE. Fonte: raw.githubusercontent.com/wcota/covid19br/master/cases-brazil-states.csv <br>Dados atualizados em "+d+".",
    if df_text == 'forman_ricci_mundial.csv':
        prefix = 'COVID-19 Mundial: '
        font_date = "IRRD/PE. Fonte: JHU CSSE/JHU APL/ESRI Living Atlas Team <br>Dados atualizados em "+d+".",

    title_size = 9
    ticks_size = 8
    marker_size = 5


    Trace1 = go.Scatter(
        x = df['periodo'],#list_x,
        y = df['forman_ricci'],
        yaxis="y1",
        name = 'Média da Forman-Ricci Curvature',
        mode = 'lines+markers',
        marker = dict(
        size = marker_size,
        color = 'darkblue',
        ),
        line = dict(
            color = 'darkblue'
        )
    )

    Trace2 = go.Scatter(
        x = df['periodo'],#list_x,
        y = df['sum_epic'],
        yaxis="y2",
        name = 'Casos confirmados de COVID-19 no período',
        mode = 'lines+markers',
        marker = dict(
        size = marker_size,
        color = 'darkorange',
        ),
        line = dict(
            color = 'darkorange'
        ),
    )


    tit = prefix + "Total de casos versus Curvatura de Forman-Ricci"

    layout = go.Layout(
        width = 700,
        height = 500,
        showlegend = True,
        paper_bgcolor='white',
        plot_bgcolor='white',

        title = dict(text = tit, 
                     font = dict(size = title_size+2),
                     x = 0.5, 
                     xanchor = 'center', 
                     y=0.85),

        legend = dict(x = 0.0, 
                      y = 0.97, 
                      traceorder = 'reversed',
                      font = dict(size = ticks_size+1) ),

        yaxis1 = dict(side = 'left',
                      tickfont = dict(size = ticks_size),
                      gridcolor='rgb(230,230,230)',
                      domain=(0.05, 0.49)),

        yaxis2 = dict(side = 'right', 
                      tickfont = dict(size = ticks_size), 
                      gridcolor='rgb(230,230,230)',
                      domain=(0.51, 0.95)),

        xaxis = dict(tickangle = -30, 
                     gridcolor='rgb(230,230,230)',
                     range = [-1, len(df['periodo'])+1],#range = [-1, len(list_x)+1],
                     zeroline=False, 
                     title = 'Tempo (7 dias)', 
                     titlefont = dict(size = title_size),
                     tickfont = dict(size = ticks_size)),

         shapes = [ dict(
                type = 'line',
                yref="y2",
                x0 = -1,
                y0 = 0,
                x1 = len(df['periodo'])+1,#len(list_x)+1,
                y1 = 0,
                line = dict(width = 1, color = 'black')
         ),
                   dict(
                type = 'line',
                yref="y1",
                x0 = -1,
                y0 = 0,
                x1 = len(df['periodo'])+1,#len(list_x)+1,
                y1 = 0,
                line = dict(width = 1,  color = 'black')
         )],

    )


    fig = go.Figure(data = [Trace1, Trace2], layout = layout)
    
    if df_text == 'forman_ricci_brasil.csv':
        fig.add_annotation(
            x=0,
            y=-0.25,
            showarrow=False,
            text="IRRD/PE. Fonte: https://raw.githubusercontent.com/wcota/covid19br/master/cases-brazil-states.csv<br>Dados atualizados em "+d+".",
            font = dict(size = ticks_size),
            xref="paper",
            yref="paper",
            xanchor = 'left',
            align='left',
            
        )
    if df_text == 'forman_ricci_mundial.csv':
        fig.add_annotation(
            x=0,
            y=-0.25,
            showarrow=False,
            text="IRRD/PE. Fonte: JHU CSSE/JHU APL/ESRI Living Atlas Team <br>Dados atualizados em "+d+".",
            font = dict(size = ticks_size),
            xref="paper",
            yref="paper",
            xanchor = 'left',
            align='left',
            
        )

    tit_file = tit+'.html'
    tit_file = tit_file.replace(':','')
    tit_file = tit_file.replace(' ','_')
    
    fig.write_html(tit_file) 
    print(tit_file)
        
    tit_image = tit+'.png'
    tit_image = tit_image.replace(':','')
    tit_image = tit_image.replace(' ','_')
    
    fig.write_image(tit_image,scale =2)
    print(tit_image)

Plot_Forman_ricci('forman_ricci_brasil.csv')
Plot_Forman_ricci('forman_ricci_mundial.csv')

