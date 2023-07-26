import pandas as pd
import time


users2 = {   
        'Records': '4',
        'Account_ID': '7',
        'Month': '23/3/2022 0:00', #format needs to change.
        'Beginning_Balance': 90000.68,
        'Current_Balance': 1107672.54,
        'Monthly_Income': 82421.54,
        'Monthly_Expense': 80896.27,
        'Wants%': 27.02,
        'Needs%': 40.52,
        'Savings%': 32.46,
        'Min_Goal': 57050.12,
        'Max_Goal': 1136145.39,
        'Increase_Decrease': 4.08
    }


def compare(refnum,num,val):
    diff= abs(((refnum-num)/((refnum+num)/2))*100)
    if diff<=val:
        return True
    else:
        return False

def recommend_ratios(val):  #dictionary passes here

    path= 'ReccomendationScripts\csvs\sql_to_.csv'
    df=pd.read_csv(path)
    df = df.dropna()
    df = df.reset_index()
    df=df.drop(['index'],axis=1) #should this be records?

    df = df.drop(['Month'],axis=1)  
    

    #user value is the last entry within the table if tail was used
    user = val #df.tail(1)
    lendf= len(df)-20
    head=df.head(lendf)
    #print(lendf)
    
    refvec1=user 
    vec2=head
    
    indx=[]
    ids=[]
    countr =0
    Monthly_Income=refvec1["Monthly_Income"] # user monthly income
    Monthly_Expense=refvec1["Monthly_Expense"] #user monthly expense
    #wants needz savings variable
    user_needs=refvec1["Needs%"] 
    user_wants =refvec1["Wants%"] 
    user_savings=refvec1["Savings%"] 

    for index,row in vec2.iterrows():
        if  compare(row["Monthly_Income"],int(Monthly_Income),20) and compare(row["Monthly_Expense"],int(Monthly_Expense),20)and row["Increase_Decrease"]>0 :
            if compare(row["Needs%"],int(user_needs),20) and compare(row["Wants%"],int(user_wants),20) and compare(row["Savings%"],int(user_savings),20):
                indx.append(index)
                ids.append(row["Account_ID"])
            #print(index)
    if indx != []:
        print(len(indx))
        testA = vec2[vec2['Account_ID'].isin(ids)]
        #for index,row in vec2.iterrows():

        

        """
        if compare(row["Needs%"],int(user_needs),20) and compare(row["Wants%"],int(user_wants),20) and compare(row["Wants%"],int(Monthly_Expense),20):

        
        #testB = testA[testA['Increase_Decrease'] >= 0.00]
        
        for index,row in testB.iterrows():
            if  compare(row["Monthly_Income"],int(Monthly_Income),20) and compare(row["Monthly_Expense"],int(Monthly_Expense),20) and row["Increase_Decrease"]>0 :
                countr +=1
        """ 

        print(len(testA))
        #print(len(testB))
        #print(countr)
        df_filtered=vec2.filter(items=indx,axis=0)
        needs=int(df_filtered["Needs%"].mean())
        wants=int(df_filtered["Wants%"].mean())
        savings= 100 - (needs+wants)
        print('needs,wants,savings')
        return needs,wants,savings
    else:
        return (50,30,20)
    
results = recommend_ratios(users2)
print(results)