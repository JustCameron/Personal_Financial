# ensure the pandas package is imported
import pandas as pd
import time

#print("working")
# change path of csv file to where it is located on your computer
#path=r"C:\Users\Keemo Yen\Desktop\csvs\mjrmusgl.csv"
#path=r"csvs\rqgwlvcl.csv"
path= 'ReccomendationScripts\csvs\sql_to_.csv'

df=pd.read_csv(path)
df = df.dropna()
df = df.reset_index()
df=df.drop(['index'],axis=1)

df = df.drop(['Start_Date','Current_Date'],axis=1)



#user value removed from the last entry within the table:
user = df.tail(1)

#This function returns True if num is within (abs)20% of the refnum 
def compare(refnum,num):
    diff= abs(((refnum-num)/((refnum+num)/2))*100)
    if diff<=20:
        return True
    else:
        return False



#only using the first 2o values from the csv dataframe, you may change this as you wish.
head=df.head(20)


# This function scans the dataframe for users that meets the requirements of having within a 20% difference of income and
# expense of the current user.
def recommend(refvec1,vec2):
    global df
    indx=[]
    Monthly_Income=refvec1["Monthly_Income"] # user monthly income
    Monthly_Expense=refvec1["Monthly_Income"] #user monthly expense
    for index,row in vec2.iterrows():
        if  compare(row["Monthly_Income"],int(Monthly_Income)) and compare(row["Monthly_Expense"],int(Monthly_Expense)): # and row["Budget_Increase"]>0 :
            indx.append(index)
    df_filtered=vec2.filter(items=indx,axis=0)
    needs=int(df_filtered["Needs%"].mean())
    wants=int(df_filtered["Wants%"].mean())
    savings= 100 - (needs+wants)
    return needs,wants,savings


results = recommend(user,head)
# while results is None:
#     time.sleep(5)  # Adjust the sleep time based on your needs
#     print("Waiting for ans...")
#print(results)


# if __name__ == "__main__":
#     recommend(user,head)