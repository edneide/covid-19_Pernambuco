import numpy as np
import pandas as pd
import datetime
from colour import Color
from scipy.optimize import curve_fit


##############################################Fitting###########################################################



def n(t,k,x,t0):
    res = k*(t)**(x)*(np.exp(-(t)/t0))
    return res





def find_starting_point(l):
    pos=0
    while l[pos]==0:
        pos+=1
    return pos  





def print_date(date):
    import datetime
    return str(date.year)+'-'+str(date.month)+'-'+str(date.day)





def add_dates(str_date,num_days):
    import datetime
    date = datetime.datetime.strptime(str_date, '%Y-%m-%d').date()
    added_date=date+datetime.timedelta(days=num_days)
    new_str_date=print_date(added_date)
    return new_str_date




def uniform_date(L):
    import datetime
    new_l=[]
    for i in L:
        date = datetime.datetime.strptime(i, '%Y-%m-%d').date()
        new_str_date=print_date(date)
        new_l.append(new_str_date)
    return new_l    





def find_starting_point(l):
    pos=0
    while l[pos]==0:
        pos+=1
    return pos  





def create_projection_list(L,num_days):
    import datetime
    L=uniform_date(L)
    last_reported=L[-1]
    new_L=[]
    for i in L:
        new_L.append(i)
    
    for i in range(num_days):
        
        new_L.append(add_dates(last_reported,1))
        last_reported=new_L[-1]
    return new_L    


def find_fitting_state(State,proj_size=0,p0=0,k0=0,r0=0):
    #B=DF[ConfirmedColumn].values.tolist()
    #B=DF[ConfirmedColumn].values.tolist()
    Brasil_State=pd.read_csv('https://raw.githubusercontent.com/wcota/covid19br/master/cases-brazil-states.csv',)
    Only_States = Brasil_State[['state','totalCases','date']]
    Estado=pd.DataFrame()
    for i in range(len(Only_States['state'])):
        if Only_States.iloc[[i]]['state'].to_list()[0]==State:
            Estado=Estado.append(Only_States.iloc[[i]])
            
    By=Estado['totalCases'].to_list()
    Bx=[i for i in range(len(By))]
    B_dates=Estado['date'].to_list()
    #Bx=[i for i in range(len(By))]
    #B_dates=Df[find_starting_point(By):]['Date'].values.tolist()
    
    #By=B[find_starting_point(B):]
    def n(t,k0,p0,r0):
        res = k0*1/(1+(k0-p0/k0)*np.exp(-r0*t))
        return res
    
    if p0==0:
        if k0==0:
            if r0==0:
                params = curve_fit(n, Bx, By,maxfev=500000)
                [k0,p0,r0] = params[0]
    
    
    B_dates_proj=create_projection_list(B_dates,proj_size)
    Bx_proj=[i for i in range(len(B_dates_proj))]
    
    B_fit=[n(i,k0,p0,r0) for i in Bx_proj]
    
    for i in range(proj_size):
        By.append(np.nan)
    
    
    Bdf=pd.DataFrame()
    Bdf['Data']=B_dates_proj
    Bdf['Confirmado']=By
    Bdf['Fitting']=B_fit
    #Bdf.to_csv('COVID_Brazil_fitting_last_update_'+str(date.year)+'_'+str(date.month)+'_'+str(date.day)+'_1.csv')
    return Bdf

def find_fitting_city(State,City,proj_size=0,p0=0,k0=0,r0=0):
    #B=DF[ConfirmedColumn].values.tolist()
    #B=DF[ConfirmedColumn].values.tolist()
    Brasil_Cities=pd.read_csv('https://raw.githubusercontent.com/wcota/covid19br/master/cases-brazil-cities-time.csv')
    Only_Cities_Data=Brasil_Cities[['city','totalCases','date']]
    Cidade=pd.DataFrame()
    for i in range(len(Only_Cities_Data['city'])):
        if City+'/'+State in Only_Cities_Data.iloc[[i]]['city'].to_list()[0]:
            Cidade=Cidade.append(Only_Cities_Data.iloc[[i]])
    
    Cidade=Cidade.fillna(0)
    By=Cidade['totalCases'].to_list()
    Bx=[i for i in range(len(By))]
    B_dates=Cidade['date'].to_list()
    #Bx=[i for i in range(len(By))]
    #B_dates=Df[find_starting_point(By):]['Date'].values.tolist()
    
    #By=B[find_starting_point(B):]
    def n(t,k0,p0,r0):
        res = k0*1/(1+(k0-p0/k0)*np.exp(-r0*t))
        return res
    
    if p0==0:
        if k0==0:
            if r0==0:
                params = curve_fit(n, Bx, By)
                [k0,p0,r0] = params[0]
    
    
    B_dates_proj=create_projection_list(B_dates,proj_size)
    Bx_proj=[i for i in range(len(B_dates_proj))]
    
    B_fit=[n(i,k0,p0,r0) for i in Bx_proj]
    
    for i in range(proj_size):
        By.append(np.nan)
    
    
    Bdf=pd.DataFrame()
    Bdf['Data']=B_dates_proj
    Bdf['Confirmado']=By
    Bdf['Fitting']=B_fit
    #Bdf.to_csv('COVID_Brazil_fitting_last_update_'+str(date.year)+'_'+str(date.month)+'_'+str(date.day)+'_1.csv')
    return Bdf

def find_fitting(Date,Time_Series,proj_size=0):
    #B=DF[ConfirmedColumn].values.tolist()
    #B=DF[ConfirmedColumn].values.tolist()
    By=Time_Series[find_starting_point(Time_Series):]
    Bx=[i for i in range(len(By))]
    B_dates=Date[find_starting_point(Time_Series):]
    #Bx=[i for i in range(len(By))]
    #B_dates=Df[find_starting_point(By):]['Date'].values.tolist()
    
    #By=B[find_starting_point(B):]
    def n(t,k0,p0,r0):
        res = k0*1/(1+(k0-p0/k0)*np.exp(-r0*t))
        return res
    
    params = curve_fit(n, Bx, By,maxfev=500000)
    [k0,p0,r0] = params[0]
    
    
    B_dates_proj=create_projection_list(B_dates,proj_size)
    Bx_proj=[i for i in range(len(B_dates_proj))]
    
    B_fit=[n(i,k0,p0,r0) for i in Bx_proj]
    
    for i in range(proj_size):
        By.append(np.nan)
    
    
    
    
    Bdf=pd.DataFrame()
    Bdf['Data']=B_dates_proj
    Bdf['Confirmado']=By
    Bdf['Fitting']=B_fit
    #Bdf.to_csv('COVID_Brazil_fitting_last_update_'+str(date.year)+'_'+str(date.month)+'_'+str(date.day)+'_1.csv')
    return Bdf



def find_fitting_World(Data_type,Count=0,World_total=False,proj_size=0):
    #B=DF[ConfirmedColumn].values.tolist()
    #B=DF[ConfirmedColumn].values.tolist()
    if Data_type=='Dead':
        WORLD=pd.read_csv('https://raw.githubusercontent.com/CSSEGISandData/COVID-19/master/csse_covid_19_data/csse_covid_19_time_series/time_series_covid19_deaths_global.csv')
    elif Data_type=='Confirmed':
        WORLD=pd.read_csv('https://raw.githubusercontent.com/CSSEGISandData/COVID-19/master/csse_covid_19_data/csse_covid_19_time_series/time_series_covid19_confirmed_global.csv')
    elif Data_type=='Recovered':
        WORLD=pd.read_csv('https://raw.githubusercontent.com/CSSEGISandData/COVID-19/master/csse_covid_19_data/csse_covid_19_time_series/time_series_covid19_recovered_global.csv')
    del WORLD['Province/State']
    del WORLD['Lat']
    del WORLD['Long']
    WORLD = WORLD.set_index('Country/Region')
    if World_total==True:
        WORLD=WORLD.T
        WORLD['Total']=WORLD.sum(axis=1)
        WORLD2 =pd.DataFrame(data=WORLD['Total'])
        WORLD2
        Days={}
        for i in WORLD2.index.to_list():
            Days[i] = datetime.datetime.strptime(i, '%m/%d/%y').strftime('%Y-%m-%d')
        WORLD2=WORLD2.rename(index=Days)
        return find_fitting(WORLD2.index.to_list(),WORLD2['Total'].to_list(),proj_size)
    else:
        WORLD=WORLD.sort_values(by=[WORLD.columns.to_list()[-1]], ascending=False).T
        Top_Countries=WORLD[['Brazil','China','Germany','Iran','Italy','Spain','US','France']]
        Top_Countries=Top_Countries.groupby(by=Top_Countries.columns, axis=1).sum()
        Days={}
        for i in Top_Countries.index.to_list():
            Days[i] = datetime.datetime.strptime(i, '%m/%d/%y').strftime('%Y-%m-%d')
        Top_Countries=Top_Countries.rename(index=Days)
        Frame_List=[]
        Country=[]
        for j in Top_Countries.columns.to_list():
            Country.append(j)
            Frame_List.append(find_fitting(Top_Countries.index.to_list(),Top_Countries[j].to_list(),proj_size))
        #Bdf.to_csv('COVID_Brazil_fitting_last_update_'+str(date.year)+'_'+str(date.month)+'_'+str(date.day)+'_1.csv')
        return Country, Frame_List


    
year='{:02d}'.format(datetime.datetime.now().year)
month='{:02d}'.format(datetime.datetime.now().month)
day='{:02d}'.format(datetime.datetime.now().day)    

PE = find_fitting_state('PE',3)
Data = []
for j in PE['Data']:
    date = datetime.datetime.strptime(j, "%Y-%m-%d") #(OBS.:  "%Y-%m-%d" é o formato da data que tá entrando (Year-Month-Day, com os traços)
    DataFinal = datetime.datetime.strftime(date, "%d %b") #(OBS.: "%d %b" é o formato "Dia Mês_3primeiras_letras")
    Data.append(DataFinal)
PE['Data']=Data

PE.to_csv('Casos_confirmados_Pernambuco_Fitting.csv',index=False)
print('Casos_confirmados_Pernambuco_Fitting.csv')

World_Conf=find_fitting_World('Confirmed',proj_size=3)
for i in range(len(World_Conf[1])):
    for j in range(len(World_Conf[1])):
        data_i=World_Conf[1][i]['Data'].to_list()[0]
        data_j=World_Conf[1][j]['Data'].to_list()[0]
        if datetime.datetime.strptime(data_i, '%Y-%m-%d')<datetime.datetime.strptime(data_j, '%Y-%m-%d'):
            Aux2=World_Conf[0][i]
            World_Conf[0][i] = World_Conf[0][j]
            World_Conf[0][j] = Aux2
            
            Aux=World_Conf[1][i]
            World_Conf[1][i] = World_Conf[1][j]
            World_Conf[1][j] = Aux

for i in World_Conf[1]:
    Data = []
    for j in i['Data']:
        date = datetime.datetime.strptime(j, "%Y-%m-%d") #(OBS.:  "%Y-%m-%d" é o formato da data que tá entrando (Year-Month-Day, com os traços)
        DataFinal = datetime.datetime.strftime(date, "%d %b") #(OBS.: "%d %b" é o formato "Dia Mês_3primeiras_letras")
        Data.append(DataFinal)
    i['Data']=Data

for i in range(len(World_Conf[1])):
    World_Conf[1][i].to_csv('Casos_confirmados_'+World_Conf[0][i]+'_Fitting.csv',index=False)
    print('Casos_confirmados_'+World_Conf[0][i]+'_Fitting.csv')

    
names=['confirmed','deaths','recovered']

for j in names:

    World_Cont=pd.read_csv('https://raw.githubusercontent.com/CSSEGISandData/COVID-19/master/csse_covid_19_data/csse_covid_19_time_series/time_series_covid19_'+j+'_global.csv')
    del World_Cont['Province/State']
    del World_Cont['Lat']
    del World_Cont['Long']
    World_Cont = World_Cont.set_index('Country/Region')
    World_Cont=World_Cont.sort_values(by=[World_Cont.columns.to_list()[-1]], ascending=False).T
    Countries=World_Cont[['Brazil','China','France','Germany','Iran','Italy','Spain','US']]
    Countries=Countries.groupby(by=Countries.columns, axis=1).sum()
    Days={}
    for i in Countries.index.to_list():
        Days[i] = datetime.datetime.strptime(i, '%m/%d/%y').strftime("%d %b")
    Countries=Countries.rename(index=Days)

    Countries.to_csv(j+'_China_EUA_Irã_Itália_Espanha_Alemanha_Brasil_França.csv')
    print(j+'_China_EUA_Irã_Itália_Espanha_Alemanha_Brasil_França.csv')  

today2 = datetime.datetime.now()
today2 = datetime.datetime.strftime(today2, "%d %b")

from datetime import date, timedelta
yesterday = date.today() - timedelta(days=1)
yesterday = yesterday.strftime('%y-%m-%d')
today = date.today()
today = today.strftime('%y-%m-%d')
PE_by_cities = pd.read_csv('https://raw.githubusercontent.com/JTeodomiro/covid19PE/master/PE_Cidades_DATA_'+yesterday+'.csv',index_col=0)
PE_CITIES=pd.read_csv('https://raw.githubusercontent.com/edneide/covid-19_Pernambuco/master/covid-19_pernambuco.csv')
PE_Confirmed=pd.DataFrame()
for i in range(len(PE_CITIES['classificacao_final'])):
    if 'CONFIRMADO'in PE_CITIES.iloc[[i]]['classificacao_final'].to_list()[0]:
        PE_Confirmed=PE_Confirmed.append(PE_CITIES.iloc[[i]])
PE_Confirmed = PE_Confirmed[['classificacao_final','municipio']]
PE_TODAY=pd.DataFrame(data=PE_Confirmed['municipio'].value_counts())
PE_TODAY=PE_TODAY.T
if PE_by_cities.index.to_list()[-1] !=today2:
    PE_by_cities =PE_by_cities.append(pd.Series(name=today2))
    for i in PE_TODAY.columns:
        if i not in PE_by_cities.columns.to_list():
            PE_by_cities[i]=np.nan
        PE_by_cities[i][today2] = PE_TODAY[i].to_list()[0]


PE_by_cities.fillna(0).to_csv('PE_Cidades_DATA.csv')
print('PE_Cidades_DATA.csv')




import plotly
import plotly.graph_objects as go
from datetime import datetime, timedelta

def plot_pe_e_br(arq):
    
    d = datetime.today()
    d = d.strftime('%d/%m/%Y às %H:%M')

    df = pd.read_csv(arq)

    if arq == 'Casos_confirmados_Pernambuco_Fitting.csv':
        tit = 'Casos confirmados em Pernambuco'
    if arq == 'Casos_confirmados_Brazil_Fitting.csv':
        tit = 'Casos confirmados no Brasil'

    title_size = 9
    ticks_size = 8
    marker_size = 5

    Trace1 = go.Scatter(
        x = df['Data'],
        y = df['Confirmado'],
        yaxis="y",
        name = 'Confirmados',
        mode = 'lines+markers',
        marker = dict(
        size = marker_size,
        color = 'red',
        ),
        line = dict(
            color = 'red',
        )

    )

    Trace2 = go.Scatter(
        x = df['Data'],
        y = df['Fitting'],
        yaxis="y",
        name = 'Projeção',
        mode = 'lines+markers',
        opacity = 0.5,
        marker = dict(
        size = marker_size,
        color = 'gray',
        ),
        line = dict(
            color = 'gray',
        )
    )



    layout = go.Layout(
        width = 750,
        height = 500,
        showlegend = True,
        paper_bgcolor='white',
        plot_bgcolor='white',

        title = dict(text = tit, 
                     font = dict(size = title_size+2),
                     x = 0.5, 
                     xanchor = 'center', 
                     y=0.9),

        legend = dict(#x = 0.1, 
                      #y = 0.97, 
                      #traceorder = 'reversed',
                      font = dict(size = ticks_size+1) ),

        yaxis = dict(side = 'left',
                     title = 'Total de casos',
                     titlefont = dict(size = title_size),
                     tickfont = dict(size = ticks_size),
                     gridcolor='rgb(230,230,230)',),

        xaxis = dict(tickangle = -30, 
                     gridcolor='rgb(230,230,230)',
                     range = [-1, len(df['Data'])+1],
                     zeroline=False, 
                     nticks = 14, 
                     tickfont = dict(size = ticks_size)),

         shapes = [ dict(
                type = 'line',
                yref="y1",
                x0 = -1,
                y0 = 0,
                x1 = len(df['Data'])+1,
                y1 = 0,
                line = dict(width = 1, color = 'black')
         )],
        
        annotations=[dict(
            x=0,
            y=-0.2,
            showarrow=False,
            text="IRRD/PE. Fonte: https://raw.githubusercontent.com/wcota/covid19br/master/cases-brazil-states.csv<br>Dados atualizados em "+d+".",
            font = dict(size = ticks_size),
            xref="paper",
            yref="paper",
            xanchor = 'left',
            align='left',
            
        )]

    )


    fig = go.Figure(data = [Trace1, Trace2], layout = layout)

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
    

plot_pe_e_br('Casos_confirmados_Pernambuco_Fitting.csv')
plot_pe_e_br('Casos_confirmados_Brazil_Fitting.csv')

####################################  SEGUNDO  ####################################

list_of_arqs = ['Casos_confirmados_China_Fitting.csv',
                'Casos_confirmados_Brazil_Fitting.csv',
                'Casos_confirmados_France_Fitting.csv',
                'Casos_confirmados_Germany_Fitting.csv',
                'Casos_confirmados_Iran_Fitting.csv',
                'Casos_confirmados_Italy_Fitting.csv',
                'Casos_confirmados_Spain_Fitting.csv',
                'Casos_confirmados_US_Fitting.csv']

list_of_colors = ['lightcoral',
                  'orchid', 
                  'cyan', 
                  'cornflowerblue',
                  'mediumseagreen', 
                  'goldenrod',
                  'darkturquoise',  
                  'hotpink']

list_of_Traces = []

d = datetime.today()
d = d.strftime('%d/%m/%Y às %H:%M')

title_size = 9
ticks_size = 8
marker_size = 5
tit = 'Casos confirmados de COVID-19 no mundo'

for i in range(0, len(list_of_arqs)-1):
    df = pd.read_csv(list_of_arqs[i])
    Trace1 = go.Scatter(
        x = df['Data'],
        y = df['Confirmado'],
        yaxis="y",
        name = list_of_arqs[i][18:-12],
        mode = 'lines+markers',
        marker = dict(
        size = marker_size,
        color = list_of_colors[i],
        ),
        line = dict(
            color = list_of_colors[i],
        )

    )
    Trace2 = go.Scatter(
        x = df['Data'],
        y = df['Fitting'],
        yaxis="y",
        name = 'Projeção',
        showlegend = False,
        mode = 'lines+markers',
        opacity = 0.5,
        marker = dict(
        size = marker_size,
        color = 'gray',
        ),
        line = dict(
            color = 'gray',
        )
    )
    list_of_Traces = list_of_Traces + [Trace1, Trace2]
    
# O último Trace.
df1 = pd.read_csv(list_of_arqs[-1])

Trace1 = go.Scatter(
    x = df1['Data'],
    y = df1['Confirmado'],
    yaxis="y",
    name = list_of_arqs[-1][18:-12],
    mode = 'lines+markers',
    marker = dict(
    size = marker_size,
    color = list_of_colors[-1],
    ),
    line = dict(
        color = list_of_colors[-1],
    )

)
Trace2 = go.Scatter(
    x = df1['Data'],
    y = df1['Fitting'],
    yaxis="y",
    name = 'Projeção',
    mode = 'lines+markers',
    opacity = 0.5,
    marker = dict(
    size = marker_size,
    color = 'gray',
    ),
    line = dict(
        color = 'gray',
    )
)

list_of_Traces = list_of_Traces + [Trace1, Trace2]

layout = go.Layout(
    width = 750,
    height = 500,
    showlegend = True,
    paper_bgcolor='white',
    plot_bgcolor='white',

    title = dict(text = tit, 
                 font = dict(size = title_size+2),
                 x = 0.5, 
                 xanchor = 'center', 
                 y=0.9),

    legend = dict(#x = 0.1, 
                  #y = 0.97, 
                  #traceorder = 'reversed',
                  font = dict(size = ticks_size+1) ),

    yaxis = dict(side = 'left',
                 title = 'Total de casos',
                 titlefont = dict(size = title_size),
                 tickfont = dict(size = ticks_size),
                 gridcolor='rgb(230,230,230)',),
    

    xaxis = dict(tickangle = -30, 
                 gridcolor='rgb(230,230,230)',
                 nticks = 14, 
                 tickfont = dict(size = ticks_size)),


     shapes = [ dict(
            type = 'line',
            yref="y1",
            x0 = -4,
            y0 = 0,
            x1 = len(df1['Data'])+4,
            y1 = 0,
            line = dict(width = 1, color = 'black')
     )],
    
    annotations=[dict(
            x=0,
            y=-0.2,
            showarrow=False,
            text="IRRD/PE. Fonte: JHU CSSE/JHU APL/ESRI Living Atlas Team <br>Dados atualizados em "+d+".",
            font = dict(size = ticks_size),
            xref="paper",
            yref="paper",
            xanchor = 'left',
            align='left',
            
        )]

)


fig = go.Figure(data = list_of_Traces, layout = layout)

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

####################################  TERCEIRO  ####################################

def plot_death_rec(arq):
    d = datetime.today()
    d = d.strftime('%d/%m/%Y às %H:%M')
    df_dr = pd.read_csv(arq, index_col = 0)
    df_dr = df_dr[['China']+list(df_dr.drop('China', axis = 1))]
    
    list_of_colors = ['lightcoral',
                      'orchid', 
                      'cyan', 
                      'cornflowerblue',
                      'mediumseagreen', 
                      'goldenrod',
                      'darkturquoise',  
                      'hotpink']

    title_size = 9
    ticks_size = 8
    marker_size = 5

    if arq == 'deaths_China_EUA_Irã_Itália_Espanha_Alemanha_Brasil_França.csv':
        tit = 'Casos de óbito por COVID-19 no mundo'
        
    if arq == 'recovered_China_EUA_Irã_Itália_Espanha_Alemanha_Brasil_França.csv':
        tit = 'Casos de recuperação da COVID-19 no mundo'

    list_of_traces = []


    for i in range(len(list(df_dr))):
        trace = go.Scatter(
            x = df_dr.index,
            y = df_dr[list(df_dr)[i]],
            name = list(df_dr)[i],
            mode = 'lines+markers',
            marker = dict(
            size = marker_size,
            color = list_of_colors[i],
            ),
            line = dict(
                color = list_of_colors[i],
            )
        )
        list_of_traces = list_of_traces + [trace]

    layout = go.Layout(
        width = 750,
        height = 500,
        showlegend = True,
        paper_bgcolor='white',
        plot_bgcolor='white',

        title = dict(text = tit, 
                     font = dict(size = title_size+2),
                     x = 0.5, 
                     xanchor = 'center', 
                     y=0.9),

        legend = dict(#x = 0.1, 
                      #y = 0.97, 
                      #traceorder = 'reversed',
                      font = dict(size = ticks_size+1) ),

        yaxis = dict(type = 'log',
                     side = 'left',
                     title = 'Total de casos',
                     #range = [0, 6],
                     titlefont = dict(size = title_size),
                     tickfont = dict(size = ticks_size),
                     gridcolor='rgb(230,230,230)',),


        xaxis = dict(tickangle = -30, 
                     gridcolor='rgb(230,230,230)',
                     nticks = 14, 
                     range = [-1, len(df_dr.index)+1],
                     tickfont = dict(size = ticks_size)),
        
        annotations=[dict(
            x=0,
            y=-0.2,
            showarrow=False,
            text="IRRD/PE. Fonte: JHU CSSE/JHU APL/ESRI Living Atlas Team <br>Dados atualizados em "+d+".",
            font = dict(size = ticks_size),
            xref="paper",
            yref="paper",
            xanchor = 'left',
            align='left',
            
        )]

    )


    fig = go.Figure(data = list_of_traces, layout = layout)

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
    
plot_death_rec('deaths_China_EUA_Irã_Itália_Espanha_Alemanha_Brasil_França.csv')
plot_death_rec('recovered_China_EUA_Irã_Itália_Espanha_Alemanha_Brasil_França.csv')

####################################  QUARTO  ####################################

df_pe = pd.read_csv('PE_Cidades_DATA.csv')
df_pe = df_pe.set_index('Data')

red = Color("red")
purple = Color("purple")
colors = list(purple.range_to(red,len(list(df_pe))))
colors = [str(i) for i in colors]

title_size = 9
ticks_size = 8
marker_size = 5
tit = 'Casos de COVID-19 de cidades em Pernambuco'

d = datetime.today()
d = d.strftime('%d/%m/%Y às %H:%M')

list_of_traces_pe = []


for i in range(len(list(df_pe))):
    trace = go.Scatter(
        x = df_pe.index,
        y = df_pe[list(df_pe)[i]],
        name = list(df_pe)[i],
        mode = 'lines+markers',
        marker = dict(
        size = marker_size,
        color = colors[i],
        ),
        line = dict(
            color = colors[i],
        )
    )
    list_of_traces_pe = list_of_traces_pe + [trace]

layout = go.Layout(
    width = 750,
    height = 450,
    showlegend = True,
    paper_bgcolor='white',
    plot_bgcolor='white',

    title = dict(text = tit, 
                 font = dict(size = title_size+2),
                 x = 0.5, 
                 xanchor = 'center', 
                 y=0.85),

    legend = dict(font = dict(size = ticks_size) ),

    yaxis = dict(side = 'left',
                 title = 'Total de casos',
                 #range = [0, 6],
                 titlefont = dict(size = title_size),
                 tickfont = dict(size = ticks_size),
                 gridcolor='rgb(230,230,230)',),


    xaxis = dict(tickangle = -30, 
                 gridcolor='rgb(230,230,230)',
                 nticks = 14, 
                 range = [-1, len(df_pe.index)+1],
                 tickfont = dict(size = ticks_size)),
    
    shapes = [ dict(
            type = 'line',
            yref="y1",
            x0 = -1,
            y0 = 0,
            x1 = len(df_pe.index)+1,
            y1 = 0,
            line = dict(width = 1, color = 'black')
     )],
    annotations=[dict(
            x=0,
            y=-0.2,
            showarrow=False,
            text="IRRD/PE. Fonte: Secretaria Estadual de Saúde - Governo de Pernambuco <br>Dados atualizados em "+d+".",
            font = dict(size = ticks_size),
            xref="paper",
            yref="paper",
            xanchor = 'left',
            align='left',
            
        )]

)


fig = go.Figure(data = list_of_traces_pe, layout = layout)

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


#############################################Death and New Cases##########################################################


import pandas as pd
import plotly
import plotly.graph_objects as go
from datetime import datetime, timedelta

df = pd.read_csv('https://raw.githubusercontent.com/wcota/covid19br/master/cases-brazil-states.csv')
df2 = df.drop(['country', 'city', 'deaths','totalCases'], axis = 1)
df2 = df2.sort_values(by = 'state', ascending = False)
df2 = df2.set_index(list(df2)[1])
c = list(dict.fromkeys(list(df2.index)))
c.remove('TOTAL')
df2_T2 = df2.drop(c, axis = 0)
df2_T2 = df2_T2.rename(index = {'TOTAL': 'BRASIL'})
df2 = df2.drop(['TOTAL'], axis = 0)

tit = 'Casos novos confirmados no Brasil'  


date = datetime.strptime(df2['date'].min(), "%Y-%m-%d")
a = date - timedelta(days=1)
fd = datetime.strftime(a, "%Y-%m-%d")

date = datetime.strptime(df2['date'].max(), "%Y-%m-%d")
b = date + timedelta(days=1)
ld = datetime.strftime(b, "%Y-%m-%d")

delta = b - a

d = datetime.today()
d = d.strftime('%d/%m/%Y às %H:%M')


text_size = 6
tick_size = 8
title_size = 10
marker_size = 15

data = go.Scatter(
    x = df2[list(df2)[0]],
    y = list(df2.index),
    text = df2[list(df2)[1]],
    textfont = dict(size = text_size),
    name = 'none',
    mode = 'markers+text',
    hoverlabel = dict(namelength = 0),
    marker = dict(
    symbol = 'square',
    size = marker_size,
    showscale=True,
    colorbar = dict(
        tickangle = -90,
        thickness = 12,
        y=0.5,
        len = 0.6,
        title = 'Número de casos novos',
        titleside = 'right',
        tickfont = dict(size = tick_size),
        titlefont = dict(size = title_size),
    ),
    color=df2[list(df2)[1]],
    colorscale=[[0, 'beige'],[0.1, 'yellow'], [0.6, 'red'], [1, 'brown']],
    reversescale = False,
    opacity=0.9,
    cauto= False,
    )

)

Trace2 = go.Scatter(
    x = df2_T2[list(df2_T2)[0]],
    y = list(df2_T2.index),
    text = df2_T2[list(df2_T2)[1]],
    textfont = dict(color = 'white', size = text_size),
    hoverlabel = dict(namelength = 0),
    yaxis="y2",
    xaxis="x",
    mode = 'markers+text',
    marker = dict(
    symbol = 'square',
    size = marker_size,
    opacity = 0.9,
    color = 'gray',
    ),
)


    
layout = go.Layout(
    showlegend = False,
    title = dict(text = tit, x = 0.5, y = 0.89, xanchor = 'center'),
    titlefont = dict(size = title_size +2),
    height = 720,
    width = 21*(delta.days),
    xaxis = dict(
        nticks = delta.days+1, 
        range=[fd,ld],
        tickangle = 45,
        tickfont = dict(size = tick_size)
    ),
    yaxis = dict( 
        range=[-1,27],
        title = dict(text = 'Unidades da Federação'),
        titlefont=dict(size = title_size), 
        tickfont = dict(size = tick_size), 
        domain=(0.1, 0.944)
    ),
    yaxis2 = dict(
        range=[-1,1],
        tickfont = dict(size = tick_size), 
        domain=(0.945,1 ),
    ),
    
    annotations=[
        dict(
            x=0,
            y=-0.02,
            showarrow=False,
            text="IRRD/PE. Fonte: https://raw.githubusercontent.com/wcota/covid19br/master/cases-brazil-states.csv<br>Dados atualizados em "+d+".",
            font = dict(size = text_size),
            xref="paper",
            yref="paper",
            xanchor = 'left',
            align='left',
            
        )
    ]
    
)

fig = go.Figure(data = [data, Trace2], layout = layout)

tit_file = tit+'.html'
tit_file = tit_file.replace(' ','_')
fig.write_html(tit_file) 
print(tit_file)

    
tit_image = tit+'.png'
tit_image = tit_image.replace(':','')
tit_image = tit_image.replace(' ','_')
    
fig.write_image(tit_image,scale =2)
print(tit_image)


df = pd.read_csv('https://raw.githubusercontent.com/wcota/covid19br/master/cases-brazil-states.csv')
df3 = df.drop(['country', 'city', 'newCases', 'totalCases'], axis = 1)
df3 = df3.sort_values(by = 'state', ascending = False)
df3 = df3.set_index(list(df3)[1])
df3['UF'] = list(df3.index)

states = list(df3['UF'].drop_duplicates())
df3 = df3.sort_values(by = list(df3)[0], ascending = True)
df3.index = list(range(0,len(df3)))

for i in list(df3['UF'].drop_duplicates()):
    index_list = list(df3[df3['UF'] == i].index)
    x = False
    for j in range(0,len(index_list)):
        if df3.loc[index_list[j]][1] > 0 and x == False:
            x = j
    if x == False:
        x = len(index_list)-1
    df3 = df3.drop(index_list[0:x], axis = 0)
    
df4 = df3.T
df4 = df4.drop(['UF', 'date'], axis = 0)

for i in list(df3['UF'].drop_duplicates()):
    index_list = list(df3[df3['UF'] == i].index)[::-1]
    for j in range(0,len(index_list)-1):
        df4[index_list[j]] = df4[index_list[j]] - df4[index_list[j+1]]
        if df4[index_list[j]][0] < 0:
            df4[index_list[j]] = [0]

df3['deaths'] = df4.T

df3 = df3.sort_values(by = 'UF', ascending = False)
df3 = df3.set_index('UF')

c = list(dict.fromkeys(list(df3.index)))
c.remove('TOTAL')
df_T2 = df3.drop(c, axis = 0)
df_T2 = df_T2.rename(index = {'TOTAL': 'BRASIL'})
df3 = df3.drop(['TOTAL'], axis = 0)

tit = 'Mortes por COVID-19 confirmadas no Brasil por data'

date = datetime.strptime(df3['date'].min(), "%Y-%m-%d")
a = date - timedelta(days=1)
fd = datetime.strftime(a, "%Y-%m-%d")

date = datetime.strptime(df3['date'].max(), "%Y-%m-%d")
b = date + timedelta(days=1)
ld = datetime.strftime(b, "%Y-%m-%d")

delta = b - a

d = datetime.today()
d=d.strftime('%d/%m/%Y às %H:%M')

text_size = 6
tick_size = 8
title_size = 10
marker_size = 15

data = go.Scatter(
    x = df3[list(df3)[0]],
    y = list(df3.index),
    text = df3[list(df3)[1]],
    textfont = dict(size = text_size),
    name = 'none',
    mode = 'markers+text',
    hoverlabel = dict(namelength = 0),
    marker = dict(
    symbol = 'square',
    size = marker_size,
    showscale=True,
    colorbar = dict(
        tickangle = -90,
        thickness = 12,
        y=0.5,
        len = 0.6,
        title = 'Número de mortes',
        titleside = 'right',
        tickfont = dict(size = tick_size),
        titlefont = dict(size = title_size),
    ),
    color=df3[list(df3)[1]],
    colorscale=[[0, 'yellow'], [1.0, 'red']],
    reversescale = False,
    opacity=0.9,
    cauto= False,
    )

)

Trace2 = go.Scatter(
    x = df_T2[list(df_T2)[0]],
    y = list(df_T2.index),
    text = df_T2[list(df_T2)[1]],
    hoverlabel = dict(namelength = 0),
    yaxis="y2",
    xaxis="x",
    mode = 'markers+text',
    marker = dict(
    symbol = 'square',
    size = marker_size,
    opacity = 0.9,
    color = 'gray',
    ),
    textfont = dict(color = 'white', size = text_size)
)
    
layout = go.Layout(
    showlegend = False,
    title = dict(text = tit, x = 0.5, y = 0.89, xanchor = 'center'),
    titlefont = dict(size = title_size+2),
    height = 700,
    width = 75+21*(delta.days),
    xaxis = dict(
        nticks = delta.days+1, 
        range=[fd,ld],
        tickangle = 45,
        tickfont = dict(size = tick_size)
    ),
    yaxis = dict( 
        range=[-1,27],
        title = dict(text = 'Unidades da Federação'),
        titlefont=dict(size = title_size), 
        tickfont = dict(size = tick_size), 
        domain=(0.1, 0.944)
    ),
    yaxis2 = dict(
        range=[-1,1],
        tickfont = dict(size = tick_size), 
        domain=(0.945,1 ),
    ),
    
    annotations=[dict(
            x=0,
            y=-0.02,
            showarrow=False,
            text="IRRD/PE. Fonte: https://raw.githubusercontent.com/wcota/covid19br/master/cases-brazil-states.csv<br>Dados atualizados em "+d+".",
            font = dict(size = text_size),
            xref="paper",
            yref="paper",
            xanchor = 'left',
            align='left',
    )]
    
)

fig = go.Figure(data = [data, Trace2], layout = layout)

tit_file = tit+'.html'
tit_file = tit_file.replace(' ','_')
fig.write_html(tit_file) 
print(tit_file)

    
tit_image = tit+'.png'
tit_image = tit_image.replace(':','')
tit_image = tit_image.replace(' ','_')

fig.write_image(tit_image,scale =2)
print(tit_image)



#################################################Curvature############################################



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















