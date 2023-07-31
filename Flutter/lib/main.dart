
import 'dart:io';
//import 'package:tuple/tuple.dart';
import 'dart:developer';
import 'dart:math';
import 'dart:ui';
import 'package:collection/collection.dart';
import 'package:intl/intl.dart';
import 'package:pie_chart/pie_chart.dart' as pc;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:window_manager/window_manager.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:syncfusion_flutter_sliders/sliders.dart';
import 'package:syncfusion_flutter_charts/charts.dart' hide LabelPlacement;

//for back end
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';




void main() async{
  WidgetsFlutterBinding.ensureInitialized(); //Everything here controls size of app when resized
  await windowManager.ensureInitialized();
  if (Platform.isWindows) {
    WindowManager.instance.setMinimumSize(const Size(768, 736));

  }
  runApp(MyApp());
}    

class MyApp extends StatelessWidget {
  //const MyApp({super.key});
  MyApp({Key? key}) : super(key: key);

  final DataConnection flaskConnect = DataConnection('http://127.0.0.1:5000'); 
  //create an instance here to call its functions in other classes


  static MyApp of(BuildContext context) { //required to run DataConnection calls
    return context.findAncestorWidgetOfExactType<MyApp>()!;
  }
  
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MyAppState(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false, //removes the debug tag
        title: 'Flutter Demo',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          fontFamily: 'Open Sans',
        ),
        home: MyHomePage(),
      ),
    );
  }
}

class MyAppState extends ChangeNotifier {
  //Lists
  var transactionList = [];
  var expenseList = [];
  var expenseCostList = [];
  var incomeList = [];
  var incomeValueList = [];
  var expenseTypeList = [];
  var rankList = [];
  var expenseFreqList = [];
  var incomeFreqList = [];
  var expenseidList = [];
  var incomeidList = [];
  var expensedatelist = [];
  List<String> creditCardList = <String>['Mastercard', 'Scotia', 'Sagicor', 'Paypal'];
  List<String> marriedOrSingleList = <String>['Single', 'Married'];
  List<String> wantORneed = <String>['Want', 'Need'];
  List<String> rankTiers = <String>['T1', 'T2', 'T3'];
  List<String> expenseFrequency = <String>['One-Time', 'Monthly'];
  List<String> incomeFrequency = <String>['One-Time', 'Monthly'];
  //User Inputs
  double annualincome = 0.00;
  double livingexpense = 0.00;
  double subscriptionexpense = 0.00;
  double mortgage = 0.00;
  double annualinterest = 0.00;
  double savingsgoal = 0.00;
  double balance = 0.00;
  double beginbalance = 0.00;
  double budget = 0.00;
  double spent = 0.00;
  double income = 0.00;
  var creditcard = "Mastercard  ";
  var singlemarried = "Single";
  var wantORneedchoice = "Want";
  var ranks = "T1";
  var expenseFreq = "One-Time";
  var incomeFreq = "One-Time";
  DateTime selectedDate = DateTime.now();
  String expenseName = "";
  String incomeName = "";
  String expenseID = ""; ////Yassso
  String incomeID = "";
  double expenseCost = 0.00;
  double incomeValue = 0.00;
  String fullexpense = "";
  double usd = 0.00;
  double jmd = 0.00;
  double jmdToUSD = 0.00;
  bool? check1 = false;
  bool? check2 = false;
  bool? check3 = false;
  bool? check4 = false;
  bool? check5 = false;
  bool? check6 = false;
  bool? check7 = false;
  bool? check8 = false;
  bool? check9 = false;
  bool? check10 = false;
  bool? check11 = false;
  bool? check12 = false;
  bool? valid_user = false;
  bool notcurrentmonthchecker = true;
  bool shownextmonth = false;
  bool nexmonthdemo = false;
  //Icons
  Icon type = Icon(
    Icons.store_mall_directory,
    color: Colors.blueAccent,
  );
  Icon wantneedIcon = Icon(
    Icons.store_mall_directory,
    color: Colors.blueAccent,
  );
  Icon rankIcon = Icon(
    Icons.looks_one,
    color: Color.fromARGB(255, 180, 166, 35),
  );
  Icon frequencyIcon = Icon(
    Icons.one_x_mobiledata_outlined,
    color: Colors.blueGrey,
  );
  Icon incomeFrequencyIcon = Icon(
    Icons.one_x_mobiledata_outlined,
    color: Colors.blueGrey,
  );
  //Miscs
  bool showHelpList = false; // the help button showing the list or not conditional
  bool showIcon = true; // help button icon conditional
  bool showCurrentTrajectoryInfo = false; // whether explaination for current trajectory appears or not
  bool showOptimalTrajectoryInfo = false; // whether explaination for optimal trajectory appears or not
  bool currentTrajectoryIcon = true;
  bool optimalTrajectoryIcon = true;
    var createSpace = 0; // used for login to keep things in bound
  double currExpCost = 0.00;
  double currIncEarn = 0.00;
  var currExpName = "";
  var currIncName = "";
  var username = "User"; // USER'S USERNAME
  var chosenMargin = 20; // USER'S CHOSEN SLIDER VALUE
  double sliderValue = 20.00; // SLIDER VALUE

  //WANTS/NEEDS/SAVINGS PERCENTAGES
  double wantPercentage = 0.00;
  double needPercentage = 0.00;
  double savingsPercentage = 0.00;

  double recommendedWantsPercentage= 0.00;
  double recommendedNeedsPercentage = 0.00;
  double recommendedSavingsPercentage = 0.00;

  double increaseDecreasePercent = 0.00;


  //Stuff For Jon
  double wantTotal = 0.00; // Keep track of total spent on wants - For Jon
  double needTotal = 0.00; // Keep track of total spent on needs - For Jon

  //(appState.wantTotal + appState.needTotal + ((appState.savingsPercentage/100) * appState.income)) - appState.income

  //Details for signup()
  String newUserEmail = "";
  String newUserPassword = "";

  //For Dashboard Dates
  var currMonth = 0;
  var currYear = 0;

  //For Report
  var repMonth = 0;
  var repYear = 0;
  double monthBeginAmt = 0.00;

  void removeExpense(exp){ //Remove clicked Expense from Expense List
    expenseTypeList.remove(expenseList.indexOf(exp));
    rankList.remove(expenseList.indexOf(exp));
    expenseFreqList.remove(expenseList.indexOf(exp));
    expenseList.remove(exp);
    //   appState.balance -= appState.expenseCost; // subtract expense from balance
    // appState.spent += appState.expenseCost; // add expense cost to spent
    balance += double.parse(exp.replaceAll(RegExp(r'[^0-9,.]'),'')); // add removed expense cost to balance [replaceAll is used here to only get the numbers from the String]
    spent -= double.parse(exp.replaceAll(RegExp(r'[^0-9,.]'),'')); // subtract removed expense cost from spent [replaceAll is used here to only get the numbers from the String]
    print (double.parse(exp.replaceAll(RegExp(r'[^0-9,.]'),'')));
    notifyListeners();
  }
     
  
   removeIncome(inc){ //Remove clicked Income from Income List
    incomeFreqList.remove(incomeList.indexOf(inc));
    incomeList.remove(inc);
    balance -= double.parse(inc.replaceAll(RegExp(r'[^0-9,.]'),'')); // minus removed income from balance [replaceAll is used here to only get the numbers from the String]
    income -= double.parse(inc.replaceAll(RegExp(r'[^0-9,.]'),'')); // subtract removed income [replaceAll is used here to only get the numbers from the String]
    //print (double.parse(exp.replaceAll(RegExp(r'[^0-9,.]'),'')));
    notifyListeners();
  }

  double getExpenseCost(exp){ //Get only Expense Cost for specific Expense
    var where = expenseList.indexOf(exp);
    currExpCost = double.parse(expenseList[where].replaceAll(RegExp(r'[^0-9,.]'),''));
    // notifyListeners();
    return currExpCost;
  }

  String getExpenseName(exp){ //Get only Expense Name for specific Expense
    var where = expenseList.indexOf(exp);
    currExpName = expenseList[where].replaceAll(RegExp(r'[^a-z,^A-Z]'),'');
    // notifyListeners();
    return currExpName;
  }

  double getIncomeEarning(inc){ //Get only Earnings for specific Income Channel
    var where = incomeList.indexOf(inc);
    currIncEarn = double.parse(incomeList[where].replaceAll(RegExp(r'[^0-9,.]'),''));
    // notifyListeners();
    return currIncEarn;
  }

  String getIncomeName(inc){ //Get only Income Name for specific Income Channel
    var where = incomeList.indexOf(inc);
    currIncName = incomeList[where].replaceAll(RegExp(r'[^a-z,^A-Z]'),'');
    // notifyListeners();
    return currIncName;
  }
    // GET CURRENT MONTH
  String returnMonth(DateTime date) {
    return new DateFormat.MMMM().format(date);
  }
    void clearAllLists() {
    transactionList.clear();
    expenseList.clear();
    incomeList.clear();
    expenseTypeList.clear();
    rankList.clear();
    expenseFreqList.clear();
    incomeFreqList.clear();
    expenseidList.clear();
    incomeidList.clear();
    //expensedatelist.clear();
    balance=0;
    spent=0;
    wantTotal=0;
    needTotal=0;
    income=0;
    beginbalance=0;
    wantPercentage = 0.00;
    needPercentage = 0.00;
    savingsPercentage = 0.00;
    recommendedWantsPercentage= 0.00;
    recommendedNeedsPercentage = 0.00;
    recommendedSavingsPercentage = 0.00;
    increaseDecreasePercent = 0.00;
    expenseCost = 0.00;
    incomeValue = 0.00;
    valid_user = false;
    monthBeginAmt = 0.00;
    
  }
   void getMonthData(monthdata) {
    //var populate = MyApp.of(context).flaskConnect.fetchData('month/data');
    // SENDS TO BACKEND
      
      var data = monthdata;
      //gotttopop.then((data){
      var expseList = data['expense'];
      print('expseList: $expseList');
      if (expseList != []){
        List<Map<String, dynamic>> copyOfExpenseList = List.from(expseList);
        for (var expq in copyOfExpenseList) {
          var id = expq['id'];
          var name = expq['name'];   
          var cost = double.parse(expq['cost']); 
          var tier = expq['tier'];               
          var expenseType = expq['expense_type']; 
          var frequency = expq['frequency']; 
          var date = expq['date']; 

          expenseList.add(("$name ${cost.toStringAsFixed(2)}")); //Interpolation
          expenseCostList.add((name, cost)); // Separate list for calcualtions
          expenseidList.add((id.toString())); //Adds id to list //Havent tested yet
          expensedatelist.add((date.toString()));
          
          //CALCULATION: To change
          //Create colunmn for balance and add value here. WYUEWI
          balance -= cost; // subtract expense from balance
          spent += cost; // add expense cost to spent
          
            //Different WANT/NEED Symbols
            if (expenseType == "Want") {
              wantTotal += cost; //To change
              Padding(
                padding: const EdgeInsets.only(left: 5),
                child: wantneedIcon = Icon(
                  Icons.store_mall_directory,
                  color: Colors.blueAccent,
                ),
              );
            
            } else {
              needTotal += cost;
              Padding(
                padding: const EdgeInsets.only(left: 5),
                child: wantneedIcon = Icon(
                  Icons.house,
                  color: Colors.green
                  ),
              );
            }
          type = wantneedIcon;
          expenseTypeList.add(type);

          //Different EXPENSE RANKINGS Symbols
          if (tier == "T1") {
            Padding(
              padding: const EdgeInsets.only(left: 5, top: 3),
              child: rankIcon = Icon(
                Icons.looks_one,
                color: Color.fromARGB(255, 180, 166, 35),
              ),
            );                        
          } 
          else if (tier == "T2") {
              Padding(
              padding: const EdgeInsets.only(left: 5, top: 3),
              child: rankIcon = Icon(
                Icons.looks_two,
                color: Colors.orange
                ),
            );
          } 
          else if (tier == "T3") {
                Padding(
                padding: const EdgeInsets.only(left: 5, top: 3),
                child: rankIcon = Icon(
                Icons.looks_3,
                color: Colors.red
                ),
                );
          }
          rankIcon = rankIcon;
          rankList.add(rankIcon);

          if (frequency == "One-Time"){  //Different INCOME FREQUENCY Symbols
            Padding(
              padding: const EdgeInsets.only(left: 5, top: 3),
              child: frequencyIcon = Icon(
                Icons.one_x_mobiledata_outlined,
                color: Colors.blueGrey,
              ),
            );
            }
          else{ 
            Padding(
              padding: const EdgeInsets.only(left: 5),
              child: frequencyIcon = Icon(
                Icons.calendar_month,
                color: Colors.blueGrey
                ),
            );
          }
          expenseFreqList.add(frequencyIcon);




      }//end for 
    }//end if-empty 
      

      var incmList = data['income'];
      print('IncmList: $incmList');
      if(incmList != []){
        List<Map<String, dynamic>> copyOfincmList = List.from(incmList);
        for (var incq in copyOfincmList) {
          var id = incq['id'];
          var name = incq['name'];   
          var monthlyEarning = double.parse(incq['monthly_earning']); 
          var frequency = incq['frequency']; 
          var date = incq['date']; 
          print(monthlyEarning);

          incomeList.add(("$name ${monthlyEarning.toStringAsFixed(2)}")); //Interpolation
          incomeValueList.add((name, monthlyEarning)); // Separate list for calcualtions
          incomeidList.add((id.toString()));
          

          //CALCULATION: To change
          balance += monthlyEarning; // adds income to remaining balance
          income += monthlyEarning; // add income value to income
          
          if (frequency == "One-Time"){  //Different INCOME FREQUENCY Symbols
            Padding(
              padding: const EdgeInsets.only(left: 5, top: 3),
              child: incomeFrequencyIcon = Icon(
                Icons.one_x_mobiledata_outlined,
                color: Colors.blueGrey,
              ),
            );
            }
          else{ 
            Padding(
              padding: const EdgeInsets.only(left: 5),
              child: incomeFrequencyIcon = Icon(
                Icons.calendar_month,
                color: Colors.blueGrey
                ),
            );
          }
          incomeFreqList.add(incomeFrequencyIcon);
          // CALCULATE WANT/NEED/SAVINGS PERCENTAGES [want/need amounts in relation to total income] To Change
          wantPercentage = wantTotal / income;
          needPercentage = needTotal / income;
          savingsPercentage = 100 - (wantPercentage*100 + needPercentage*100);

         
        }
      }
      //});  //end first populate

      double bwants = 0.00;
      double bneeds = 0.00; 
      double bsavings = 0.00;
      double rwants = 0.00;
      double rneeds = 0.00;
      double rsavings = 0.00;
      double increasedecrease = 0.00; 
      double monthBegBalance = 0.00;
      var currDate = '';
        
      //var recPopulate = MyApp.of(context).flaskConnect.fetchData('splits');
      //recPopulate.then((data){
      var splitList = data['splits'];
      //print('Message: $splitList');
      if (splitList != []){  //add to the function months yzm
        List<Map<String, dynamic>> copyOfsplitList = List.from(splitList);
        for (var splits in copyOfsplitList) {
        
          bwants = double.parse(splits['wants']); 
          bneeds = double.parse(splits['needs']); 
          bsavings = double.parse(splits['savings']); 
          rwants = double.parse(splits['rwants']); 
          rneeds = double.parse(splits['rneeds']); 
          rsavings = double.parse(splits['rsavings']);
          increasedecrease = double.parse(splits['increase_decrease']); 
          currDate = splits['date']; 
          monthBegBalance = double.parse(splits['beginning_balance']); //UNCOMMENT
          //beginbalance = monthBegBalance; OR
          monthBeginAmt = monthBegBalance;


          print('Splits in loop: $rwants');
          recommendedWantsPercentage = rwants;
          recommendedNeedsPercentage = rneeds;
          recommendedSavingsPercentage = rsavings;
          increaseDecreasePercent = increasedecrease;
          // wantPercentage = bwants;
          // needPercentage = bneeds;
          // savingsPercentage = bsavings; change
          //if (increasedecrease == 0.00){increaseDecreasePercent = 10.00;}
          
        }} //End for and if 
      //});
  }

}
class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  @override
  Widget build(BuildContext context) {
    Widget page;
    page = ImagePage();

    Widget loginpage;
    Widget imagepage;

    loginpage = LoginPage();
    imagepage = ImagePage();

    return Row(
        children: <Widget>[
          Expanded( //Split page
            flex: 4, //Set how much % of screen page takes up
            child: Container(
              color: Colors.green,
              child: loginpage, //Load Login Page
            ),
          ),
          Expanded( //Split page
            flex: 6, //Set how much % of screen page takes up
            child: Container(
              color: Colors.yellow,
              child: imagepage, //Load Image Page
            ),
          ),
        ],
      );
  }
}
class LoginPage extends StatefulWidget {
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    Widget page;
    
    Future<void> handleLogin(credentials,DataConnection flaskConnect) async{
          // Show loading indicator before the API call
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext context) {
              return Center(
                child: CircularProgressIndicator(),
              );
            },
          );
          final sentCredentials= await MyApp.of(context).flaskConnect.sendData('login', credentials);
          var data = sentCredentials;
          appState.valid_user =false;
          //sentCredentials.then((data){   
            if (data['message'] == 'Success'){
              String tkn = data['access_token'];
              MyApp.of(context).flaskConnect.saveTokenToSharedPreferences(tkn);
              
              //Gets the current month and year to use for dashboard switching and reprt
              if (data['goal_amount'] != null){ 
              appState.savingsgoal = double.parse(data['goal_amount']); 
              }
              appState.currMonth = data['month'];
              appState.repMonth = data['month'];
              
              appState.currYear = data['year'];
              appState.repYear = data['year'];
              appState.username = data['username'];
              //gets staring balance of user
              double bBalance = double.parse(data['beg_balance']); //gets beginning_balance of the current month
              //print("The ID sent $id");
              appState.clearAllLists();
              appState.balance += bBalance; //Dis correct?
              appState.beginbalance += bBalance; //would change each month
              print("The Beginning balnce sent ${appState.beginbalance}");
              appState.valid_user =true;
          }
          else{
                  
          // Hide the loading indicator in case of an error
          Navigator.of(context).pop();
          }
          //});
          
            
          
          if (appState.valid_user==true){
          //Recieves data from database and adds to respective lists
          var populate = await MyApp.of(context).flaskConnect.fetchData('populate');
          var data2 = populate;
          
          //populate.then((data){
            var expenseList = data2['expense'];
            print('ExpenseList: $expenseList');
            if (expenseList != [] || expenseList!=null){
              for (var expense in expenseList) {
                var id = expense['id'];
                var name = expense['name'];   
                var cost = num.parse(expense['cost']); 
                var tier = expense['tier'];               
                var expenseType = expense['expense_type']; 
                var frequency = expense['frequency']; 
                var date = expense['date']; 

                appState.expenseList.add(("$name ${cost.toStringAsFixed(2)}")); //Interpolation
                appState.expenseCostList.add((name, cost)); // Separate list for calcualtions
                appState.expenseidList.add((id.toString())); //Adds id to list //Havent tested yet
                appState.expensedatelist.add((date.toString()));
                
                //CALCULATION: To change
                //Create colunmn for balance and add value here. WYUEWI
                appState.balance -= cost; // subtract expense from balance
                appState.spent += cost; // add expense cost to spent
                
                  //Different WANT/NEED Symbols
                  if (expenseType == "Want") {
                    appState.wantTotal += cost; //To change
                    Padding(
                      padding: const EdgeInsets.only(left: 5),
                      child: appState.wantneedIcon = Icon(
                        Icons.store_mall_directory,
                        color: Colors.blueAccent,
                      ),
                    );
                  
                  } else {
                    appState.needTotal += cost;
                    Padding(
                      padding: const EdgeInsets.only(left: 5),
                      child: appState.wantneedIcon = Icon(
                        Icons.house,
                        color: Colors.green
                        ),
                    );
                  }
                appState.type = appState.wantneedIcon;
                appState.expenseTypeList.add(appState.type);

                //Different EXPENSE RANKINGS Symbols
                if (tier == "T1") {
                  Padding(
                    padding: const EdgeInsets.only(left: 5, top: 3),
                    child: appState.rankIcon = Icon(
                      Icons.looks_one,
                      color: Color.fromARGB(255, 180, 166, 35),
                    ),
                  );                        
                } 
                else if (tier == "T2") {
                    Padding(
                    padding: const EdgeInsets.only(left: 5, top: 3),
                    child: appState.rankIcon = Icon(
                      Icons.looks_two,
                      color: Colors.orange
                      ),
                  );
                } 
                else if (tier == "T3") {
                      Padding(
                      padding: const EdgeInsets.only(left: 5, top: 3),
                      child: appState.rankIcon = Icon(
                      Icons.looks_3,
                      color: Colors.red
                      ),
                      );
                }
                appState.rankIcon = appState.rankIcon;
                appState.rankList.add(appState.rankIcon);

                if (frequency == "One-Time"){  //Different INCOME FREQUENCY Symbols
                  Padding(
                    padding: const EdgeInsets.only(left: 5, top: 3),
                    child: appState.frequencyIcon = Icon(
                      Icons.one_x_mobiledata_outlined,
                      color: Colors.blueGrey,
                    ),
                  );
                  }
                else{ 
                  Padding(
                    padding: const EdgeInsets.only(left: 5),
                    child: appState.frequencyIcon = Icon(
                      Icons.calendar_month,
                      color: Colors.blueGrey
                      ),
                  );
                }
                appState.expenseFreqList.add(appState.frequencyIcon);




            }//end for 
          }//end if-empty 
            

            var incomeList = data2['income'];
            print('IncomeList: $incomeList');
            if(incomeList != [] || incomeList!=null){
              for (var income in incomeList) {
                var id = income['id'];
                var name = income['name'];   
                var monthlyEarning = num.parse(income['monthly_earning']); 
                var frequency = income['frequency']; 
                var date = income['date']; 

                appState.incomeList.add(("$name ${monthlyEarning.toStringAsFixed(2)}")); //Interpolation
                appState.incomeValueList.add((name, monthlyEarning)); // Separate list for calcualtions
                appState.incomeidList.add((id.toString()));
                

                //CALCULATION: To change
                appState.balance += monthlyEarning; // adds income to remaining balance
                appState.income += monthlyEarning; // add income value to income
                
                if (frequency == "One-Time"){  //Different INCOME FREQUENCY Symbols
                  Padding(
                    padding: const EdgeInsets.only(left: 5, top: 3),
                    child: appState.incomeFrequencyIcon = Icon(
                      Icons.one_x_mobiledata_outlined,
                      color: Colors.blueGrey,
                    ),
                  );
                  }
                else{ 
                  Padding(
                    padding: const EdgeInsets.only(left: 5),
                    child: appState.incomeFrequencyIcon = Icon(
                      Icons.calendar_month,
                      color: Colors.blueGrey
                      ),
                  );
                }
                appState.incomeFreqList.add(appState.incomeFrequencyIcon);
                // CALCULATE WANT/NEED/SAVINGS PERCENTAGES [want/need amounts in relation to total income] To Change
                appState.wantPercentage = appState.wantTotal / appState.income;
                appState.needPercentage = appState.needTotal / appState.income;
                appState.savingsPercentage = 100 - (appState.wantPercentage*100 + appState.needPercentage*100);
              }
            }
          //});  //end first populate

          double bwants = 0.00;
          double bneeds = 0.00; 
          double bsavings = 0.00;
          double rwants = 0.00;
          double rneeds = 0.00;
          double rsavings = 0.00;
          double increasedecrease = 0.00; 
          var currDate = '';
          double monthBegBalance =0.00;
          
          var recPopulate = await MyApp.of(context).flaskConnect.fetchData('splits');
          
          //recPopulate.then((data){
            var data3 = recPopulate;
          
            var splitList = data3['splits'];
            //print('Message: $splitList');
            if (splitList != []){
              for (var splits in splitList) {
              
                bwants = double.parse(splits['wants']); 
                bneeds = double.parse(splits['needs']); 
                bsavings = double.parse(splits['savings']); 
                rwants = double.parse(splits['rwants']); 
                rneeds = double.parse(splits['rneeds']); 
                rsavings = double.parse(splits['rsavings']);
                increasedecrease = double.parse(splits['increase_decrease']); 
                currDate = splits['date']; 
                monthBegBalance = double.parse(splits['beginning_balance']);

                print('Splits in loop: $rwants');
                appState.recommendedWantsPercentage = rwants;
                appState.recommendedNeedsPercentage = rneeds;
                appState.recommendedSavingsPercentage = rsavings;
                appState.increaseDecreasePercent = increasedecrease;
                appState.monthBeginAmt = monthBegBalance;
                if (increasedecrease == 0.00){
                    appState.increaseDecreasePercent = 10.00;
                    
                    print('IncreaseDecrease: ${appState.increaseDecreasePercent}');

                }
              }} //End for and if 
          //});

          print('Splits OutsideLoop: ${appState.recommendedSavingsPercentage}');
            Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => MainPage()), //Goes to main page
        );
          }
          else{}
      
    }

    // USER PASSWORD AND EMAIL INPUT GETTERS
    final emailController = TextEditingController();
    final passwordController = TextEditingController();

    final emailformKey = GlobalKey<FormState>();
    final passwordformKey = GlobalKey<FormState>();

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
        children: [

          SizedBox(height: 10,), //Adds a bit of space between top bar to image
          Container(
            padding: EdgeInsets.all(30), //Dictates size of image container i.e. image size basically
            width: 80,
            decoration: BoxDecoration( //Adds logo image to container
              image: DecorationImage(
                alignment: Alignment.topCenter,
                fit: BoxFit.fill,
                image: AssetImage('assets/images/temp_logo_1.png'), //Image
              ),
            ),
          ),


          SizedBox(height:20,), //The Welcome Text and space between Welcome and Logo
          Padding(
            padding: const EdgeInsets.only(
              left: 30,
              right: 20,
              top: 0,
              bottom: 5,
            ),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text('Welcome!', 
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontFamily: 'Noto Sans',
                fontSize: 40,
              ),
              ),
              ),
          ),
          

          Padding(          // The text and padding between sub text and username
            padding: const EdgeInsets.only(
              left: 30,
              right: 20,
              top: 10,
              bottom: 5,
            ),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text("Glad to see you're back!", 
              style: TextStyle(
                //fontWeight: FontWeight.bold,
                fontFamily: 'Noto Sans',
                fontSize: 25,
              ),
              )
              ),
          ),


          Padding(          // The text and padding between Email and Email Text Field
            padding: const EdgeInsets.only(
              left: 30,
              right: 20,
              top: 40,
              bottom: 5,
            ),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text("E-Mail", 
              textAlign: TextAlign.left,)
              ),
          ),
          

          Padding(                          //E-MAIL TEXT FIELD
            padding: const EdgeInsets.only(
              left: 30,
              right: 20,
              top: 0,
              bottom: 20,
            ),
              child: Form( // Form for validation
                key: emailformKey,
                child: TextFormField(
                  validator: (value){ // Value = What the user inputs
                    if (value!.isEmpty) {
                      return 'Email cannot be empty'; // Send this back as Error
                    }
                    else if(!value.contains('@') || !value.contains('.')){ // If there is no number in password
                      return 'Please enter a valid email address. E.g. example@example.com';
                    }
                    return null; // If everything is valid, send back 'null' meaning no errors
                  },
                  onChanged: (newValue) { // Validate in realtime
                    emailformKey.currentState!.validate();
                  },

                  controller: emailController, // For Jon
                  
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                floatingLabelBehavior: FloatingLabelBehavior.never, //Removes annoying floating label text on click
                labelText: 'E-Mail',
                labelStyle: TextStyle( //Changes label Text Font
                  fontFamily: 'Nato Sans'
                ),
                hintText: 'Enter valid E-Mail',
                hintStyle: TextStyle( //Changes hint Text Font
                  fontFamily: 'Nato Sans'
                ),
              ),
            ),
          ),
        ),


          Padding(          // The text and padding between Password and Password Text Field
            padding: const EdgeInsets.only(
              left: 30,
              right: 20,
              top: 15,
              bottom: 5,
            ),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text("Password", 
              textAlign: TextAlign.left,
              )
              ),
          ),


          Padding(                          //PASSWORD TEXT FIELD
            padding: const EdgeInsets.only(
              left: 30,
              right: 20,
              top: 0,
              bottom: 0,
            ),
              child: Form( // Form for validation
                key: passwordformKey,
                child: TextFormField(
                  validator: (value){ // Value = What the user inputs
                    if (value!.isEmpty) {
                      return 'Password cannot be empty'; // Send this back as Error
                    }
                    else if(num.tryParse(value.replaceAll(RegExp(r'[^0-9,.]'), '')) == null){ // If there is no number in password
                      return 'Password must contain a number';
                    }
                    return null; // If everything is valid, send back 'null' meaning no errors
                  },
                  onChanged: (newValue) { // Validate in realtime
                    passwordformKey.currentState!.validate();
                  },

                  controller: passwordController, // For Jon

              obscureText: true, //Adds the Asteriks for Password confidentiality
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.lock_open, color: Colors.grey),
              
                border: OutlineInputBorder(),
                floatingLabelBehavior: FloatingLabelBehavior.never, //Removes annoying floating label text on click
                labelText: 'Password',
                labelStyle: TextStyle( //Changes Font
                  fontFamily: 'Nato Sans'
                ),
                hintText: 'Enter your Password',
                hintStyle: TextStyle( //Changes Font
                  fontFamily: 'Nato Sans'
                ),
              ),
            ),
          ),
        ),

          Padding(                          //Remember Me and Forgot Password
            padding: const EdgeInsets.only(
              left: 30,
              right: 20,
              top: 1,
              bottom: 5,
            ),
            child: Row( //
              children: [

              //Remember Me Section

                Checkbox(
                  value: false,
                  onChanged: (null)
                  ),   
                Text('Remember Me',
                  style: TextStyle(fontFamily: 'Nato Sans'),
                ),

              //Forgot Password Section

              Expanded( //Huuuuuge gap for aesthetics
                child: Align( //Put that boy all the way on the right
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: (){ 
                      // Do thing after they press this
                    },
                    style: ButtonStyle(
                      overlayColor: MaterialStateProperty.all(Colors.transparent), //Removes highlight when hovering on 'Forgot Password'
                    ),
                
                    child: Text( //Do password text with underline (really tedius way to do without clipping underline with text)
                      "Forgot Password?",
                      style: TextStyle(
                        shadows: [
                          Shadow(
                              color: Theme.of(context).colorScheme.primary, //colour of text (it's a shadow, ik, but it works)
                              offset: Offset(0, -1))
                        ],
                        color: Colors.transparent,
                        decoration:
                        TextDecoration.underline,
                        decorationColor: Theme.of(context).colorScheme.primary,
                        decorationThickness: 1,
                      ),
                    ),
                  ),
                ),
              ),

              ],

            ),
          ),


          Padding(                          //LOGIN BUTTON
            padding: const EdgeInsets.only(
              left: 30,
              right: 20,
              top: 0,
              bottom: 5,
            ),
            child: SizedBox( //Box inwhich button is kept within to control size
              width: 500,
              height: 50,
              child: OutlinedButton(
                style: OutlinedButton.styleFrom( //Style button to make it more rectangular but with rounded edges
                  backgroundColor: Theme.of(context).colorScheme.onBackground,
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                  side: BorderSide.none, //Removes border colour from button
                ),
                
                onPressed: (){  //After clicking Login
                  // This is the Error Handling Jon
                  if (!emailformKey.currentState!.validate()) { // Checks if Email is Valid, then does something
                    appState.createSpace = 1; // I use this later just to make some space for errors
                  }
                  if (!passwordformKey.currentState!.validate()) { // Checks if Password is Valid, then does something
                    appState.createSpace = 1; // I use this later just to make some space for errors
                  }
                  // If Email and Password are valid, Login
                  if (emailformKey.currentState!.validate() && passwordformKey.currentState!.validate()){
                       //var login = MyApp.of(context).flaskConnect.fetchData('login');
                  //final sendCredentials= {'email': 'bob@gmail.com', 'password': 'pass123'};
                    final sendCredentials= {'email': emailController.text, 'password': passwordController.text};
                    handleLogin(sendCredentials,MyApp.of(context).flaskConnect);
                  
                }//if valid_user 
                else{ //invalid user

                  // Navigator.push(
                  //   context,
                  //   MaterialPageRoute(builder: (context) => LoginPage()), //Goes to main page
                  //   );
                  }
                }, //OnPressedClosure
                child: Text('Login')),
            ),
          ),


          Padding(                          //OR Text with Horizontal Lines
            padding: const EdgeInsets.only(
              left: 30,
              right: 20,
              top: 1,
              bottom: 5,
            ),
            child: Row( //OR with Horizontal Text using Expanded Row Dividers
              children: [
              Expanded(
                  child: Divider()
              ),       

              Text(" OR "),        

              Expanded(
                  child: Divider()
              ),
              ],

            ),
          ),
          

          Padding(                          //ALTERNATIVE LOGIN BUTTON
            padding: const EdgeInsets.only(
              left: 30,
              right: 20,
              top: 0,
              bottom: 5,
            ),
            child: SizedBox( //Box inwhich button is kept within to control size
              width: 500,
              height: 50,
              child: OutlinedButton(
                style: OutlinedButton.styleFrom( //Style button to make it more rectangular but with rounded edges
                  backgroundColor: Theme.of(context).colorScheme.secondary,
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                  side: BorderSide.none, //Removes border colour from button
                ),
                onPressed: (){}, 
                child: Text('Login with Google')),
            ),
          ),



          Padding(                          //Don't have an account? Sign up!
            padding: const EdgeInsets.only(
              left: 30,
              right: 20,
              top: 1,
              bottom: 5,
            ),
            child: Row( // 'Don't have an account?' Sign Up Text and Button
              children: [
              Text("Don't have an account?"),     
              TextButton(
                onPressed: (){ 
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => SignUpPage()), //Goes to sign up page
                  );
                  // Do thing after they press this
                },
                style: ButtonStyle(
                  overlayColor: MaterialStateProperty.all(Colors.transparent), //Removes highlight when hovering on 'Forgot Password'
                ),

                child: Text( //Do password text with underline (really tedius way to do without clipping underline with text)
                  "Sign up!",
                  style: TextStyle(
                    shadows: [
                      Shadow(
                          color: Theme.of(context).colorScheme.primary, //colour of text (it's a shadow, ik, but it works)
                          offset: Offset(0, -1))
                    ],
                    color: Colors.transparent,
                    decoration:
                    TextDecoration.underline,
                    decorationColor: Theme.of(context).colorScheme.primary,
                    decorationThickness: 1,
                  ),
                ),
              ),   

              ],

            ),
          ),
          if (appState.createSpace == 1) // Create extra space for error messages
              SizedBox(height: 40,)

        ],
      ),
    ),
    );
    
  }
}
class ImagePage extends StatelessWidget{

  @override
  Widget build(BuildContext context) {
    
    var theme = Theme.of(context);
    var appState = context.watch<MyAppState>();

    return Container(
      width: MediaQuery.of(context).size.width, // Fit image to screen size
      height: MediaQuery.of(context).size.height,
      decoration: BoxDecoration(
        image: DecorationImage(
          fit: BoxFit.fill, //Fit image to screen size
          image: AssetImage('assets/images/temp_wallpaper_1.5.png'), //Image
        ),
      ),
    );

  }
}
class MainPage extends StatefulWidget{
  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int chosenIndex = 0;
  @override
  Widget build(BuildContext context) {
  var appState = context.watch<MyAppState>();
  Widget? page;
  switch (chosenIndex) {
    case 0:
      page = HomeMenu();
      break;
    case 1:
      page = DashboardPage();
      break;
    case 2:
      page = BudgetPage(); //Budget Planner Page
      break;
    case 3:
      page = SettingsPage();
      break;
    case 4:
      page = null; //Logout
      break;
    default:
      throw UnimplementedError('no widget for $chosenIndex');
  }
    return Scaffold(
      body: SafeArea(
        child: Row(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(
                left: 0,
                right: 0,
                top: 10,
                bottom: 0,
              ),
              child: NavigationRail(
                extended: false,
                labelType: NavigationRailLabelType.selected,
                destinations: [
                  NavigationRailDestination( // HOME
                    icon: Icon(Icons.home_outlined),
                    selectedIcon: Icon(Icons.home_rounded),
                    label: Text('Home'),
                  ),
                  NavigationRailDestination( //DASHBOARD
                    icon: Icon(Icons.space_dashboard_outlined),
                    selectedIcon: Icon(Icons.space_dashboard),
                    label: Text('Dashboard'),
                  ),
                  NavigationRailDestination( //PLACEHOLDER
                    icon: Icon(Icons.account_balance_wallet_outlined),
                    selectedIcon: Icon(Icons.account_balance_wallet),
                    label: Text('Report'),
                  ),
                  NavigationRailDestination( //SETTINGS
                    icon: Icon(Icons.settings_outlined),
                    selectedIcon: Icon(Icons.settings),
                    label: Text('Settings'),
                  ),
                  NavigationRailDestination( //LOGOUT
                    icon: Icon(Icons.logout_outlined),
                    selectedIcon: Icon(Icons.logout),
                    label: Text('Logout'),
                  ),
                ],
                selectedIndex: chosenIndex,
                onDestinationSelected: (value) { // When an option is selected do something
                  if (value == 4){ //If user selects Logout, first page starts at 0 remember
                    // LOGS OUT USER   //idk if clearing of flutter lists need to be done or nah
                    appState.clearAllLists();
                    final leave= {'Left': 'Logout'};                                
                    final leaved= MyApp.of(context).flaskConnect.sendData('logout', leave);
                  
                  if (value == 1){
                    if (appState.currMonth != appState.repMonth && appState.notcurrentmonthchecker)
                    {
                      appState.clearAllLists();

                      chosenIndex = value;
                      appState.notcurrentmonthchecker = false;
                    }
                  }
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => MyHomePage()),
                    );
                  }
                  else{ // Else, go to given page associated with value in switch statement
                    setState(() { 
                    chosenIndex = value;
                  });
                  }
                },
              ),
            ),
          
          Expanded(
            child: Container(
              color: Theme.of(context).colorScheme.primaryContainer,
              child: page,
            ),
          ),
        ],
        ),
      ),
    );
  }
}

class HomeMenu extends StatefulWidget{

  @override
  State<HomeMenu> createState() => _HomeMenuState();
}
final usdController = TextEditingController();
final jmdController = TextEditingController();

class _HomeMenuState extends State<HomeMenu> {  
  @override
  Widget build(BuildContext context) {
    
    var theme = Theme.of(context);
    var appState = context.watch<MyAppState>();
    
    String usd;
    String jmd;
    String jmdToUSD = "USD";

    //appState.transactionList.add("potato");
    //var count2;

    return Scaffold(
      backgroundColor: Color.fromARGB(255, 241, 238, 238),
      body: SingleChildScrollView(
        child: Container(

          //  HOME PAGE IMAGE
          decoration: BoxDecoration(
            color: Colors.grey,
            image: DecorationImage(
              image: AssetImage('assets/images/home_background6.jpg'),
              opacity: 0.9,
              fit: BoxFit.cover,
            ),
          ),

          child: Column(
            children: [
              Padding( // HOME HEADING
                padding: const EdgeInsets.only(
                  left: 50,
                  right: 0,
                  top: 10,
                  bottom: 0,
                ),
                child: Align(
                  alignment: Alignment.topLeft,
                  child: Text("Home",
                    style: TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                      fontFamily: "Nato Sans"
                    ),
                  ),
                ),
              ),
              
              Padding( // ACCOUNTS HEADING
                padding: const EdgeInsets.only(
                  left: 60,
                  right: 0,
                  top: 20,
                  bottom: 0,
                ),
                child: Align(
                  alignment: Alignment.topLeft,
                  child: Container( // Puts it in a box to make textalign.center keep it centered on the account icon
                    width: 100,
                    child: Text("${appState.username}",
                      textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      fontFamily: "Nato Sans"
                    ),
                  ),
                ),
              ),
            ),
              
              Row( // Accounts Row
                children: [
              
                  //      ACCOUNT 1
                  Padding(
                    padding: const EdgeInsets.only(
                      left: 30,
                      right: 0,
                      top: 0,
                      bottom: 0,
                    ),
                    child: Align(
                      alignment: Alignment.centerLeft,
              
                        child: IconButton(
                          onPressed: (){}, 
                          //icon: Image.asset('assets/images/homeimage.jpg'),
                          icon: Icon(Icons.person),
                          selectedIcon: Icon(Icons.person),
                          style: IconButton.styleFrom(
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
                          ),
                          constraints: BoxConstraints.expand(width: 150, height: 150), //use with image icon
                          hoverColor: const Color.fromARGB(255, 219, 219, 219),
                          padding: EdgeInsets.zero,
                          iconSize: 125, //only works when you use code like icon: Icon(Icons.favorites) 
                          ),
                      ),
                  ),

                  //  BALANCE
                  Padding(
                    padding: const EdgeInsets.only(
                      left: 20,
                    ),
                    child: Container(
                      width: 170,
                      height: 40,
                      decoration: BoxDecoration(
                        border: Border.all(width: 1, color: Colors.black.withOpacity(0)),
                        borderRadius: BorderRadius.all(Radius.circular(5)),
                        color: Colors.lightGreen.withOpacity(0.5),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.only(
                          left: 5,
                          right: 0,
                          top: 10,
                          bottom: 10,
                        ),
                        child: Row(
                          children: [
                            Text("Balance: ",
                            style: TextStyle(
                              fontFamily: 'Open Sans',
                              fontWeight: FontWeight.bold,
                            ),
                            ),
                            Text(appState.balance.toStringAsFixed(2), // Displays remaining to 2 decimal places
                              style: TextStyle(
                                height: -0.05, //get text in line with other text
                                fontFamily: 'Open Sans',
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ), 
              

                  // //      ACCOUNT TWO FOR TESTING
                  // Padding(
                  //   padding: const EdgeInsets.only(
                  //     left: 30,
                  //     right: 0,
                  //     top: 0,
                  //     bottom: 0,
                  //   ),
                  //   child: Align(
                  //     alignment: Alignment.centerLeft,
              
                  //       child: SizedBox.fromSize(
                  //         size: Size(150, 150),
                  //         child: ClipOval(
                  //           child: Material(
                  //             shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                  //             color: Colors.transparent,
                  //             child: InkWell(
                  //               splashColor: Colors.grey,
                  //               onTap: (){},
                  //               child: Column(
                  //                 children: [
                  //                   Icon(Icons.add_circle),
                  //                   Text("You"),
                  //                 ],
                  //               )
                  //             )
                  //           )
                  //         )
                  //       )
                  //     ),
                  // )
                ],
              ),
              //  TRANSACTIONS
              Padding(
                padding: const EdgeInsets.only(
                  left: 60,
                  right: 0,
                  top: 20,
                  bottom: 0,
                ),
                  child: Column(
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 5),
                          child: Text('Latest Transactions',
                          textAlign: TextAlign.left,
                          style: TextStyle(
                            fontFamily: 'Nato Sans',
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                      ),
                    ),

                      //  IF TOTAL TRANSACTIONS IS GREATER THAN 5, RUN THIS COMMAND TO ONLY GET 5 LATEST
                      if (appState.expenseList != [] && appState.expenseList.length >= 5) //Displays Transactions if list isn't emtpy
                        for (var i=1; i<=5; i++) //Get the 5 latest Transactions
                          Align(
                            alignment: Alignment.centerLeft,
                            child: SizedBox(
                              width: 450,
                              child: Row(
                                children: [
                                  Icon(Icons.arrow_right,
                                    size: 18,
                                  ),
                                  Text("${appState.getExpenseName(appState.expenseList[appState.expenseList.length - i].toString())}  for  \$${appState.getExpenseCost(appState.expenseList[appState.expenseList.length - i].toString())}  on  ${appState.expensedatelist[appState.expensedatelist.length - i]}", //Shows each individual variable
                                  //child: Text(appState.transactionList[count] as String //Shows each entry
                                  style: TextStyle(
                                    fontFamily: 'Open Sans',
                                    fontSize: 15,
                                    // color: const Color.fromARGB(255, 253, 112, 69),
                                    height: 1, //brings icon more in line with text
                                  ),
                                  ),
                                ],
                              )
                              ),
                          ),
                      // ELSE IF TOTAL TRANSACTIONS IS LESS THAN 5, RUN THIS COMMAND
                      if (appState.expenseList != [] && appState.expenseList.length <= 4) //Displays Transactions if list isn't emtpy
                        for (var i=1; i<=appState.expenseList.length; i++) //Get the 5 latest Transactions
                          Align(
                            alignment: Alignment.centerLeft,
                            child: SizedBox(
                              width: 450,
                              child: Row(
                                children: [
                                  Icon(Icons.arrow_right,
                                    size: 18,
                                  ),
                                  Text("${appState.getExpenseName(appState.expenseList[appState.expenseList.length - i].toString())}  for  \$${appState.getExpenseCost(appState.expenseList[appState.expenseList.length - i].toString())}  on  ${DateTime.now()}", //Shows each individual variable
                                  //child: Text(appState.transactionList[count] as String //Shows each entry
                                  style: TextStyle(
                                    fontFamily: 'Open Sans',
                                    fontSize: 15,
                                    // color: const Color.fromARGB(255, 253, 112, 69),
                                    height: 1, //brings icon more in line with text
                                  ),
                                  ),
                                ],
                              )
                              ),
                          ),

                      if (appState.expenseList.isEmpty) //Displays message if list IS empty
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Padding(
                            padding: const EdgeInsets.only(
                              left: 0,
                              right: 0,
                              top: 20,
                              bottom: 0,
                            ),
                            child: Row( //Row with No Transactions Icon and Text
                              children: [
                                Icon(
                                  //color: Colors.red,
                                  Icons.error,
                                ),
                                Text(" There are no Transactions",
                                  style: TextStyle(
                                    //backgroundColor: Color.fromARGB(255, 214, 209, 209), 
                                  ),
                                ),
                              ]
                            ),
                          ),
                          ),  
        
                      // EXCHANGE RATE TEXT
                      Padding(
                        padding: const EdgeInsets.only(
                          left: 0,
                          right: 0,
                          top: 20,
                          bottom: 20,
                        ),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text('Exchange Rate [JMD ⇆ USD]',
                            textAlign: TextAlign.left,
                            style: TextStyle(
                              fontFamily: 'Nato Sans',
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                          ),
                        ),
                      ),
        
                      //  EXCHANGE RATE IMAGE
                      Align(
                        alignment: Alignment.centerLeft,
                        child: SizedBox(
                          child: Image(
                            image: AssetImage('assets/images/exchangeratesv2.png'),
                            fit: BoxFit.fill
                            )
                          ),
                      )
                    ],
                  ),
                ),
                Row( // EXCHANGE RATE INPUTS ROW
                  children: [
        
                    //  JMD INPUT TEXTFIELD
                    Padding( 
                      padding: const EdgeInsets.only(
                        left: 250,
                        right: 0,
                        top: 20,
                        bottom: 20,
                      ),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: SizedBox(
                          width: 100,
                          child: TextField(
                            controller: jmdController, // Get User Input
                            onSubmitted: (value) { // If any text is entered
                              jmd = jmdController.text;
                              appState.jmd = double.parse(jmd);
                              jmdToUSD = (appState.jmd/155.231).toString();
                              setState(() {
                                appState.jmdToUSD = double.parse(jmdToUSD);
                                //print((appState.jmd/155.231).toString());
                              });
                            },

                            textAlign: TextAlign.center,
                            decoration: InputDecoration(
                              alignLabelWithHint: true,
                              //border: OutlineInputBorder(), //just to help see the parameters
                              floatingLabelBehavior: FloatingLabelBehavior.never, //Removes annoying floating label text on click
                              hintText: 'JMD',
                              hintStyle: TextStyle( //Changes hint Text Font
                                fontFamily: 'Open Sans'
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
        
                    
                    Padding(
                      padding: const EdgeInsets.only(
                        left: 20,
                        right: 0,
                        top: 20,
                        bottom: 20,
                      ),
                      child: TextButton(
                        onPressed: (){}, 
                          child: SizedBox(
                            width: 50,
                            //height: 50,
                            child: Image(
                              image: AssetImage('assets/images/exchange.png'),
                              fit: BoxFit.fill
                              )
                            ),
                        ),
                    ),
        
                    //  USD INPUT/OUTPUT TEXTFIELD
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(
                          left: 20,
                          right: 0,
                          top: 20,
                          bottom: 20,
                        ),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: SizedBox(
                            width: 100,
                            //height: 50,
                            child: TextField(            
                              readOnly: true,
                              // onChanged: (value) {
                              //   jmdToUSD = (appState.jmd/155.231);
                              // }, 
                              textAlign: TextAlign.center,
                              decoration: InputDecoration(
                                alignLabelWithHint: true,
                                //border: OutlineInputBorder(), //just to help see the parameters
                                floatingLabelBehavior: FloatingLabelBehavior.never, //Removes annoying floating label text on click
                                //labelText: appState.jmdToUSD.toStringAsFixed(3),
                                hintText: appState.jmdToUSD.toStringAsFixed(3),
                                hintStyle: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black.withOpacity(0.7),
                                )
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      )
    );

  }
}
  final addExpenseNameController = TextEditingController();
  final addExpenseCostController = TextEditingController();
  final addIncomeNameController = TextEditingController();
  final addIncomeValueController = TextEditingController();
class DashboardPage extends StatefulWidget{

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  @override
  Widget build(BuildContext context) {
    
    var theme = Theme.of(context);
    var appState = context.watch<MyAppState>();

    String want_need_dropdownValue = appState.wantORneed.first;
    String rank_dropdownValue = appState.rankTiers.first;
    String expense_freq_dropdownValue = appState.expenseFrequency.first;
    String income_freq_dropdownValue = appState.incomeFrequency.first;

    var columnsThereYN = 0;
    late Icon wantneedIcon;
    late Icon rankIcon;
    late Icon frequencyIcon;
    late Icon incomeFrequencyIcon;
    late String type;

    // Get current month in text format, e.g. 'April' 'June' 'July' 
    String currentMonth = appState.returnMonth(DateTime.now());

    // To check if the expense type is want or need (used in Add Expense)
    Icon want = Icon(
      Icons.store_mall_directory,
      color: Colors.blueAccent,
      );
    Icon need = Icon(
      Icons.house,
      color: Colors.green
      );

    var zippedLists = IterableZip([appState.expenseList, appState.expenseTypeList, appState.rankList, appState.expenseFreqList,appState.expenseidList]);//appState.expensedatelist]); //Added a list
    var incomeZippedLists = IterableZip([appState.incomeList, appState.incomeFreqList,appState.incomeidList]);

  


    String addExpenseName;
    String addExpenseCost;
    String addIncomeName;
    String addIncomeValue;
    String fullexpense;
    var currentExpense;
    //appState.expenseList.add("1000.00");

    return Scaffold(
      backgroundColor: Color.fromARGB(255, 241, 238, 238),
      body: SingleChildScrollView(
        child: Container(

          //  DASHBOARD PAGE IMAGE
          decoration: BoxDecoration(
            color: Colors.grey,
            image: DecorationImage(
              image: AssetImage('assets/images/home_background6.jpg'),
              opacity: 0.9,
              fit: BoxFit.cover,
            ),
          ),

          child: Column(
            children: [
              Padding( // DASHBOARD HEADING
                padding: const EdgeInsets.only(
                  left: 50,
                  right: 0,
                  top: 10,
                  bottom: 0,
                ),
                child: Align(
                  alignment: Alignment.topLeft,
                  child: Row(
                    children: [
                      Text("Dashboard", 
                        style: TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                          fontFamily: "Nato Sans"
                        ),
                      ),
                    // DemoNextMonth
                        TextButton( 
                          onPressed: () async {
                            num val=appState.currMonth;

                            if (appState.nexmonthdemo){
                              appState.nexmonthdemo = false;
                              appState.clearAllLists();
                              //val--;
                            }
                            else
                            {
                              appState.clearAllLists();
                              appState.nexmonthdemo = true;
                              val ++;                             
                            }
                            final sendtopop= {'month': '$val', 'year': '2023'};                                
                            final nexmonth= await  MyApp.of(context).flaskConnect.sendData('month/data', sendtopop);
                            setState(() {
                              appState.getMonthData(nexmonth);
                              // Should bring up table with expenses recommended to remove
                            });
                          },
                          // The icon 
                          child: Icon(Icons.help,
                            size: 22,
                            color: Colors.black.withOpacity(0),
                          ),
                          ),
                    ],
                  ),
                ),
              ),
              
              Padding( // INFORMATION HEADING
                padding: const EdgeInsets.only(
                  left: 60,
                  right: 0,
                  top: 20,
                  bottom: 10,
                ),
                child: Align(
                  alignment: Alignment.topLeft,
                  child: Text("Status for $currentMonth",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      fontFamily: "Nato Sans"
                    ),
                  ),
                ),
              ),
              
              Row( // INFORMATION ROW
                children: [
              
                  //  GOAL
                  Padding(
                    padding: const EdgeInsets.only(
                      left: 60,
                    ),
                    child: Container(
                      width: 250,
                      height: 60,
                      decoration: BoxDecoration(
                        border: Border.all(width: 1, color: Colors.black.withOpacity(0)),
                        borderRadius: BorderRadius.all(Radius.circular(5)),
                        //color: Colors.grey.withOpacity(0.5),
                        color: Colors.yellow.withOpacity(0.5),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.only(
                          left: 5,
                          right: 0,
                          top: 10,
                          bottom: 10,
                        ),
                        child: Row(
                          children: [
                            Text("Goal: "),
                            Text(appState.savingsgoal.toStringAsFixed(2), // Displays goal to 2 decimal places,
                              style: TextStyle(
                                height: -0.05, //get text in line with other text
                                fontFamily: 'Open Sans',
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  //  REMAINING
                  Padding(
                    padding: const EdgeInsets.only(
                      left: 20,
                    ),
                    child: Container(
                      width: 250,
                      height: 60,
                      decoration: BoxDecoration(
                        border: Border.all(width: 1, color: Colors.black.withOpacity(0)),
                        borderRadius: BorderRadius.all(Radius.circular(5)),
                        color: Colors.lightGreen.withOpacity(0.5),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.only(
                          left: 5,
                          right: 0,
                          top: 10,
                          bottom: 10,
                        ),
                        child: Row(
                          children: [
                            Text("Remaining: "),
                            Text(appState.balance.toStringAsFixed(2), // Displays remaining to 2 decimal places
                              style: TextStyle(
                                height: -0.05, //get text in line with other text
                                fontFamily: 'Open Sans',
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ), 

                  //  SPENT
                  Padding(
                    padding: const EdgeInsets.only(
                      left: 20,
                    ),
                    child: Container(
                      width: 250,
                      height: 60,
                      decoration: BoxDecoration(
                        border: Border.all(width: 1, color: Colors.black.withOpacity(0)),
                        borderRadius: BorderRadius.all(Radius.circular(5)),
                        color: Colors.redAccent.withOpacity(0.5),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.only(
                          left: 5,
                          right: 0,
                          top: 10,
                          bottom: 10,
                        ),
                        child: Row(
                          children: [
                            Text("Spent: "),
                            Text(appState.spent.toStringAsFixed(2), // Displays spent to 2 decimal places
                              style: TextStyle(
                                height: -0.05, //get text in line with other text
                                fontFamily: 'Open Sans',
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ), 

                ],
              ),

              //  EXPENSES
              Padding(
                padding: const EdgeInsets.only(
                  left: 60,
                  right: 0,
                  top: 20,
                  bottom: 0,
                ),
                  child: Column(
                    children: [
        
                      // EXPENSES TEXT
                      Padding(
                        padding: const EdgeInsets.only(
                          left: 0,
                          right: 0,
                          top: 20,
                          bottom: 10,
                        ),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text('Expenses',
                            textAlign: TextAlign.left,
                            style: TextStyle(
                              fontFamily: 'Nato Sans',
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                          ),
                        ),
                      ),
        
                      //  EXPENSES SEARCH FIELD
                      Align(
                        alignment: Alignment.centerLeft,
                        child: SizedBox(
                          width: 920,
                          height: 45,
                          child: TextField(
                            style: TextStyle(
                              fontFamily: 'Open Sans',
                              fontSize: 15,
                            ),
                            decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              floatingLabelBehavior: FloatingLabelBehavior.never, //Removes annoying floating label text on click
                              labelText: 'Search...',
                              labelStyle: TextStyle( //Changes Font
                                fontFamily: 'Nato Sans'
                              ),
                            ),
                          )
                          ),
                      ),

                      //          EXPENSES LIST

                      Padding(
                        padding: const EdgeInsets.only(
                        top: 10,
                        ),
                        child: Align( //align container
                          alignment: Alignment.centerLeft,
                          child: Container(
                            width: 920,
                            decoration: BoxDecoration(
                              border: Border.all(width: 1, color: Colors.black.withOpacity(0.5)),
                              borderRadius: BorderRadius.all(Radius.circular(5))
                            ),
                            child: Align( //align everything inside box
                              alignment: Alignment.centerLeft,
                              child: SizedBox(
                                width: 920,
                                child: Column(
                                  children: [
                                    if (appState.expenseList.isNotEmpty) //Displays Columns if list isn't emtpy
                                      Row(
                                        children: [
                                          Expanded(
                                            // flex: 2,
                                            child: Padding(
                                              padding: const EdgeInsets.only(left:15),
                                              child: Text("NAME", //Specifically gets the Name
                                                style: TextStyle(
                                                  color: Colors.grey,
                                                ),
                                              ),
                                            ),
                                          ),
                                          Expanded( //Specifically gets the Cost
                                            // flex: 5,
                                            child: Align(
                                              alignment: Alignment.centerLeft,
                                              child: Text("COST", //Specifically gets the Name
                                                style: TextStyle(
                                                  color: Colors.grey,
                                                ),
                                              ),
                                            ),
                                          ),
                                          Expanded( //Specifically gets the Cost
                                            // flex: 1,
                                            child: Align(
                                              alignment: Alignment.centerRight,
                                              child: Text("W/N    RANK    FREQ     DEL      ", //Specifically gets the Name
                                                style: TextStyle(
                                                  color: Colors.grey,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    
                                    if (appState.expenseList != []) //Displays Expenses if list isn't emtpy
                                      for (var tuple in zippedLists)//Get all expenses
                                        // 1st = Expense, 2nd = Want/Need, 3rd = Rank, 4th = Frequency
                                        Row(
                                          children: [
                                            //  Money Icon and Expense Text Part
                                              Expanded(
                                                // flex: 2,
                                                child: Padding(
                                                  padding: const EdgeInsets.only(left: 15),
                                                  child: Text(appState.getExpenseName(tuple.first), //Specifically gets the Name
                                                    style: TextStyle(
                                                      color: Colors.deepOrangeAccent,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                left: 5,
                                              ),
                                              child: Icon(Icons.attach_money_rounded, 
                                              color: Colors.deepOrangeAccent,
                                              ),
                                            ),
                                            Expanded( //Specifically gets the Cost
                                              // flex: 2,
                                              child: Align(
                                                alignment: Alignment.centerLeft,
                                                child: Text(appState.getExpenseCost(tuple.first).toString(), //Specifically gets the Name
                                                  style: TextStyle(
                                                    color: Colors.deepOrangeAccent,
                                                  ),
                                                ),
                                              ),
                                            ),

                                            //  Remove Button
                                            Expanded( // Aligns it nicely to the right
                                              child: Align(
                                                alignment: Alignment.centerRight,
                                                child: Row(
                                                  children: [
                                                    SizedBox(width: 93,),
                                                    tuple.elementAt(1), // Want/Need Icon
                                                    SizedBox(width: 25,),
                                                    tuple.elementAt(2), // Rank Icon
                                                    SizedBox(width: 28,),
                                                    tuple.elementAt(3), // Frequency Icon
                                                    Padding(
                                                      padding: const EdgeInsets.only(left: 10),
                                                      child: TextButton( // Expense Button To Delete
                                                        onPressed: () {
                                                          setState(() {
                                                            appState.removeExpense(tuple.first);
                                                            final removeExpenseFromID = {'record_id': tuple.elementAt(4),'table': 'ExpenseList'};           
                                                            final removedExpensefromID = MyApp.of(context).flaskConnect.sendData('remove', removeExpenseFromID);
                                                            //print(appState.expenseList);
                                                          });
                                                        },
                                                                                                  
                                                        child: Icon(Icons.delete,
                                                          size: 20,
                                                          color: Colors.red,
                                                        ),
                                                        ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),

                                    // Text(expense.toString(), //Shows each individual variable
                                    // //child: Text(appState.transactionList[count] as String //Shows each entry
                                    // style: TextStyle(
                                    //   fontFamily: 'Open Sans',
                                    //   fontSize: 15,
                                    //   color: const Color.fromARGB(255, 253, 112, 69),
                                    //   height: 1, //brings icon more in line with text
                                    // ),
                                    // ),
                                  ],
                                )
                                ),
                            ),
                          ),
                        ),
                      ),

                      //  EXPENSES BOX IF EMPTY
                      if (appState.expenseList.isEmpty) //Displays message if list IS empty
                        Padding(
                          padding: const EdgeInsets.only(
                            top: 10,
                          ),
                          child: Align(
                            alignment: Alignment.centerLeft, //aligns container
                            child: Container(
                              width: 920,
                              decoration: BoxDecoration(
                                border: Border.all(width: 1, color: Colors.black.withOpacity(0.5)),
                                borderRadius: BorderRadius.all(Radius.circular(5))
                              ),
                              child: Align( //aligns everything inside box
                                alignment: Alignment.centerLeft,
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                    left: 0,
                                    right: 0,
                                    top: 5,
                                    bottom: 5,
                                  ),
                                  child: Row( //Row with No Expenses Icon and Text
                                    children: [
                                      Icon(
                                        //color: Colors.red,
                                        Icons.error,
                                      ),
                                      Text(" There are no Expenses",
                                        style: TextStyle(
                                          //backgroundColor: Color.fromARGB(255, 214, 209, 209), 
                                        ),
                                      ),
                                    ]
                                  ),
                                ),
                                ),
                            ),
                          ),
                        ),  

              Padding( // ADD EXPENSE HEADING
                padding: const EdgeInsets.only(
                  left: 0,
                  right: 0,
                  top: 20,
                  bottom: 10,
                ),
                child: Align(
                  alignment: Alignment.topLeft,
                  child: Text("Add Expense",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      fontFamily: "Nato Sans"
                    ),
                  ),
                ),
              ),

              Padding( // NAME & COST HEADING
                padding: const EdgeInsets.only(
                  left: 0,
                  right: 0,
                  top: 0,
                  bottom: 0,
                ),
                child: Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(
                        left: 0,
                        right: 60,
                      ),
                      child: Align(
                        alignment: Alignment.topLeft,
                        child: Text("Name",
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            fontFamily: "Open Sans"
                          ),
                        ),
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.only(
                        left: 166,
                        right: 0,
                      ),
                      child: Align(
                        alignment: Alignment.topLeft,
                        child: Text("Cost",
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            fontFamily: "Open Sans"
                          ),
                        ),
                      ),
                    ),

                  ],
                ),
              ),

                Row( // NAME & COST INPUTS ROW
                  children: [
        
                    //  NAME TEXTFIELD
                    Padding( 
                      padding: const EdgeInsets.only(
                        left: 0,
                        right: 0,
                        top: 0,
                        bottom: 20,
                      ),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: SizedBox(
                          width: 250,
                          height: 40,
                          child: TextField(
                              controller: addExpenseNameController, // Get User Input
                              onSubmitted: (value) { // If Enter is pushed
                                addExpenseName = addExpenseNameController.text;
                                appState.expenseName = addExpenseName;
                              },
                              onChanged: (value) { // If any text is entered at all
                                addExpenseName = addExpenseNameController.text;
                                appState.expenseName = addExpenseName;
                              },

                            style: TextStyle(
                              fontSize: 14,
                              fontFamily: 'Open Sans'
                            ),
                            //textAlign: TextAlign.center,
                            decoration: InputDecoration(
                              alignLabelWithHint: true,
                              border: OutlineInputBorder(), //just to help see the parameters
                              floatingLabelBehavior: FloatingLabelBehavior.never, //Removes annoying floating label text on click
                              //hintText: 'Name',
                              hintStyle: TextStyle( //Changes hint Text Font
                                fontFamily: 'Open Sans'
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
        
                    //  COST TEXT FIELD
                    Padding( 
                      padding: const EdgeInsets.only(
                        left: 20,
                        right: 0,
                        top: 0,
                        bottom: 20,
                      ),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: SizedBox(
                          width: 250,
                          height: 40,
                          child: TextField(
                            controller: addExpenseCostController, // Get User Input
                            onSubmitted: (value) { // If Enter is pushed
                              addExpenseCost = addExpenseCostController.text;
                              appState.expenseCost = double.parse(addExpenseCost);
                              //appState.expenseCostList.add(double.parse(addExpenseCost)); //add the expense to the expense cost list so i can 
                              //print((appState.expenseName.toString(), appState.expenseCost.toString()));
                            },
                            onChanged: (value) { // If any text is entered at all
                              addExpenseCost = addExpenseCostController.text;
                              if (addExpenseCost != ""){
                                appState.expenseCost = double.parse(addExpenseCost);
                              }
                              //appState.expenseCostList.add(double.parse(addExpenseCost)); //add the expense to the expense cost list so i can 
                              //print((appState.expenseName.toString(), appState.expenseCost.toString()));
                            },

                            style: TextStyle(
                              fontSize: 14,
                              fontFamily: 'Open Sans'
                            ),
                            //textAlign: TextAlign.center,
                            decoration: InputDecoration(
                              alignLabelWithHint: true,
                              border: OutlineInputBorder(), //just to help see the parameters
                              floatingLabelBehavior: FloatingLabelBehavior.never, //Removes annoying floating label text on click
                              //hintText: 'Cost',
                              hintStyle: TextStyle( //Changes hint Text Font
                                fontFamily: 'Open Sans'
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),     


                    Padding(                          //WANT OR NEED POP UP/DROP DOWN MENU
                      padding: const EdgeInsets.only(
                        left: 20,
                        right: 0,
                        top: 0,
                        bottom: 20,
                      ),
                      child: Align(
                        alignment: Alignment.centerLeft,
              
                        //    WANT/NEED POP UP/DROP DOWN MENU 
                        child: Container(
                          width: 90,
                          height: 40,
                          decoration: BoxDecoration( // Adds border
                            border: Border.all(width: 1, color: Colors.black.withOpacity(0.5)),
                            borderRadius: BorderRadius.all(Radius.circular(50))
                          ),
                          child: PopupMenuButton( //Create pop up menu
                            constraints: const BoxConstraints.tightFor(width: 100, height: 100), //Control width and height of dropdown button when clicked. Also creates a scrollable environment
                            shape: RoundedRectangleBorder( //Change border for menu
                            side: BorderSide(style: BorderStyle.solid, width: 0.3), //adds a line around the border
                            borderRadius: BorderRadius.all(Radius.circular(10.0))
                            ), 
                            // Configure pop up menu
                            itemBuilder: (context) {
                              return appState.wantORneed.map((str) { // Create drop down menu items from given list
                                return PopupMenuItem(
                                  value: str,
                                  child: Row(
                                    children: [
                                      Text(str,
                                        //little bit of style for the text
                                        style: TextStyle(
                                          fontFamily: 'Nato Sans',
                                          fontSize: 15,
                                        ),
                                      ),
                                      if (str == "Want") //Different WANT/NEED Symbols
                                        Padding(
                                          padding: const EdgeInsets.only(left: 5),
                                          child: wantneedIcon = Icon(
                                             Icons.store_mall_directory,
                                            color: Colors.blueAccent,
                                          ),
                                        )
                                      else
                                        Padding(
                                          padding: const EdgeInsets.only(left: 5),
                                          child: wantneedIcon = Icon(
                                            Icons.house,
                                            color: Colors.green
                                            ),
                                        )
                                      
                                    ],
                                  ),
                                  
                                );
                              }).toList();
                            },
              
                            child: Row( // Displayed Choice and Icon
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: <Widget>[
                                Padding(
                                  padding: const EdgeInsets.only(
                                    left: 10,
                                  ),
                                  child: Text(appState.wantORneedchoice, //selected card text
              
                                  ),
                                ),
                                // ICON
                                // Text(appState.wantORneedchoice),
                                if (appState.wantORneedchoice == "Want") //Different WANT/NEED Symbols
                                  Padding(
                                    padding: const EdgeInsets.only(left: 5),
                                    child: wantneedIcon = Icon(
                                      Icons.store_mall_directory,
                                      color: Colors.blueAccent,
                                      ),
                                  )
                                else
                                  Padding(
                                    padding: const EdgeInsets.only(left: 5),
                                    child: wantneedIcon = Icon(
                                      Icons.house,
                                      color: Colors.green
                                      ),
                                  )
                              ],
                            ),
              
                            onSelected: (String? choice) { // Called when the user selects an item
                              appState.wantORneedchoice = choice!; // Set global variable to chosen card
                              setState(() {
                                appState.type = wantneedIcon;
                                want_need_dropdownValue = appState.wantORneedchoice; // Update selected
                              });
                            },
                          ),
                          ),
                          )
                        ),


                    Padding(                          //EXPENSE RANKINGS POP UP/DROP DOWN MENU
                      padding: const EdgeInsets.only(
                        left: 20,
                        right: 0,
                        top: 0,
                        bottom: 20,
                      ),
                      child: Align(
                        alignment: Alignment.centerLeft,
              
                        //    EXPENSE RANKINGS POP UP/DROP DOWN MENU 
                        child: Container(
                          width: 70,
                          height: 40,
                          decoration: BoxDecoration( // Adds border
                            border: Border.all(width: 1, color: Colors.black.withOpacity(0.5)),
                            borderRadius: BorderRadius.all(Radius.circular(50))
                          ),
                          child: PopupMenuButton( //Create pop up menu
                            constraints: const BoxConstraints.tightFor(width: 80, height: 100), //Control width and height of dropdown button when clicked. Also creates a scrollable environment
                            shape: RoundedRectangleBorder( //Change border for menu
                            side: BorderSide(style: BorderStyle.solid, width: 0.3), //adds a line around the border
                            borderRadius: BorderRadius.all(Radius.circular(10.0))
                            ), 
                            // Configure pop up menu
                            itemBuilder: (context) {
                              return appState.rankTiers.map((str) { // Create drop down menu items from given list
                                return PopupMenuItem(
                                  value: str,
                                  child: Row(
                                    children: [
                                      Text(str,
                                        //little bit of style for the text
                                        style: TextStyle(
                                          fontFamily: 'Nato Sans',
                                          fontSize: 15,
                                        ),
                                      ),
                                      if (str == "T1") //Different EXPENSE RANKINGS Symbols
                                        Padding(
                                          padding: const EdgeInsets.only(left: 5, top: 3),
                                          child: rankIcon = Icon(
                                            Icons.looks_one,
                                            color: Color.fromARGB(255, 180, 166, 35),
                                          ),
                                        )
                                      else if (str == "T2")
                                        Padding(
                                          padding: const EdgeInsets.only(left: 5, top: 3),
                                          child: rankIcon = Icon(
                                            Icons.looks_two,
                                            color: Colors.orange
                                            ),
                                        )
                                      else if (str == "T3")
                                        Padding(
                                          padding: const EdgeInsets.only(left: 5, top: 3),
                                          child: rankIcon = Icon(
                                            Icons.looks_3,
                                            color: Colors.red
                                            ),
                                        )

                                    ],
                                  ),
                                  
                                );
                              }).toList();
                            },
              
                            child: Row( // Displayed Choice and Icon
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: <Widget>[
                                Padding(
                                  padding: const EdgeInsets.only(
                                    left: 10,
                                  ),
                                  child: Text(appState.ranks, //selected card text
              
                                  ),
                                ),
                                // ICON
                                if (appState.ranks == "T1") //Different EXPENSE RANKINGS Symbols
                                  Padding(
                                    padding: const EdgeInsets.only(left: 5, top: 0),
                                    child: rankIcon = Icon(
                                      Icons.looks_one,
                                      color: Color.fromARGB(255, 180, 166, 35),
                                    ),
                                  )
                                else if (appState.ranks == "T2")
                                  Padding(
                                    padding: const EdgeInsets.only(left: 5, top: 0),
                                    child: rankIcon = Icon(
                                      Icons.looks_two,
                                      color: Colors.orange
                                      ),
                                  )
                                else if (appState.ranks == "T3")
                                  Padding(
                                    padding: const EdgeInsets.only(left: 5, top: 0),
                                    child: rankIcon = Icon(
                                      Icons.looks_3,
                                      color: Colors.red
                                      ),
                                  )
                              ],
                            ),
              
                            onSelected: (String? choice) { // Called when the user selects an item
                              appState.ranks = choice!; // Set global variable to chosen card
                              setState(() {
                                appState.rankIcon = rankIcon;
                                rank_dropdownValue = appState.ranks; // Update selected
                              });
                            },
                          ),
                          ),
                          )
                        ),


                    Padding(                          //EXPENSE FREQUENCY POP UP/DROP DOWN MENU
                      padding: const EdgeInsets.only(
                        left: 20,
                        right: 0,
                        top: 0,
                        bottom: 20,
                      ),
                      child: Align(
                        alignment: Alignment.centerLeft,
              
                        //    EXPENSE FREQUENCY POP UP/DROP DOWN MENU 
                        child: Container(
                          width: 120,
                          height: 40,
                          decoration: BoxDecoration( // Adds border
                            border: Border.all(width: 1, color: Colors.black.withOpacity(0.5)),
                            borderRadius: BorderRadius.all(Radius.circular(50))
                          ),
                          child: PopupMenuButton( //Create pop up menu
                            constraints: const BoxConstraints.tightFor(width: 130, height: 100), //Control width and height of dropdown button when clicked. Also creates a scrollable environment
                            shape: RoundedRectangleBorder( //Change border for menu
                            side: BorderSide(style: BorderStyle.solid, width: 0.3), //adds a line around the border
                            borderRadius: BorderRadius.all(Radius.circular(10.0))
                            ), 
                            // Configure pop up menu
                            itemBuilder: (context) {
                              return appState.expenseFrequency.map((str) { // Create drop down menu items from given list
                                return PopupMenuItem(
                                  value: str,
                                  child: Row(
                                    children: [
                                      Text(str,
                                        //little bit of style for the text
                                        style: TextStyle(
                                          fontFamily: 'Nato Sans',
                                          fontSize: 15,
                                        ),
                                      ),
                                      if (str == "One-Time") //Different EXPENSE FREQUENCY Symbols
                                        Padding(
                                          padding: const EdgeInsets.only(left: 5, top: 3),
                                          child: frequencyIcon = Icon(
                                            Icons.one_x_mobiledata_outlined,
                                            color: Colors.blueGrey,
                                          ),
                                        )
                                      else
                                        Padding(
                                          padding: const EdgeInsets.only(left: 5),
                                          child: frequencyIcon = Icon(
                                            Icons.calendar_month,
                                            color: Colors.blueGrey
                                            ),
                                        )
                                      
                                    ],
                                  ),
                                  
                                );
                              }).toList();
                            },
              
                            child: Row( // Displayed Choice and Icon
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: <Widget>[
                                Padding(
                                  padding: const EdgeInsets.only(
                                    left: 10,
                                  ),
                                  child: Text(appState.expenseFreq, //selected card text
              
                                  ),
                                ),
                                // ICON
                                if (appState.expenseFreq == "One-Time") //Different EXPENSE FREQUENCY Symbols
                                  Padding(
                                    padding: const EdgeInsets.only(left: 5),
                                    child: frequencyIcon = Icon(
                                      Icons.one_x_mobiledata_outlined,
                                      color: Colors.blueGrey,
                                      ),
                                  )
                                else
                                  Padding(
                                    padding: const EdgeInsets.only(left: 5),
                                    child: frequencyIcon = Icon(
                                      Icons.calendar_month,
                                      color: Colors.blueGrey
                                      ),
                                  )
                              ],
                            ),
              
                            onSelected: (String? choice) { // Called when the user selects an item
                              appState.expenseFreq = choice!; // Set global variable to chosen card
                              setState(() {
                                appState.frequencyIcon = frequencyIcon;
                                expense_freq_dropdownValue = appState.expenseFreq; // Update selected
                              });
                            },
                          ),
                          ),
                          )
                        ),


                    //  ADD EXPENSE BUTTON
                    Padding( 
                      padding: const EdgeInsets.only(
                        left: 20,
                        right: 0,
                        top: 0,
                        bottom: 20,
                      ),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: SizedBox(
                          width: 50,
                          height: 40,
                          child: IconButton(
                            onPressed: () async{
                              // SENDS TO BACKEND
                                final sendExpense= {'name': appState.expenseName.toString(), 'cost': appState.expenseCost.toStringAsFixed(2), 'tier': appState.ranks.toString(), 'expenseType': appState.wantORneedchoice.toString(), 'frequency': appState.expenseFreq.toString()};                                
                                final sentExpense= await MyApp.of(context).flaskConnect.sendData('expense/add', sendExpense);
                                var data = sentExpense;
                              setState((){
                                //sentExpense.then((data){ 
                                var id = data['message']; 
                                print("The ID sent $id");
                                appState.expenseID = id.toString();
                                appState.expenseidList.add((appState.expenseID));
                                

                                //});

                                // UPDATE ICONS
                                appState.type = wantneedIcon;
                                appState.expenseTypeList.add(appState.type);
                                appState.rankIcon = rankIcon;
                                appState.rankList.add(appState.rankIcon);
                                appState.frequencyIcon = frequencyIcon;
                                appState.expenseFreqList.add(appState.frequencyIcon);
                                // CALCULATE WANT/NEED AMOUNTS TO BE USED FOR PERCENTAGES
                                if (appState.type.icon == want.icon){ // Dot operators to compare specifically the icons
                                  // print("Happened");
                                  appState.wantTotal += appState.expenseCost;
                                  }
                                else if(appState.type.icon == need.icon){ // Dot operators to compare specifically the icons
                                  // print("Happened");
                                  appState.needTotal += appState.expenseCost;
                                }
                                //  ADD EXPENSE TO EXPENSE LIST
                                appState.expenseList.add(("${appState.expenseName} ${appState.expenseCost.toStringAsFixed(2)}")); //Interpolation
                                appState.expenseCostList.add((appState.expenseName, appState.expenseCost)); // Separate list for calcualtions
                                appState.balance -= appState.expenseCost; // subtract expense from balance
                                appState.spent += appState.expenseCost; // add expense cost to spent

                                // CALCULATE WANT/NEED/SAVINGS PERCENTAGES [want/need amounts in relation to total income]
                                appState.wantPercentage = appState.wantTotal / appState.income;
                                appState.needPercentage = appState.needTotal / appState.income;
                                appState.savingsPercentage = 100 - (appState.wantPercentage*100 + appState.needPercentage*100);
                              });
                          
                            }, //onpressed()
                            icon: Icon(Icons.add), // The plus icon
                            )
                        ),
                      ),
                    ),   

                  ],
                ),

                      // INCOME TEXT
                      Padding(
                        padding: const EdgeInsets.only(
                          left: 0,
                          right: 0,
                          top: 10,
                          bottom: 10,
                        ),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text('Income Channels',
                            textAlign: TextAlign.left,
                            style: TextStyle(
                              fontFamily: 'Nato Sans',
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                          ),
                        ),
                      ),
        
                      //  INCOME SEARCH FIELD
                      Align(
                        alignment: Alignment.centerLeft,
                        child: SizedBox(
                          width: 920,
                          height: 45,
                          child: TextField(
                            style: TextStyle(
                              fontFamily: 'Open Sans',
                              fontSize: 15,
                            ),
                            decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              floatingLabelBehavior: FloatingLabelBehavior.never, //Removes annoying floating label text on click
                              labelText: 'Search...',
                              labelStyle: TextStyle( //Changes Font
                                fontFamily: 'Nato Sans'
                              ),
                            ),
                          )
                          ),
                      ),

                      //   INCOME LIST

                      Padding(
                        padding: const EdgeInsets.only(
                        top: 10,
                        ),
                        child: Align( //align container
                          alignment: Alignment.centerLeft,
                          child: Container(
                            width: 920,
                            decoration: BoxDecoration(
                              border: Border.all(width: 1, color: Colors.black.withOpacity(0.5)),
                              borderRadius: BorderRadius.all(Radius.circular(5))
                            ),
                            child: Align( //align everything inside box
                              alignment: Alignment.centerLeft,
                              child: SizedBox(
                                width: 920,
                                child: Column(
                                  children: [
                                    if (appState.incomeList.isNotEmpty) //Displays Columns if list isn't emtpy
                                      Row(
                                        children: [
                                          Expanded(
                                            // flex: 2,
                                            child: Padding(
                                              padding: const EdgeInsets.only(left:15),
                                              child: Text("NAME", //Specifically gets the Name
                                                style: TextStyle(
                                                  color: Colors.grey,
                                                ),
                                              ),
                                            ),
                                          ),
                                          Expanded( //Specifically gets the Cost
                                            // flex: 5,
                                            child: Align(
                                              alignment: Alignment.centerLeft,
                                              child: Text("EARNINGS", //Specifically gets the Name
                                                style: TextStyle(
                                                  color: Colors.grey,
                                                ),
                                              ),
                                            ),
                                          ),
                                          Expanded( //Specifically gets the Cost
                                            // flex: 1,
                                            child: Align(
                                              alignment: Alignment.centerRight,
                                              child: Text("               FREQ     DEL      ", //Specifically gets the Name
                                                style: TextStyle(
                                                  color: Colors.grey,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    if (appState.incomeList != []) //Displays Expenses if list isn't emtpy
                                      for (var tuple in incomeZippedLists)//Get all expenses
                                        // 1st = Expense, 2nd = Want/Need, 3rd = Rank, 4th = Frequency
                                        Row(
                                          children: [
                                            //  Money Icon and Expense Text Part
                                              Expanded(
                                                // flex: 2,
                                                child: Padding(
                                                  padding: const EdgeInsets.only(left: 15),
                                                  child: Text(appState.getIncomeName(tuple.first), //Specifically gets the Name
                                                    style: TextStyle(
                                                      color: Colors.deepOrangeAccent,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                left: 5,
                                              ),
                                              child: Icon(Icons.attach_money_rounded, 
                                              color: Colors.deepOrangeAccent,
                                              ),
                                            ),
                                            Expanded( //Specifically gets the Earnings
                                              // flex: 2,
                                              child: Align(
                                                alignment: Alignment.centerLeft,
                                                child: Text(appState.getIncomeEarning(tuple.first).toString(), //Specifically gets the Name
                                                  style: TextStyle(
                                                    color: Colors.deepOrangeAccent,
                                                  ),
                                                ),
                                              ),
                                            ),

                                            //  Remove Button
                                            Expanded( // Aligns it nicely to the right
                                              child: Align(
                                                alignment: Alignment.centerRight,
                                                child: Row(
                                                  children: [
                                                    SizedBox(width: 196,),
                                                    tuple.elementAt(1), // Frequency Icon
                                                    Padding(
                                                      padding: const EdgeInsets.only(left: 10),
                                                      child: TextButton( // Income Button To Delete
                                                        onPressed: () {
                                                          setState(() {
                                                            appState.removeIncome(tuple.first);
                                                            final removeIncomeFromID = {'record_id': tuple.elementAt(2),'table': 'IncomeChannel'};           
                                                            final removedIncomefromID = MyApp.of(context).flaskConnect.sendData('remove', removeIncomeFromID);
                                                            //print(appState.expenseList);
                                                          });
                                                        },
                                                                                                  
                                                        child: Icon(Icons.delete,
                                                          size: 20,
                                                          color: Colors.red,
                                                        ),
                                                        ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),

                                  ],
                                )
                                ),
                            ),
                          ),
                        ),
                      ),

                      //  INCOME BOX IF EMPTY
                      if (appState.incomeList.isEmpty) //Displays message if list IS empty
                        Padding(
                          padding: const EdgeInsets.only(
                            top: 10,
                          ),
                          child: Align(
                            alignment: Alignment.centerLeft, //aligns container
                            child: Container(
                              width: 920,
                              decoration: BoxDecoration(
                                border: Border.all(width: 1, color: Colors.black.withOpacity(0.5)),
                                borderRadius: BorderRadius.all(Radius.circular(5))
                              ),
                              child: Align( //aligns everything inside box
                                alignment: Alignment.centerLeft,
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                    left: 0,
                                    right: 0,
                                    top: 5,
                                    bottom: 5,
                                  ),
                                  child: Row( //Row with No Income Icon and Text
                                    children: [
                                      Icon(
                                        //color: Colors.red,
                                        Icons.error,
                                      ),
                                      Text(" There are no Income Channels",
                                        style: TextStyle(
                                          //backgroundColor: Color.fromARGB(255, 214, 209, 209), 
                                        ),
                                      ),
                                    ]
                                  ),
                                ),
                                ),
                            ),
                          ),
                        ),  

              Padding( // ADD INCOME HEADING
                padding: const EdgeInsets.only(
                  left: 0,
                  right: 0,
                  top: 20,
                  bottom: 10,
                ),
                child: Align(
                  alignment: Alignment.topLeft,
                  child: Text("Add Income Channel",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      fontFamily: "Nato Sans"
                    ),
                  ),
                ),
              ),

              Padding( // NAME & EARNINGS HEADING
                padding: const EdgeInsets.only(
                  left: 0,
                  right: 0,
                  top: 0,
                  bottom: 0,
                ),
                child: Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(
                        left: 0,
                        right: 60,
                      ),
                      child: Align(
                        alignment: Alignment.topLeft,
                        child: Text("Name",
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            fontFamily: "Open Sans"
                          ),
                        ),
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.only(
                        left: 166,
                        right: 0,
                      ),
                      child: Align(
                        alignment: Alignment.topLeft,
                        child: Text("Monthly Earnings",
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            fontFamily: "Open Sans"
                          ),
                        ),
                      ),
                    ),

                  ],
                ),
              ),

                    ],
                  ),
                ),
                Row( // NAME & EARNINGS INPUTS ROW
                  children: [
        
                    //  NAME TEXTFIELD
                    Padding( 
                      padding: const EdgeInsets.only(
                        left: 60,
                        right: 0,
                        top: 0,
                        bottom: 20,
                      ),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: SizedBox(
                          width: 250,
                          height: 40,
                          child: TextField(
                              controller: addIncomeNameController, // Get User Input
                              onSubmitted: (value) { // If Enter is pushed
                                addIncomeName = addIncomeNameController.text;
                                appState.incomeName = addIncomeName;
                              },
                              onChanged: (value) { // If any text is entered at all
                                addIncomeName = addIncomeNameController.text;
                                appState.incomeName = addIncomeName;
                              },

                            style: TextStyle(
                              fontSize: 14,
                              fontFamily: 'Open Sans'
                            ),
                            //textAlign: TextAlign.center,
                            decoration: InputDecoration(
                              alignLabelWithHint: true,
                              border: OutlineInputBorder(), //just to help see the parameters
                              floatingLabelBehavior: FloatingLabelBehavior.never, //Removes annoying floating label text on click
                              //hintText: 'Name',
                              hintStyle: TextStyle( //Changes hint Text Font
                                fontFamily: 'Open Sans'
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
        
                    //  EARNINGS TEXT FIELD
                    Padding( 
                      padding: const EdgeInsets.only(
                        left: 20,
                        right: 0,
                        top: 0,
                        bottom: 20,
                      ),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: SizedBox(
                          width: 250,
                          height: 40,
                          child: TextField(
                            controller: addIncomeValueController, // Get User Input
                            onSubmitted: (value) { // If Enter is pushed
                              addIncomeValue = addIncomeValueController.text;
                              appState.incomeValue = double.parse(addIncomeValue);
                              //appState.expenseCostList.add(double.parse(addExpenseCost)); //add the expense to the expense cost list so i can 
                              //print((appState.expenseName.toString(), appState.expenseCost.toString()));
                            },
                            onChanged: (value) { // If any text is entered at all
                              addIncomeValue = addIncomeValueController.text;
                              if (addIncomeValue != ""){
                                appState.incomeValue = double.parse(addIncomeValue);
                              }
                              //appState.expenseCostList.add(double.parse(addExpenseCost)); //add the expense to the expense cost list so i can 
                              //print((appState.expenseName.toString(), appState.expenseCost.toString()));
                            },

                            style: TextStyle(
                              fontSize: 14,
                              fontFamily: 'Open Sans'
                            ),
                            //textAlign: TextAlign.center,
                            decoration: InputDecoration(
                              alignLabelWithHint: true,
                              border: OutlineInputBorder(), //just to help see the parameters
                              floatingLabelBehavior: FloatingLabelBehavior.never, //Removes annoying floating label text on click
                              //hintText: 'Cost',
                              hintStyle: TextStyle( //Changes hint Text Font
                                fontFamily: 'Open Sans'
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),     


                    Padding(                          //INCOME FREQUENCY POP UP/DROP DOWN MENU
                      padding: const EdgeInsets.only(
                        left: 20,
                        right: 0,
                        top: 0,
                        bottom: 20,
                      ),
                      child: Align(
                        alignment: Alignment.centerLeft,
              
                        //    INCOME FREQUENCY POP UP/DROP DOWN MENU 
                        child: Container(
                          width: 120,
                          height: 40,
                          decoration: BoxDecoration( // Adds border
                            border: Border.all(width: 1, color: Colors.black.withOpacity(0.5)),
                            borderRadius: BorderRadius.all(Radius.circular(50))
                          ),
                          child: PopupMenuButton( //Create pop up menu
                            constraints: const BoxConstraints.tightFor(width: 130, height: 100), //Control width and height of dropdown button when clicked. Also creates a scrollable environment
                            shape: RoundedRectangleBorder( //Change border for menu
                            side: BorderSide(style: BorderStyle.solid, width: 0.3), //adds a line around the border
                            borderRadius: BorderRadius.all(Radius.circular(10.0))
                            ), 
                            // Configure pop up menu
                            itemBuilder: (context) {
                              return appState.incomeFrequency.map((str) { // Create drop down menu items from given list
                                return PopupMenuItem(
                                  value: str,
                                  child: Row(
                                    children: [
                                      Text(str,
                                        //little bit of style for the text
                                        style: TextStyle(
                                          fontFamily: 'Nato Sans',
                                          fontSize: 15,
                                        ),
                                      ),
                                      if (str == "One-Time") //Different INCOME FREQUENCY Symbols
                                        Padding(
                                          padding: const EdgeInsets.only(left: 5, top: 3),
                                          child: Icon(
                                            Icons.one_x_mobiledata_outlined,
                                            color: Colors.blueGrey,
                                          ),
                                        )
                                      else
                                        Padding(
                                          padding: const EdgeInsets.only(left: 5),
                                          child: Icon(
                                            Icons.calendar_month,
                                            color: Colors.blueGrey
                                            ),
                                        )
                                      
                                    ],
                                  ),
                                  
                                );
                              }).toList();
                            },
              
                            child: Row( // Displayed Choice and Icon
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: <Widget>[
                                Padding(
                                  padding: const EdgeInsets.only(
                                    left: 10,
                                  ),
                                  child: Text(appState.incomeFreq, //selected card text
              
                                  ),
                                ),
                                // ICON
                                if (appState.incomeFreq == "One-Time") //Different INCOME FREQUENCY Symbols
                                  Padding(
                                    padding: const EdgeInsets.only(left: 5),
                                    child: incomeFrequencyIcon = Icon(
                                      Icons.one_x_mobiledata_outlined,
                                      color: Colors.blueGrey,
                                      ),
                                  )
                                else
                                  Padding(
                                    padding: const EdgeInsets.only(left: 5),
                                    child: incomeFrequencyIcon = Icon(
                                      Icons.calendar_month,
                                      color: Colors.blueGrey
                                      ),
                                  )
                              ],
                            ),
              
                            onSelected: (String? choice) { // Called when the user selects an item
                              appState.incomeFreq = choice!; // Set global variable to chosen card
                              setState(() { 
                                appState.incomeFrequencyIcon =  incomeFrequencyIcon;
                                income_freq_dropdownValue = appState.incomeFreq; // Update selected
                              });
                            }
                          ),
                          ),
                          )
                        ),


                    //  ADD INCOME BUTTON
                    Padding( 
                      padding: const EdgeInsets.only(
                        left: 20,
                        right: 0,
                        top: 0,
                        bottom: 20,
                      ),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: SizedBox(
                          width: 50,
                          height: 40,
                          child: IconButton(
                            onPressed: () async{
                              // SENT INCOME TO DB/BACKEND
                                final sendIncomeChannel = {'name': appState.incomeName.toString(), 'monthly_earning': appState.incomeValue.toStringAsFixed(2),'frequency': appState.incomeFreq.toString()};           
                                final sentIncomeChannel = await MyApp.of(context).flaskConnect.sendData('incomeChannel/add', sendIncomeChannel);
                                var data2 = sentIncomeChannel;
                              setState(() {
                                //sentIncomeChannel.then((data){ 
                                
                                var id = data2['message']; 
                                print("The ID sent $id");
                                appState.incomeID = id.toString();
                                appState.incomeidList.add((appState.incomeID));

                                //});

                                //UPDATE ICONS
                                appState.incomeFrequencyIcon = incomeFrequencyIcon;
                                appState.incomeFreqList.add(appState.incomeFrequencyIcon);
                                //  ADD INCOME TO INCOME LIST
                                appState.incomeList.add(("${appState.incomeName} ${appState.incomeValue.toStringAsFixed(2)}")); //Interpolation
                                appState.incomeValueList.add((appState.incomeName, appState.incomeValue)); // Separate list for calcualtions
                                appState.balance += appState.incomeValue; // adds income to remaining balance
                                appState.income += appState.incomeValue; // add income value to income

                                // CALCULATE WANT/NEED/SAVINGS PERCENTAGES [want/need amounts in relation to total income]
                                appState.wantPercentage = appState.wantTotal / appState.income;
                                appState.needPercentage = appState.needTotal / appState.income;
                                appState.savingsPercentage = 100 - (appState.wantPercentage*100 + appState.needPercentage*100);

                      
                              
                              });
                            }, 
                            icon: Icon(Icons.add),
                            )
                        ),
                      ),
                    ),   

                  ],
                ),
                SizedBox(
                  height: 210,
                )
            ],
          ),
        ),
      )
    );

  }
}

class SignUpPage extends StatefulWidget{

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}   
// USER PASSWORD AND EMAIL INPUT GETTERS
final emailController = TextEditingController();
final passwordController = TextEditingController();
final usernameController = TextEditingController();
class _SignUpPageState extends State<SignUpPage> {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    Widget page;
    
    final usernameformKey = GlobalKey<FormState>();

    final emailformKey = GlobalKey<FormState>();
    final passwordformKey = GlobalKey<FormState>();


    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          color: Colors.grey.withOpacity(0.5),
          image: DecorationImage(
            image: AssetImage('assets/images/signup1.jpg'),
            opacity: 0.9,
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          children: [
            SizedBox(height: 10,), //Adds a bit of space between top bar to image
            Container(
              padding: EdgeInsets.all(30), //Dictates size of image container i.e. image size basically
              width: 80,
              decoration: BoxDecoration( //Adds logo image to container
                image: DecorationImage(
                  alignment: Alignment.topCenter,
                  fit: BoxFit.fill,
                  image: AssetImage('assets/images/temp_logo_1.png'), //Image
                ),
              ),
            ),
      
      
            SizedBox(height:20,), //The Create Your Account Text and space between Logo
            Padding(
              padding: const EdgeInsets.only(
                left: 0,
                right: 20,
                top: 0,
                bottom: 5,
              ),
              child: Align(
                alignment: Alignment.center,
                child: Text('Create your Financial Account', 
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Noto Sans',
                  fontSize: 40,
                ),
                ),
                ),
            ),
            
      
            Padding(                          //Don't have an account? Sign up!
              padding: const EdgeInsets.only(
                left: 30,
                right: 20,
                top: 1,
                bottom: 5,
              ),
              child: Row( // 'Don't have an account?' Sign Up Text and Button
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                Text("Already have an account?",
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    //fontWeight: FontWeight.bold,
                    fontFamily: 'Noto Sans',
                    fontSize: 15,
                  ),
                ),     
                TextButton(
                  onPressed: (){ 
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => MyHomePage()), //Goes to Log in page
                    );
                    // Do thing after they press this
                  },
                  style: ButtonStyle(
                    overlayColor: MaterialStateProperty.all(Colors.transparent), //Removes highlight when hovering on 'Forgot Password'
                  ),
      
                  child: Text( // Log In Button from Sign up screen
                    "Login!",
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Noto Sans',
                      fontSize: 15,
                      shadows: [
                        Shadow(
                            color: Theme.of(context).colorScheme.primary, //colour of text (it's a shadow, ik, but it works)
                            offset: Offset(0, -1))
                      ],
                      color: Colors.transparent,
                      decoration:
                      TextDecoration.underline,
                      decorationColor: Theme.of(context).colorScheme.primary,
                      decorationThickness: 1,
                    ),
                  ),
                ),   
                ],
              ),
            ),
      
                  Padding(          // USERNAME HEADING
              padding: const EdgeInsets.only(
                left: 400,
                right: 20,
                top: 40,
                bottom: 5,
              ),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text("Username", 
                textAlign: TextAlign.left,)
                ),
            ),

            Padding(                          //USERNAME TEXT FIELD
              padding: const EdgeInsets.only(
                left: 390,
                right: 400,
                top: 0,
                bottom: 20,
              ),
              child: Form(
                key: usernameformKey,
                child: TextFormField(
                  validator: (value){ // Value = What the user inputs
                    if (value!.isEmpty) {
                      return 'Username cannot be empty'; // Send this back as Error
                    }
                    return null; // If everything is valid, send back 'null' meaning no errors
                  },
                  onChanged: (newValue) { // Validate in realtime
                    usernameformKey.currentState!.validate();
                    appState.username = newValue;
                  },
                  controller: usernameController, // FOR JON
                            
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    floatingLabelBehavior: FloatingLabelBehavior.never, //Removes annoying floating label text on click
                    labelText: 'Username',
                    labelStyle: TextStyle( //Changes label Text Font
                      fontFamily: 'Nato Sans'
                    ),
                    hintText: 'What should we call you?',
                    hintStyle: TextStyle( //Changes hint Text Font
                      fontFamily: 'Nato Sans'
                    ),
                  ),
                ),
              ),
            ),


            Padding(          // The text and padding between Email and Email Text Field
              padding: const EdgeInsets.only(
                left: 400,
                right: 20,
                top: 0,
                bottom: 5,
              ),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text("E-Mail", 
                textAlign: TextAlign.left,)
                ),
            ),
            
      
            Padding(                          //E-MAIL TEXT FIELD
              padding: const EdgeInsets.only(
                left: 390,
                right: 400,
                top: 0,
                bottom: 3,
              ),
              child: Form( // Form for validation
          
                key: emailformKey,
                child: TextFormField(
                  validator: (value){ // Value = What the user inputs
                    if (value!.isEmpty) {
                      return 'Email cannot be empty'; // Send this back as Error
                    }
                    else if(!value.contains('@') || !value.contains('.')){ // If there is no number in password
                      return 'Please enter a valid email address. E.g. example@example.com';
                    }
                    return null; // If everything is valid, send back 'null' meaning no errors
                  },
                  onChanged: (newValue) { // Validate in realtime
                    emailformKey.currentState!.validate();
                  },

                  controller: emailController, // For Jon
                  
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                floatingLabelBehavior: FloatingLabelBehavior.never, //Removes annoying floating label text on click
                labelText: 'E-Mail',
                labelStyle: TextStyle( //Changes label Text Font
                  fontFamily: 'Nato Sans'
                ),
                hintText: 'Enter valid E-Mail',
                hintStyle: TextStyle( //Changes hint Text Font
                  fontFamily: 'Nato Sans'
                ),
              ),
            ),
          ),
            ),
      
      
            Padding(          // The text and padding between Password and Password Text Field
              padding: const EdgeInsets.only(
                left: 400,
                right: 20,
                top: 15,
                bottom: 5,
              ),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text("Password", 
                textAlign: TextAlign.left,
                )
                ),
            ),
      
      
            Padding(                          //PASSWORD TEXT FIELD
              padding: const EdgeInsets.only(
                left: 390,
                right: 400,
                top: 0,
                bottom: 0,
              ),
                 child: Form( // Form for validation
                key: passwordformKey,
                child: TextFormField(
                  validator: (value){ // Value = What the user inputs
                    if (value!.isEmpty) {
                      return 'Password cannot be empty'; // Send this back as Error
                    }
                    else if(num.tryParse(value.replaceAll(RegExp(r'[^0-9,.]'), '')) == null){ // If there is no number in password
                      return 'Password must contain a number';
                    }
                    return null; // If everything is valid, send back 'null' meaning no errors
                  },
                  onChanged: (newValue) { // Validate in realtime
                    passwordformKey.currentState!.validate();
                  },

                  controller: passwordController, // For Jon

              obscureText: true, //Adds the Asteriks for Password confidentiality
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.lock_open, color: Colors.grey),
              
                border: OutlineInputBorder(),
                floatingLabelBehavior: FloatingLabelBehavior.never, //Removes annoying floating label text on click
                labelText: 'Password',
                labelStyle: TextStyle( //Changes Font
                  fontFamily: 'Nato Sans'
                ),
                hintText: 'Enter your Password',
                hintStyle: TextStyle( //Changes Font
                  fontFamily: 'Nato Sans'
                ),
              ),
            ),
          ),
            ),
      
            Padding(                          //NEXT BUTTON
              padding: const EdgeInsets.only(
                left: 0,
                right: 10,
                top: 30,
                bottom: 5,
              ),
              child: Align(
                alignment: Alignment.center,
                child: SizedBox( //Box inwhich button is kept within to control size
                  width: 460,
                  height: 50,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom( //Style button to make it more rectangular but with rounded edges
                      backgroundColor: Theme.of(context).colorScheme.onBackground,
                      foregroundColor: Theme.of(context).colorScheme.onPrimary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                      side: BorderSide.none, //Removes border colour from button
                    ),
                    onPressed: (){ //After clicking Login  
                      //Add user info here and save until complete
                      //appState.newUserEmail = "";
                      //appState.newUserPassword = "";

                        // This is the Error Handling Jon
                        if (!emailformKey.currentState!.validate()) { // Checks if Email is Valid, then does something
                          appState.createSpace = 1; // I use this later just to make some space for errors
                        }
                        if (!passwordformKey.currentState!.validate()) { // Checks if Password is Valid, then does something
                          appState.createSpace = 1; // I use this later just to make some space for errors
                        }
                        if (!usernameformKey.currentState!.validate()) { // Checks if Username is Valid, then does something
                          appState.createSpace = 1; // I use this later just to make some space for errors
                        }
                        // If Username, Email and Password are valid, Login
                        if (emailformKey.currentState!.validate() && passwordformKey.currentState!.validate() && usernameformKey.currentState!.validate()){
                            //var login = MyApp.of(context).flaskConnect.fetchData('login');
                        //final sendCredentials= {'email': 'bob@gmail.com', 'password': 'pass123'};
                          appState.newUserEmail = emailController.text;
                          appState.newUserPassword = passwordController.text;
                          appState.username = usernameController.text;
                          print("vale ${appState.newUserEmail}");
                          Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => FinancialAccountCreationPage()),
                            );
                        
                      }//if valid_user 
                     
                    }, //onpressed
                    child: Text('Next')),
                ),
              ),
            ),
            
      
          ],
        ),
      ),
    );
    
  }
}

class FinancialAccountCreationPage extends StatefulWidget{
  static DateTime selectedDate = DateTime.now();

  
  @override
  State<FinancialAccountCreationPage> createState() => _FinancialAccountCreationPageState();
}
final balanceController = TextEditingController();
final annualincomeController = TextEditingController();
final livingexpenseController = TextEditingController();
final subscriptionexpenseController = TextEditingController();
final mortgageController = TextEditingController();
final annualinterestController = TextEditingController();
final savingsgoalController = TextEditingController();

class _FinancialAccountCreationPageState extends State<FinancialAccountCreationPage> {
  
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: FinancialAccountCreationPage.selectedDate,
        firstDate: DateTime(2023, 1),
        lastDate: DateTime(2101));
    if (picked != null && picked != FinancialAccountCreationPage.selectedDate) {
      setState(() {
        FinancialAccountCreationPage.selectedDate = picked;
        //print(FinancialAccountCreationPage.selectedDate);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    // User inputs
    String dropdownValue = appState.creditCardList.first;
    DateTime chosenDate = (appState.selectedDate);
   
    String beginningbalance;
    String annualincome;
    String livingexpense;
    String subscriptionexpense;
    String mortgage;
    String annualinterest;
    String savingsgoal;
    //Checkboxes
    bool? check1 = false;   //House
    bool? check2 = false;   //Retirement
    bool? check3 = false;   //Travel
    bool? check4 = false;   //Electronics  
    bool? check5 = false;   //Family
    bool? check6 = false;   //Education
    bool? check7 = false;   //Emergency Funds
    bool? check8 = false;   //Homeware
    bool? check9 = false;   //Shopping
    bool? check10 = false;  //Mortgage
    bool? check11 = false;  //Car
    bool? check12 = false;  //Other

    Map<String,dynamic> checkedgoals = {};





    return DefaultTabController(
      initialIndex: 0,
      length: 1, //number of tabs
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Back'), // Back text
          
          // Complete Account Creation Button
          actions: [
            Padding(
              padding: const EdgeInsets.only(
                right: 20,
              ),
              child: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(
                      right: 20,
                    ),
                    child: Text('Complete',
                      style: TextStyle(
                        fontFamily: 'Open Sans',
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.check),
                    iconSize: 25,
                    tooltip: 'Complete',
                    onPressed: () async { //ADD HERE
                          if (appState.check1 == true){checkedgoals['House'] = '0.00';}
                          if (appState.check2 == true){checkedgoals['Retirement'] = '0.00';}
                          if (appState.check3 == true){checkedgoals['Travel'] = '0.00';}
                          if (appState.check4 == true){checkedgoals['Electronics'] = '0.00';}
                          if (appState.check5 == true){checkedgoals['Family'] = '0.00';}
                          if (appState.check6 == true){checkedgoals['Education'] = '0.00';}
                          if (appState.check7 == true){checkedgoals['Emergency Funds'] = '0.00';}
                          if (appState.check8 == true){checkedgoals['Homeware'] = '0.00';}
                          if (appState.check9 == true){checkedgoals['Shopping'] = '0.00';}
                          if (appState.check10 == true){checkedgoals['Mortgage'] = '0.00';}
                          if (appState.check11 == true){checkedgoals['Car'] = '0.00';}
                          if (appState.check11 == true){checkedgoals['Other'] = '${appState.savingsgoal}';}

                          //checkedgoals['single':]
                          print('Usa dem ${checkedgoals['other']}');
                          checkedgoals['Other'] = '${appState.savingsgoal}';

                          final sendCredentials= {'username':appState.username,'email': appState.newUserEmail, 'password': appState.newUserPassword, 'beginning_balance':appState.beginbalance.toStringAsFixed(2)};
                          final sentCredentials= await MyApp.of(context).flaskConnect.sendData('signup', sendCredentials); 
                          var data = sentCredentials;
                          //sentCredentials.then((data){   
                            if (data['message'] == 'Success'){
                              print('this works');
                              String tkn = data['access_token'];
                              MyApp.of(context).flaskConnect.saveTokenToSharedPreferences(tkn);
                              
                              //Gets the current month and year to use for dashboard switching and reprt
                              appState.currMonth = data['month'];
                              appState.repMonth = data['month'];
                              
                              appState.currYear = data['year'];
                              appState.repYear = data['year'];
                              appState.username = data['username'];
                              //gets staring balance of user
                              double bBalance = double.parse(data['beg_balance']);                
                              //print("The ID sent $id");
                              appState.clearAllLists();
                              appState.balance = bBalance; //Dis correct?
                              appState.beginbalance = bBalance; //would change each month
                              print("The Beginning balnce sent ${appState.beginbalance}");
                              appState.valid_user =false; //Added so when a user is not valid it wont brake system
                          }
                          
                          
                          final sdCredentials2= checkedgoals;
                          final stCredentials2= await MyApp.of(context).flaskConnect.sendData('signup/goals', sdCredentials2); //signup/goals
                          print(sdCredentials2);


                      //appState.newUserEmail,appState.newUserPassword appState.balance send here

                      // Go to home page
                      Navigator.push(
                        context, 
                        MaterialPageRoute(builder: (context) => MainPage(),
                        ),
                        );
                    }
                  ),
                ],
              ),
            )
          ],

          scrolledUnderElevation: 4.0,
          shadowColor: Theme.of(context).shadowColor,

          // The Top Selection Bar
          bottom: TabBar(
            tabs: <Widget>[
              Tab(
                icon: const Icon(Icons.attach_money),
                text: 'Finances',
              ),
              // Tab(
              //   icon: const Icon(Icons.account_balance),
              //   text: 'Taxes & Interests',
              // ),
              // Tab(
              //   icon: const Icon(Icons.auto_awesome),
              //   text: 'Goals',
              // ),
            ],
          ),
        ),

        //  TABS
        body: TabBarView(
          children: <Widget>[

            // FIRST TAB
            Scaffold(
              body: Container(
                decoration: BoxDecoration( //Adds logo image to container
                  color: Colors.white10.withOpacity(1),
                  image: DecorationImage(
                    //alignment: Alignment.topCenter,
                    fit: BoxFit.fill,
                    image: AssetImage('assets/images/home_background2.jpg'), //Image
                    opacity: 0.5,
                  ),
                ),
                child: Column(
                  children: [
              
                    // FINANCES
              
                    // Padding(          // The text and padding between Card Type and Salary Text Field
                    //   padding: const EdgeInsets.only(
                    //     left: 50,
                    //     right: 20,
                    //     top: 40,
                    //     bottom: 5,
                    //   ),
                    //   child: Align(
                    //     alignment: Alignment.centerLeft,
                    //     child: Text("Select Credit Card*", 
                    //     textAlign: TextAlign.left,)
                    //     ),
                    // ),
                    
                          
                    // Padding(                          //CARD TYPE POP UP/DROP DOWN MENU
                    //   padding: const EdgeInsets.only(
                    //     left: 50,
                    //     right: 400,
                    //     top: 0,
                    //     bottom: 0,
                    //   ),
                    //   child: Align(
                    //     alignment: Alignment.centerLeft,
              
                    //     //    CREDIT CARD POP UP/DROP DOWN MENU 
                    //     child: Container(
                    //       width: 135,
                    //       height: 50,
                    //       decoration: BoxDecoration(
                    //         border: Border.all(width: 1, color: Colors.black.withOpacity(0.5)),
                    //         borderRadius: BorderRadius.all(Radius.circular(5))
                    //       ),
                    //       child: PopupMenuButton( //Create pop up menu
                    //         shape: RoundedRectangleBorder( //Change border for menu
                    //         side: BorderSide(style: BorderStyle.solid, width: 0.3), //adds a line around the border
                    //         borderRadius: BorderRadius.all(Radius.circular(5.0))
                    //         ), 
                    //         // Configure pop up menu
                    //         itemBuilder: (context) {
                    //           return appState.creditCardList.map((str) { // Create drop down menu items from given list
                    //             return PopupMenuItem(
                    //               value: str,
                    //               child: Text(str,
                    //                 //little bit of style for the text
                    //                 style: TextStyle(
                    //                   fontFamily: 'Nato Sans',
                    //                   fontSize: 15,
                    //                 ),
                    //               ),
                                  
                    //             );
                    //           }).toList();
                    //         },
              
                    //         child: Row( // Displayed Choice and Icon
                    //           mainAxisSize: MainAxisSize.min,
                    //           mainAxisAlignment: MainAxisAlignment.start,
                    //           children: <Widget>[
                    //             Padding(
                    //               padding: const EdgeInsets.only(
                    //                 left: 10,
                    //               ),
                    //               child: Text(appState.creditcard, //selected card text
              
                    //               ),
                    //             ),
                    //             Icon(Icons.credit_card),
                    //           ],
                    //         ),
              
                    //         onSelected: (String? choice) { // Called when the user selects an item
                    //           appState.creditcard = choice!; // Set global variable to chosen card
                    //           setState(() {
                    //             dropdownValue = appState.creditcard; // Update selected
                    //           });
                    //         },
                    //       ),
                    //       ),
                    //       )
                    //     ),
              
                    Padding(          // The text and padding between Text Field
                      padding: const EdgeInsets.only(
                        left: 50,
                        right: 20,
                        top: 40,
                        bottom: 5,
                      ),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text("Beginning Balance*", 
                        textAlign: TextAlign.left,
                        )
                        ),
                    ),
                          
                          
                    Padding(                          //BEGINNING BALANCE TEXT FIELD
                      padding: const EdgeInsets.only(
                        left: 50,
                        right: 400,
                        top: 0,
                        bottom: 0,
                      ),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: SizedBox(
                          width: 460,
                          height: 50,
                          child: TextField(
                            controller: balanceController, // Get User Input
                            onChanged: (value) { // If any text is entered
                              beginningbalance = balanceController.text;
                              if (beginningbalance != ""){
                                appState.balance = double.parse(beginningbalance);
                                appState.beginbalance = double.parse(beginningbalance);
                              }
                            },

                            decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              floatingLabelBehavior: FloatingLabelBehavior.never, //Removes annoying floating label text on click
                              labelText: 'Balance',
                              labelStyle: TextStyle( //Changes Font
                                fontFamily: 'Nato Sans'
                              ),
                            ),
                          ),
                        ),
                      ),
                    ), 


                    // GOALS IN FINANCES TAB

                  Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: const EdgeInsets.only(
                        left: 50,
                        right: 20,
                        top: 15,
                        bottom: 15,
                      ),
                      child: Row(
                        children: [
                          Text("Select your Reasons for Saving", 
                            style: TextStyle(
                              fontFamily: 'Open Sans',
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.left,),
                          Padding(
                            padding: const EdgeInsets.only(
                              left: 10,
                            ),
                            child: Text("(can be changed later)", 
                              style: TextStyle(
                                fontSize: 12,
                                fontStyle: FontStyle.italic,
                              ),
                              textAlign: TextAlign.left,),
                          ),
                        ],
                      ),
                    )
                    ),

                    //  HOME SAVING CHECKBOX 
                    Padding(
                      padding: const EdgeInsets.only(
                        left: 50,
                        right: 20,
                        top: 0,
                        bottom: 5,
                      ),
                      child: Row(
                        children: [
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Padding(
                              padding: const EdgeInsets.only(
                                right: 10,
                              ),
                              child: Text("House", 
                              textAlign: TextAlign.left,),
                            )
                            ),

                          Align(
                            alignment: Alignment.centerLeft,
                            child: Padding(
                              padding: const EdgeInsets.only(
                                left: 76,
                              ),
                              child: Row(
                                children: [
                                  Checkbox(
                                    value: appState.check1,
                                    onChanged:(bool? value) {
                                      setState(() {
                                        check1 = value;
                                        appState.check1 = check1;
                                      });
                                    },
                                    ),

                                //  RETIREMENT SAVINGS CHECKBOX
                                Padding(
                                  padding: const EdgeInsets.only(
                                    left: 50,
                                    right: 20,
                                    top: 0,
                                    bottom: 5,
                                  ),
                                  child: Row(
                                    children: [
                                      Align(
                                        alignment: Alignment.centerLeft,
                                        child: Padding(
                                          padding: const EdgeInsets.only(
                                            right: 10,
                                          ),
                                          child: Text("Retirement", 
                                          textAlign: TextAlign.left,),
                                        )
                                        ),

                                      Align(
                                        alignment: Alignment.centerLeft,
                                        child: Padding(
                                          padding: const EdgeInsets.only(
                                            left: 42,
                                          ),
                                          child: Checkbox(
                                            value: appState.check2,
                                            onChanged:(bool? value) {
                                              setState(() {
                                                check2 = value;
                                                appState.check2 = check2;
                                              });
                                            },
                                            ),
                                        ),
                                      ),   
                                    ],
                                  ),
                                ),

                                ],
                              ),
                            ),
                          ),   
                        ],
                      ),
                    ),

                    //  TRAVEL SAVINGS CHECKBOX
                    Padding(
                      padding: const EdgeInsets.only(
                        left: 50,
                        right: 20,
                        top: 0,
                        bottom: 5,
                      ),
                      child: Row(
                        children: [
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Padding(
                              padding: const EdgeInsets.only(
                                right: 10,
                              ),
                              child: Text("Travel", 
                              textAlign: TextAlign.left,),
                            )
                            ),

                          Align(
                            alignment: Alignment.centerLeft,
                            child: Padding(
                              padding: const EdgeInsets.only(
                                left: 77,
                              ),
                              child: Row(
                                children: [
                                  Checkbox(
                                    value: appState.check3,
                                    onChanged:(bool? value) {
                                      setState(() {
                                        check3 = value;
                                        appState.check3 = check3;
                                      });
                                    },
                                    ),

                                  //  ELECTRONICS SAVINGS CHECKBOX
                                  Padding(
                                    padding: const EdgeInsets.only(
                                      left: 50,
                                      right: 20,
                                      top: 0,
                                      bottom: 5,
                                    ),
                                    child: Row(
                                      children: [
                                        Align(
                                          alignment: Alignment.centerLeft,
                                          child: Padding(
                                            padding: const EdgeInsets.only(
                                              right: 10,
                                            ),
                                            child: Text("Electronics", 
                                            textAlign: TextAlign.left,),
                                          )
                                          ),

                                        Align(
                                          alignment: Alignment.centerLeft,
                                          child: Padding(
                                            padding: const EdgeInsets.only(
                                              left: 44,
                                            ),
                                            child: Checkbox(
                                              value: appState.check4,
                                              onChanged:(bool? value) {
                                                setState(() {
                                                  check4 = value;
                                                  appState.check4 = check4;
                                                });
                                              },
                                              ),
                                          ),
                                        ),   
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),   
                        ],
                      ),
                    ),

                    //  FAMILY SAVINGS CHECKBOX
                    Padding(
                      padding: const EdgeInsets.only(
                        left: 50,
                        right: 20,
                        top: 0,
                        bottom: 5,
                      ),
                      child: Row(
                        children: [
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Padding(
                              padding: const EdgeInsets.only(
                                right: 10,
                              ),
                              child: Text("Family", 
                              textAlign: TextAlign.left,),
                            )
                            ),

                          Align(
                            alignment: Alignment.centerLeft,
                            child: Padding(
                              padding: const EdgeInsets.only(
                                left: 75,
                              ),
                              child: Row(
                                children: [
                                  Checkbox(
                                    value: appState.check5,
                                    onChanged:(bool? value) {
                                      setState(() {
                                        check5 = value;
                                        appState.check5 = check5;
                                      });
                                    },
                                    ),

                                  //  EDUCATION SAVINGS CHECKBOX
                                  Padding(
                                    padding: const EdgeInsets.only(
                                      left: 50,
                                      right: 20,
                                      top: 0,
                                      bottom: 5,
                                    ),
                                    child: Row(
                                      children: [
                                        Align(
                                          alignment: Alignment.centerLeft,
                                          child: Padding(
                                            padding: const EdgeInsets.only(
                                              right: 10,
                                            ),
                                            child: Text("Education", 
                                            textAlign: TextAlign.left,),
                                          )
                                          ),

                                        Align(
                                          alignment: Alignment.centerLeft,
                                          child: Padding(
                                            padding: const EdgeInsets.only(
                                              left: 51,
                                            ),
                                            child: Checkbox(
                                              value: appState.check6,
                                              onChanged:(bool? value) {
                                                setState(() {
                                                  check6 = value;
                                                  appState.check6 = check6;
                                                });
                                              },
                                              ),
                                          ),
                                        ),   
                                      ],
                                    ),
                                  ),

                                ],
                              ),
                            ),
                          ),   
                        ],
                      ),
                    ),

                    //  EMERGENCY FUNDS SAVINGS CHECKBOX
                    Padding(
                      padding: const EdgeInsets.only(
                        left: 50,
                        right: 20,
                        top: 0,
                        bottom: 5,
                      ),
                      child: Row(
                        children: [
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Padding(
                              padding: const EdgeInsets.only(
                                right: 8,
                              ),
                              child: Text("Emergency Funds", 
                              textAlign: TextAlign.left,),
                            )
                            ),

                          Align(
                            alignment: Alignment.centerLeft,
                            child: Row(
                              children: [
                                Checkbox(
                                  value: appState.check7,
                                  onChanged:(bool? value) {
                                    setState(() {
                                      check7 = value;
                                      appState.check7 = check7;
                                    });
                                  },
                                  ),

                                //  HOMEWARE SAVINGS CHECKBOX
                                Padding(
                                  padding: const EdgeInsets.only(
                                    left: 50,
                                    right: 20,
                                    top: 0,
                                    bottom: 5,
                                  ),
                                  child: Row(
                                    children: [
                                      Align(
                                        alignment: Alignment.centerLeft,
                                        child: Padding(
                                          padding: const EdgeInsets.only(
                                            right: 10,
                                          ),
                                          child: Text("Homeware", 
                                          textAlign: TextAlign.left,),
                                        )
                                        ),

                                      Align(
                                        alignment: Alignment.centerLeft,
                                        child: Padding(
                                          padding: const EdgeInsets.only(
                                            left: 44,
                                          ),
                                          child: Checkbox(
                                            value: appState.check8,
                                            onChanged:(bool? value) {
                                              setState(() {
                                                check8 = value;
                                                appState.check8 = check8;
                                              });
                                            },
                                            ),
                                        ),
                                      ),   
                                    ],
                                  ),
                                ),

                              ],
                            ),
                          ),   
                        ],
                      ),
                    ),

                    //  SHOPPING SAVINGS CHECKBOX
                    Padding(
                      padding: const EdgeInsets.only(
                        left: 50,
                        right: 20,
                        top: 0,
                        bottom: 5,
                      ),
                      child: Row(
                        children: [
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Padding(
                              padding: const EdgeInsets.only(
                                right: 10,
                              ),
                              child: Text("Shopping", 
                              textAlign: TextAlign.left,),
                            )
                            ),

                          Align(
                            alignment: Alignment.centerLeft,
                            child: Padding(
                              padding: const EdgeInsets.only(
                                left: 55,
                              ),
                              child: Row(
                                children: [
                                  Checkbox(
                                    value: appState.check9,
                                    onChanged:(bool? value) {
                                      setState(() {
                                        check9 = value;
                                        appState.check9 = check9;
                                      });
                                    },
                                    ),

                                //  MORTGAGE DOWN PAYMENT SAVINGS CHECKBOX
                                Padding(
                                  padding: const EdgeInsets.only(
                                    left: 50,
                                    right: 20,
                                    top: 0,
                                    bottom: 5,
                                  ),
                                  child: Row(
                                    children: [
                                      Align(
                                        alignment: Alignment.centerLeft,
                                        child: Padding(
                                          padding: const EdgeInsets.only(
                                            right: 10,
                                          ),
                                          child: Text("Mortgage", 
                                          textAlign: TextAlign.left,),
                                        )
                                        ),

                                      Align(
                                        alignment: Alignment.centerLeft,
                                        child: Padding(
                                          padding: const EdgeInsets.only(
                                            left: 54,
                                          ),
                                          child: Checkbox(
                                            value: appState.check10,
                                            onChanged:(bool? value) {
                                              setState(() {
                                                check10 = value;
                                                appState.check10 = check10;
                                              });
                                            },
                                            ),
                                        ),
                                      ),   
                                    ],
                                  ),
                                ),

                                ],
                              ),
                            ),
                          ),   
                        ],
                      ),
                    ),

                    //  CAR SAVINGS CHECKBOX
                    Padding(
                      padding: const EdgeInsets.only(
                        left: 50,
                        right: 20,
                        top: 0,
                        bottom: 5,
                      ),
                      child: Row(
                        children: [
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Padding(
                              padding: const EdgeInsets.only(
                                right: 10,
                              ),
                              child: Text("Car", 
                              textAlign: TextAlign.left,),
                            )
                            ),

                          Align(
                            alignment: Alignment.centerLeft,
                            child: Padding(
                              padding: const EdgeInsets.only(
                                left: 97,
                              ),
                              child: Row(
                                children: [
                                  Checkbox(
                                    value: appState.check11,
                                    onChanged:(bool? value) {
                                      setState(() {
                                        check11 = value;
                                        appState.check11 = check11;
                                      });
                                    },
                                    ),

                                  //  OTHER SAVINGS CHECKBOX
                                  Padding(
                                    padding: const EdgeInsets.only(
                                      left: 50,
                                      right: 20,
                                      top: 0,
                                      bottom: 5,
                                    ),
                                    child: Row(
                                      children: [
                                        Align(
                                          alignment: Alignment.centerLeft,
                                          child: Padding(
                                            padding: const EdgeInsets.only(
                                              right: 10,
                                            ),
                                            child: Text("Other", 
                                            textAlign: TextAlign.left,),
                                          )
                                          ),

                                        Align(
                                          alignment: Alignment.centerLeft,
                                          child: Padding(
                                            padding: const EdgeInsets.only(
                                              left: 80,
                                            ),
                                            child: Checkbox(
                                              value: appState.check12,
                                              onChanged:(bool? value) {
                                                setState(() {
                                                  check12 = value;
                                                  appState.check12 = check12;
                                                });
                                              },
                                              ),
                                          ),
                                        ),   
                                      ],
                                    ),
                                  ),

                                ],
                              ),
                            ),
                          ),   
                        ],
                      ),
                    ),

                    Padding(          // The text and padding between Text Field
                      padding: const EdgeInsets.only(
                        left: 50,
                        right: 20,
                        top: 15,
                        bottom: 5,
                      ),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Row(
                          children: [
                            Text("Savings Goal", 
                            textAlign: TextAlign.left,
                            ),
                            Text("   (can be changed later)",
                            style: TextStyle(
                              fontSize: 12,
                              fontStyle: FontStyle.italic,
                            ), 
                            textAlign: TextAlign.left,
                            ),
                          ],
                        )
                        ),
                    ),
                          
                          
                    Padding(                          //GOAL TEXT FIELD
                      padding: const EdgeInsets.only(
                        left: 50,
                        right: 400,
                        top: 0,
                        bottom: 0,
                      ),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: SizedBox(
                          width: 235,
                          height: 50,
                          child: TextField(
                            controller: savingsgoalController,
                            onChanged: (value) { // If any text is entered
                              savingsgoal = savingsgoalController.text;
                              if (savingsgoal != ""){
                                appState.savingsgoal = double.parse(savingsgoal);
                              }
                            },

                            decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              floatingLabelBehavior: FloatingLabelBehavior.never, //Removes annoying floating label text on click
                              labelText: 'Default: 2x Balance',
                              labelStyle: TextStyle( //Changes Font
                                fontFamily: 'Nato Sans'
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    // Padding(          // The text and padding between Text Field
                    //   padding: const EdgeInsets.only(
                    //     left: 50,
                    //     right: 20,
                    //     top: 15,
                    //     bottom: 5,
                    //   ),
                    //   child: Align(
                    //     alignment: Alignment.centerLeft,
                    //     child: Text("Enter your Annual Income*", 
                    //     textAlign: TextAlign.left,
                    //     )
                    //     ),
                    // ),
                          
                          
                    // Padding(                          //INCOME TEXT FIELD
                    //   padding: const EdgeInsets.only(
                    //     left: 50,
                    //     right: 400,
                    //     top: 0,
                    //     bottom: 0,
                    //   ),
                    //   child: Align(
                    //     alignment: Alignment.centerLeft,
                    //     child: SizedBox(
                    //       width: 460,
                    //       height: 50,
                    //       child: TextField(
                    //         controller: annualincomeController, //Get user input
                    //         onChanged: (value) { // If any text is entered
                    //           annualincome = annualincomeController.text;
                    //           if (annualincome != ""){
                    //             appState.annualincome = double.parse(annualincome);
                    //           }
                    //         },

                    //         decoration: InputDecoration(
                    //           border: OutlineInputBorder(),
                    //           floatingLabelBehavior: FloatingLabelBehavior.never, //Removes annoying floating label text on click
                    //           labelText: 'Income',
                    //           labelStyle: TextStyle( //Changes Font
                    //             fontFamily: 'Nato Sans'
                    //           ),
                    //         ),
                    //       ),
                    //     ),
                    //   ),
                    // ),
              
                    // Padding(          // The text and padding between Text Field
                    //   padding: const EdgeInsets.only(
                    //     left: 50,
                    //     right: 20,
                    //     top: 15,
                    //     bottom: 5,
                    //   ),
                    //   child: Align(
                    //     alignment: Alignment.centerLeft,
                    //     child: Text("Enter your Overall Monthly Living Expenses*", 
                    //     textAlign: TextAlign.left,
                    //     )
                    //     ),
                    // ),
              
                    // Padding(                          //LIVING EXPENSE TEXT FIELD
                    //   padding: const EdgeInsets.only(
                    //     left: 50,
                    //     right: 400,
                    //     top: 0,
                    //     bottom: 0,
                    //   ),
                    //   child: Align(
                    //     alignment: Alignment.centerLeft,
                    //     child: SizedBox(
                    //       width: 460,
                    //       height: 50,
                    //       child: TextField(
                    //         controller: livingexpenseController, //Get User Input
                    //         onChanged: (value) { // If any text is entered
                    //           livingexpense = livingexpenseController.text;
                    //           if (livingexpense != ""){
                    //             appState.livingexpense = double.parse(livingexpense);
                    //           }
                    //         },

                    //         decoration: InputDecoration(
                    //           border: OutlineInputBorder(),
                    //           floatingLabelBehavior: FloatingLabelBehavior.never, //Removes annoying floating label text on click
                    //           labelText: 'Monthly Expense',
                    //           labelStyle: TextStyle( //Changes Font
                    //             fontFamily: 'Nato Sans'
                    //           ),
                    //         ),
                    //       ),
                    //     ),
                    //   ),
                    // ),
              
                    // Padding(          // The text and padding between Text Field
                    //   padding: const EdgeInsets.only(
                    //     left: 50,
                    //     right: 20,
                    //     top: 15,
                    //     bottom: 5,
                    //   ),
                    //   child: Align(
                    //     alignment: Alignment.centerLeft,
                    //     child: Row(
                    //       children: [
                    //         Text("Enter your Overall Subscriptions Expenses", 
                    //         textAlign: TextAlign.left,
                    //         ),
                    //         Text("  (Optional)",
                    //         style: TextStyle(
                    //           fontStyle: FontStyle.italic,
                    //         ), 
                    //         textAlign: TextAlign.left,
                    //         ),
                    //       ],
                    //     )
                    //     ),
                    // ),
              
                    // Padding(                          //SUBSCRIPTION EXPENSE TEXT FIELD
                    //   padding: const EdgeInsets.only(
                    //     left: 50,
                    //     right: 400,
                    //     top: 0,
                    //     bottom: 0,
                    //   ),
                    //   child: Align(
                    //     alignment: Alignment.centerLeft,
                    //     child: SizedBox(
                    //       width: 460,
                    //       height: 50,
                    //       child: TextField(
                    //         controller: subscriptionexpenseController, // Get User Input
                    //         onChanged: (value) { // If any text is entered
                    //           subscriptionexpense = subscriptionexpenseController.text;
                    //           if (subscriptionexpense != ""){
                    //             appState.subscriptionexpense = double.parse(subscriptionexpense);
                    //           }
                    //         },

                    //         decoration: InputDecoration(
                    //           border: OutlineInputBorder(),
                    //           floatingLabelBehavior: FloatingLabelBehavior.never, //Removes annoying floating label text on click
                    //           labelText: 'Subscription Expense',
                    //           labelStyle: TextStyle( //Changes Font
                    //             fontFamily: 'Nato Sans'
                    //           ),
                    //         ),
                    //       ),
                    //     ),
                    //   ),
                    // ),
                  ],
                ),
              )
              ),

            //  SECOND TAB
            // Scaffold(
            //   body: Container(
            //     decoration: BoxDecoration( //Adds image to container
            //       color: Colors.white10.withOpacity(1),
            //       image: DecorationImage(
            //         //alignment: Alignment.topCenter,
            //         fit: BoxFit.fill,
            //         image: AssetImage('assets/images/home_background2.jpg'), //Image
            //         opacity: 0.5,
            //       ),
            //     ),
            //     child: Column(
            //       children: [
              
            //         // TAXES & INTERESTS
              
            //         Padding(          // The text and padding between Card Type and Salary Text Field
            //           padding: const EdgeInsets.only(
            //             left: 50,
            //             right: 20,
            //             top: 40,
            //             bottom: 5,
            //           ),
            //           child: Align(
            //             alignment: Alignment.centerLeft,
            //             child: Text("Filing Status*", 
            //             textAlign: TextAlign.left,)
            //             ),
            //         ),
                    
                          
            //         Padding(                          //FILING STATUS POP UP/DROP DOWN MENU
            //           padding: const EdgeInsets.only(
            //             left: 50,
            //             right: 400,
            //             top: 0,
            //             bottom: 0,
            //           ),
            //           child: Align(
            //             alignment: Alignment.centerLeft,
              
            //             //    FILING STATUS POP UP/DROP DOWN MENU 
            //             child: Container(
            //               width: 110,
            //               height: 50,
            //               decoration: BoxDecoration( // Adds border
            //                 border: Border.all(width: 1, color: Colors.black.withOpacity(0.5)),
            //                 borderRadius: BorderRadius.all(Radius.circular(5))
            //               ),
            //               child: PopupMenuButton( //Create pop up menu
            //                 shape: RoundedRectangleBorder( //Change border for menu
            //                 side: BorderSide(style: BorderStyle.solid, width: 0.3), //adds a line around the border
            //                 borderRadius: BorderRadius.all(Radius.circular(5.0))
            //                 ), 
            //                 // Configure pop up menu
            //                 itemBuilder: (context) {
            //                   return appState.marriedOrSingleList.map((str) { // Create drop down menu items from given list
            //                     return PopupMenuItem(
            //                       value: str,
            //                       child: Text(str,
            //                         //little bit of style for the text
            //                         style: TextStyle(
            //                           fontFamily: 'Nato Sans',
            //                           fontSize: 15,
            //                         ),
            //                       ),
                                  
            //                     );
            //                   }).toList();
            //                 },
              
            //                 child: Row( // Displayed Choice and Icon
            //                   mainAxisSize: MainAxisSize.min,
            //                   mainAxisAlignment: MainAxisAlignment.start,
            //                   children: <Widget>[
            //                     Padding(
            //                       padding: const EdgeInsets.only(
            //                         left: 10,
            //                       ),
            //                       child: Text(appState.singlemarried, //selected card text
              
            //                       ),
            //                     ),
            //                     // ICON
            //                     Padding( // spaces between icon and chosen filing status
            //                       padding: const EdgeInsets.only(
            //                         left: 5,
            //                       ),
            //                       child: Icon(Icons.group),
            //                     ),
            //                   ],
            //                 ),
              
            //                 onSelected: (String? choice) { // Called when the user selects an item
            //                   appState.singlemarried = choice!; // Set global variable to chosen card
            //                   setState(() {
            //                     dropdownValue = appState.singlemarried; // Update selected
            //                   });
            //                 },
            //               ),
            //               ),
            //               )
            //             ),
              
                          
                          
            //         Padding(          // The text and padding between Text Field
            //           padding: const EdgeInsets.only(
            //             left: 50,
            //             right: 20,
            //             top: 15,
            //             bottom: 5,
            //           ),
            //           child: Align(
            //             alignment: Alignment.centerLeft,
            //             child: Row(
            //               children: [
            //                 Text("Mortgage Interest", 
            //                 textAlign: TextAlign.left,
            //                 ),
            //                 Text("  (Optional)",
            //                 style: TextStyle(
            //                   fontStyle: FontStyle.italic,
            //                 ), 
            //                 textAlign: TextAlign.left,
            //                 ),
            //               ],
            //             )
            //             ),
            //         ),
                          
                          
            //         Padding(                          //MORTGAGE TEXT FIELD
            //           padding: const EdgeInsets.only(
            //             left: 50,
            //             right: 400,
            //             top: 0,
            //             bottom: 0,
            //           ),
            //           child: Align(
            //             alignment: Alignment.centerLeft,
            //             child: SizedBox(
            //               width: 460,
            //               height: 50,
            //               child: TextField(
            //                 controller: mortgageController, // Get User Input
            //                 onChanged: (value) { // If any text is entered
            //                   mortgage = mortgageController.text;
            //                   if (mortgage != ""){
            //                     appState.mortgage = double.parse(mortgage);
            //                   }
            //                 },

            //                 decoration: InputDecoration(
            //                   border: OutlineInputBorder(),
            //                   floatingLabelBehavior: FloatingLabelBehavior.never, //Removes annoying floating label text on click
            //                   labelText: 'Mortgage',
            //                   labelStyle: TextStyle( //Changes Font
            //                     fontFamily: 'Nato Sans'
            //                   ),
            //                 ),
            //               ),
            //             ),
            //           ),
            //         ),
              
            //         Padding(          // The text and padding between Text Field
            //           padding: const EdgeInsets.only(
            //             left: 50,
            //             right: 20,
            //             top: 15,
            //             bottom: 5,
            //           ),
            //           child: Align(
            //             alignment: Alignment.centerLeft,
            //             child: Text("Annual Interest Rate (% per year)*", 
            //             textAlign: TextAlign.left,
            //             )
            //             ),
            //         ),
              
            //         Padding(                          //ANNUAL INTEREST RATE TEXT FIELD
            //           padding: const EdgeInsets.only(
            //             left: 50,
            //             right: 400,
            //             top: 0,
            //             bottom: 0,
            //           ),
            //           child: Align(
            //             alignment: Alignment.centerLeft,
            //             child: SizedBox(
            //               width: 460,
            //               height: 50,
            //               child: TextField(
            //                 controller: annualinterestController, // Get User Input
            //                 onChanged: (value) { // If any text is entered
            //                   annualinterest = annualinterestController.text;
            //                   if (annualinterest != ""){
            //                     appState.annualinterest = double.parse(annualinterest);
            //                   }
            //                 },

            //                 decoration: InputDecoration(
            //                   border: OutlineInputBorder(),
            //                   floatingLabelBehavior: FloatingLabelBehavior.never, //Removes annoying floating label text on click
            //                   labelText: 'Interest Rate',
            //                   labelStyle: TextStyle( //Changes Font
            //                     fontFamily: 'Nato Sans'
            //                   ),
            //                 ),
            //               ),
            //             ),
            //           ),
            //         ),
              
            //         Padding(          // The text and padding between Text Field
            //           padding: const EdgeInsets.only(
            //             left: 50,
            //             right: 20,
            //             top: 15,
            //             bottom: 5,
            //           ),
            //           child: Align(
            //             alignment: Alignment.centerLeft,
            //             child: Text("First Deposit Date (YYYY-MM-DD)*", 
            //             textAlign: TextAlign.left,
            //             )
            //             ),
            //         ),

            //         //                     FIRST DEPOSIT DATE CALENDAR
            //         Padding(                          
            //           padding: const EdgeInsets.only( //spacing for select date button
            //             left: 40,
            //             right: 400,
            //             top: 0,
            //             bottom: 0,
            //           ),
            //           child: Align(
            //             alignment: Alignment.centerLeft,
            //             child: SizedBox(
            //               width: 460,
            //               height: 100,
            //               child: Column(
            //                 children: [ 
            //                   // Sets the Text to be the date chosen
            //                   Align(
            //                     alignment: Alignment.centerLeft,
            //                     child: Padding( //spacing for box with displayed date
            //                       padding: const EdgeInsets.only(
            //                         left: 10,
            //                         right: 50,
            //                         top: 0,
            //                         bottom: 0,
            //                       ),
            //                       child: Container(
            //                         decoration: BoxDecoration(
            //                           border: Border.all(width: 1, color: Colors.black.withOpacity(0.5)),
            //                           borderRadius: BorderRadius.all(Radius.circular(5))
            //                         ),
            //                         child: Padding(
            //                           padding: const EdgeInsets.all(8.0),
            //                           child: Text(
            //                             FinancialAccountCreationPage.selectedDate.toString().split(' ')[0]),
            //                         ),
            //                       ),
            //                     )),
            //                   Align(
            //                     alignment: Alignment.centerLeft,
            //                     child: Padding(
            //                       padding: const EdgeInsets.only(
            //                         top: 10,
            //                       ),
            //                       child: ElevatedButton(
            //                         onPressed: () {
            //                           _selectDate(context); // Calls function named _selectDate
            //                         },
            //                         child: const Text('Select date',
            //                           style: TextStyle(
            //                             color: Colors.black,
            //                           ),
            //                         ),
            //                       ),
            //                     ),
            //                   ),
            //                 ],
            //               ),
            //             ),
            //           ),
            //         ),

            //       ],
            //     ),
            //   )
            //   ),

            // //  THIRD TAB
            // Scaffold(
            //   body: Container(
            //     decoration: BoxDecoration( //Adds image to container
            //       color: Colors.white10.withOpacity(1),
            //       image: DecorationImage(
            //         //alignment: Alignment.topCenter,
            //         fit: BoxFit.fill,
            //         image: AssetImage('assets/images/home_background2.jpg'), //Image
            //         opacity: 0.5,
            //       ),
            //     ),
            //     child: Column(
            //       children: [
              
            //         // GOALS

            //       Align(
            //         alignment: Alignment.centerLeft,
            //         child: Padding(
            //           padding: const EdgeInsets.only(
            //             left: 50,
            //             right: 20,
            //             top: 40,
            //             bottom: 15,
            //           ),
            //           child: Row(
            //             children: [
            //               Text("Select your Reasons for Saving", 
            //                 style: TextStyle(
            //                   fontFamily: 'Open Sans',
            //                   fontWeight: FontWeight.bold,
            //                 ),
            //                 textAlign: TextAlign.left,),
            //               Padding(
            //                 padding: const EdgeInsets.only(
            //                   left: 10,
            //                 ),
            //                 child: Text("(can be changed later)", 
            //                   style: TextStyle(
            //                     fontSize: 12,
            //                     fontStyle: FontStyle.italic,
            //                   ),
            //                   textAlign: TextAlign.left,),
            //               ),
            //             ],
            //           ),
            //         )
            //         ),

            //         //  HOME SAVING CHECKBOX 
            //         Padding(
            //           padding: const EdgeInsets.only(
            //             left: 50,
            //             right: 20,
            //             top: 0,
            //             bottom: 5,
            //           ),
            //           child: Row(
            //             children: [
            //               Align(
            //                 alignment: Alignment.centerLeft,
            //                 child: Padding(
            //                   padding: const EdgeInsets.only(
            //                     right: 10,
            //                   ),
            //                   child: Text("House", 
            //                   textAlign: TextAlign.left,),
            //                 )
            //                 ),

            //               Align(
            //                 alignment: Alignment.centerLeft,
            //                 child: Padding(
            //                   padding: const EdgeInsets.only(
            //                     left: 76,
            //                   ),
            //                   child: Row(
            //                     children: [
            //                       Checkbox(
            //                         value: appState.check1,
            //                         onChanged:(bool? value) {
            //                           setState(() {
            //                             check1 = value;
            //                             appState.check1 = check1;
            //                           });
            //                         },
            //                         ),

            //                     //  RETIREMENT SAVINGS CHECKBOX
            //                     Padding(
            //                       padding: const EdgeInsets.only(
            //                         left: 50,
            //                         right: 20,
            //                         top: 0,
            //                         bottom: 5,
            //                       ),
            //                       child: Row(
            //                         children: [
            //                           Align(
            //                             alignment: Alignment.centerLeft,
            //                             child: Padding(
            //                               padding: const EdgeInsets.only(
            //                                 right: 10,
            //                               ),
            //                               child: Text("Retirement", 
            //                               textAlign: TextAlign.left,),
            //                             )
            //                             ),

            //                           Align(
            //                             alignment: Alignment.centerLeft,
            //                             child: Padding(
            //                               padding: const EdgeInsets.only(
            //                                 left: 42,
            //                               ),
            //                               child: Checkbox(
            //                                 value: appState.check2,
            //                                 onChanged:(bool? value) {
            //                                   setState(() {
            //                                     check2 = value;
            //                                     appState.check2 = check2;
            //                                   });
            //                                 },
            //                                 ),
            //                             ),
            //                           ),   
            //                         ],
            //                       ),
            //                     ),

            //                     ],
            //                   ),
            //                 ),
            //               ),   
            //             ],
            //           ),
            //         ),

            //         //  TRAVEL SAVINGS CHECKBOX
            //         Padding(
            //           padding: const EdgeInsets.only(
            //             left: 50,
            //             right: 20,
            //             top: 0,
            //             bottom: 5,
            //           ),
            //           child: Row(
            //             children: [
            //               Align(
            //                 alignment: Alignment.centerLeft,
            //                 child: Padding(
            //                   padding: const EdgeInsets.only(
            //                     right: 10,
            //                   ),
            //                   child: Text("Travel", 
            //                   textAlign: TextAlign.left,),
            //                 )
            //                 ),

            //               Align(
            //                 alignment: Alignment.centerLeft,
            //                 child: Padding(
            //                   padding: const EdgeInsets.only(
            //                     left: 77,
            //                   ),
            //                   child: Row(
            //                     children: [
            //                       Checkbox(
            //                         value: appState.check3,
            //                         onChanged:(bool? value) {
            //                           setState(() {
            //                             check3 = value;
            //                             appState.check3 = check3;
            //                           });
            //                         },
            //                         ),

            //                       //  ELECTRONICS SAVINGS CHECKBOX
            //                       Padding(
            //                         padding: const EdgeInsets.only(
            //                           left: 50,
            //                           right: 20,
            //                           top: 0,
            //                           bottom: 5,
            //                         ),
            //                         child: Row(
            //                           children: [
            //                             Align(
            //                               alignment: Alignment.centerLeft,
            //                               child: Padding(
            //                                 padding: const EdgeInsets.only(
            //                                   right: 10,
            //                                 ),
            //                                 child: Text("Electronics", 
            //                                 textAlign: TextAlign.left,),
            //                               )
            //                               ),

            //                             Align(
            //                               alignment: Alignment.centerLeft,
            //                               child: Padding(
            //                                 padding: const EdgeInsets.only(
            //                                   left: 44,
            //                                 ),
            //                                 child: Checkbox(
            //                                   value: appState.check4,
            //                                   onChanged:(bool? value) {
            //                                     setState(() {
            //                                       check4 = value;
            //                                       appState.check4 = check4;
            //                                     });
            //                                   },
            //                                   ),
            //                               ),
            //                             ),   
            //                           ],
            //                         ),
            //                       ),
            //                     ],
            //                   ),
            //                 ),
            //               ),   
            //             ],
            //           ),
            //         ),

            //         //  FAMILY SAVINGS CHECKBOX
            //         Padding(
            //           padding: const EdgeInsets.only(
            //             left: 50,
            //             right: 20,
            //             top: 0,
            //             bottom: 5,
            //           ),
            //           child: Row(
            //             children: [
            //               Align(
            //                 alignment: Alignment.centerLeft,
            //                 child: Padding(
            //                   padding: const EdgeInsets.only(
            //                     right: 10,
            //                   ),
            //                   child: Text("Family", 
            //                   textAlign: TextAlign.left,),
            //                 )
            //                 ),

            //               Align(
            //                 alignment: Alignment.centerLeft,
            //                 child: Padding(
            //                   padding: const EdgeInsets.only(
            //                     left: 75,
            //                   ),
            //                   child: Row(
            //                     children: [
            //                       Checkbox(
            //                         value: appState.check5,
            //                         onChanged:(bool? value) {
            //                           setState(() {
            //                             check5 = value;
            //                             appState.check5 = check5;
            //                           });
            //                         },
            //                         ),

            //                       //  EDUCATION SAVINGS CHECKBOX
            //                       Padding(
            //                         padding: const EdgeInsets.only(
            //                           left: 50,
            //                           right: 20,
            //                           top: 0,
            //                           bottom: 5,
            //                         ),
            //                         child: Row(
            //                           children: [
            //                             Align(
            //                               alignment: Alignment.centerLeft,
            //                               child: Padding(
            //                                 padding: const EdgeInsets.only(
            //                                   right: 10,
            //                                 ),
            //                                 child: Text("Education", 
            //                                 textAlign: TextAlign.left,),
            //                               )
            //                               ),

            //                             Align(
            //                               alignment: Alignment.centerLeft,
            //                               child: Padding(
            //                                 padding: const EdgeInsets.only(
            //                                   left: 51,
            //                                 ),
            //                                 child: Checkbox(
            //                                   value: appState.check6,
            //                                   onChanged:(bool? value) {
            //                                     setState(() {
            //                                       check6 = value;
            //                                       appState.check6 = check6;
            //                                     });
            //                                   },
            //                                   ),
            //                               ),
            //                             ),   
            //                           ],
            //                         ),
            //                       ),

            //                     ],
            //                   ),
            //                 ),
            //               ),   
            //             ],
            //           ),
            //         ),

            //         //  EMERGENCY FUNDS SAVINGS CHECKBOX
            //         Padding(
            //           padding: const EdgeInsets.only(
            //             left: 50,
            //             right: 20,
            //             top: 0,
            //             bottom: 5,
            //           ),
            //           child: Row(
            //             children: [
            //               Align(
            //                 alignment: Alignment.centerLeft,
            //                 child: Padding(
            //                   padding: const EdgeInsets.only(
            //                     right: 8,
            //                   ),
            //                   child: Text("Emergency Funds", 
            //                   textAlign: TextAlign.left,),
            //                 )
            //                 ),

            //               Align(
            //                 alignment: Alignment.centerLeft,
            //                 child: Row(
            //                   children: [
            //                     Checkbox(
            //                       value: appState.check7,
            //                       onChanged:(bool? value) {
            //                         setState(() {
            //                           check7 = value;
            //                           appState.check7 = check7;
            //                         });
            //                       },
            //                       ),

            //                     //  HOMEWARE SAVINGS CHECKBOX
            //                     Padding(
            //                       padding: const EdgeInsets.only(
            //                         left: 50,
            //                         right: 20,
            //                         top: 0,
            //                         bottom: 5,
            //                       ),
            //                       child: Row(
            //                         children: [
            //                           Align(
            //                             alignment: Alignment.centerLeft,
            //                             child: Padding(
            //                               padding: const EdgeInsets.only(
            //                                 right: 10,
            //                               ),
            //                               child: Text("Homeware", 
            //                               textAlign: TextAlign.left,),
            //                             )
            //                             ),

            //                           Align(
            //                             alignment: Alignment.centerLeft,
            //                             child: Padding(
            //                               padding: const EdgeInsets.only(
            //                                 left: 44,
            //                               ),
            //                               child: Checkbox(
            //                                 value: appState.check8,
            //                                 onChanged:(bool? value) {
            //                                   setState(() {
            //                                     check8 = value;
            //                                     appState.check8 = check8;
            //                                   });
            //                                 },
            //                                 ),
            //                             ),
            //                           ),   
            //                         ],
            //                       ),
            //                     ),

            //                   ],
            //                 ),
            //               ),   
            //             ],
            //           ),
            //         ),

            //         //  SHOPPING SAVINGS CHECKBOX
            //         Padding(
            //           padding: const EdgeInsets.only(
            //             left: 50,
            //             right: 20,
            //             top: 0,
            //             bottom: 5,
            //           ),
            //           child: Row(
            //             children: [
            //               Align(
            //                 alignment: Alignment.centerLeft,
            //                 child: Padding(
            //                   padding: const EdgeInsets.only(
            //                     right: 10,
            //                   ),
            //                   child: Text("Shopping", 
            //                   textAlign: TextAlign.left,),
            //                 )
            //                 ),

            //               Align(
            //                 alignment: Alignment.centerLeft,
            //                 child: Padding(
            //                   padding: const EdgeInsets.only(
            //                     left: 55,
            //                   ),
            //                   child: Row(
            //                     children: [
            //                       Checkbox(
            //                         value: appState.check9,
            //                         onChanged:(bool? value) {
            //                           setState(() {
            //                             check9 = value;
            //                             appState.check9 = check9;
            //                           });
            //                         },
            //                         ),

            //                     //  MORTGAGE DOWN PAYMENT SAVINGS CHECKBOX
            //                     Padding(
            //                       padding: const EdgeInsets.only(
            //                         left: 50,
            //                         right: 20,
            //                         top: 0,
            //                         bottom: 5,
            //                       ),
            //                       child: Row(
            //                         children: [
            //                           Align(
            //                             alignment: Alignment.centerLeft,
            //                             child: Padding(
            //                               padding: const EdgeInsets.only(
            //                                 right: 10,
            //                               ),
            //                               child: Text("Mortgage", 
            //                               textAlign: TextAlign.left,),
            //                             )
            //                             ),

            //                           Align(
            //                             alignment: Alignment.centerLeft,
            //                             child: Padding(
            //                               padding: const EdgeInsets.only(
            //                                 left: 54,
            //                               ),
            //                               child: Checkbox(
            //                                 value: appState.check10,
            //                                 onChanged:(bool? value) {
            //                                   setState(() {
            //                                     check10 = value;
            //                                     appState.check10 = check10;
            //                                   });
            //                                 },
            //                                 ),
            //                             ),
            //                           ),   
            //                         ],
            //                       ),
            //                     ),

            //                     ],
            //                   ),
            //                 ),
            //               ),   
            //             ],
            //           ),
            //         ),

            //         //  CAR SAVINGS CHECKBOX
            //         Padding(
            //           padding: const EdgeInsets.only(
            //             left: 50,
            //             right: 20,
            //             top: 0,
            //             bottom: 5,
            //           ),
            //           child: Row(
            //             children: [
            //               Align(
            //                 alignment: Alignment.centerLeft,
            //                 child: Padding(
            //                   padding: const EdgeInsets.only(
            //                     right: 10,
            //                   ),
            //                   child: Text("Car", 
            //                   textAlign: TextAlign.left,),
            //                 )
            //                 ),

            //               Align(
            //                 alignment: Alignment.centerLeft,
            //                 child: Padding(
            //                   padding: const EdgeInsets.only(
            //                     left: 97,
            //                   ),
            //                   child: Row(
            //                     children: [
            //                       Checkbox(
            //                         value: appState.check11,
            //                         onChanged:(bool? value) {
            //                           setState(() {
            //                             check11 = value;
            //                             appState.check11 = check11;
            //                           });
            //                         },
            //                         ),

            //                       //  OTHER SAVINGS CHECKBOX
            //                       Padding(
            //                         padding: const EdgeInsets.only(
            //                           left: 50,
            //                           right: 20,
            //                           top: 0,
            //                           bottom: 5,
            //                         ),
            //                         child: Row(
            //                           children: [
            //                             Align(
            //                               alignment: Alignment.centerLeft,
            //                               child: Padding(
            //                                 padding: const EdgeInsets.only(
            //                                   right: 10,
            //                                 ),
            //                                 child: Text("Other", 
            //                                 textAlign: TextAlign.left,),
            //                               )
            //                               ),

            //                             Align(
            //                               alignment: Alignment.centerLeft,
            //                               child: Padding(
            //                                 padding: const EdgeInsets.only(
            //                                   left: 80,
            //                                 ),
            //                                 child: Checkbox(
            //                                   value: appState.check12,
            //                                   onChanged:(bool? value) {
            //                                     setState(() {
            //                                       check12 = value;
            //                                       appState.check12 = check12;
            //                                     });
            //                                   },
            //                                   ),
            //                               ),
            //                             ),   
            //                           ],
            //                         ),
            //                       ),

            //                     ],
            //                   ),
            //                 ),
            //               ),   
            //             ],
            //           ),
            //         ),

            //         Padding(          // The text and padding between Text Field
            //           padding: const EdgeInsets.only(
            //             left: 50,
            //             right: 20,
            //             top: 15,
            //             bottom: 5,
            //           ),
            //           child: Align(
            //             alignment: Alignment.centerLeft,
            //             child: Row(
            //               children: [
            //                 Text("Savings Goal", 
            //                 textAlign: TextAlign.left,
            //                 ),
            //                 Text("   (can be changed later)",
            //                 style: TextStyle(
            //                   fontSize: 12,
            //                   fontStyle: FontStyle.italic,
            //                 ), 
            //                 textAlign: TextAlign.left,
            //                 ),
            //               ],
            //             )
            //             ),
            //         ),
                          
                          
            //         Padding(                          //GOAL TEXT FIELD
            //           padding: const EdgeInsets.only(
            //             left: 50,
            //             right: 400,
            //             top: 0,
            //             bottom: 0,
            //           ),
            //           child: Align(
            //             alignment: Alignment.centerLeft,
            //             child: SizedBox(
            //               width: 235,
            //               height: 50,
            //               child: TextField(
            //                 controller: savingsgoalController,
            //                 onChanged: (value) { // If any text is entered
            //                   savingsgoal = savingsgoalController.text;
            //                   if (savingsgoal != ""){
            //                     appState.savingsgoal = double.parse(savingsgoal);
            //                   }
            //                 },

            //                 decoration: InputDecoration(
            //                   border: OutlineInputBorder(),
            //                   floatingLabelBehavior: FloatingLabelBehavior.never, //Removes annoying floating label text on click
            //                   labelText: 'Default: 2x Balance',
            //                   labelStyle: TextStyle( //Changes Font
            //                     fontFamily: 'Nato Sans'
            //                   ),
            //                 ),
            //               ),
            //             ),
            //           ),
            //         ),


            //       ],
            //     ),
            //   )
            //   ),
          ],
        ),
      ),
    );
  }
}

class BudgetPage extends StatefulWidget{

  @override
  State<BudgetPage> createState() => _BudgetPageState();
}

class _BudgetPageState extends State<BudgetPage> {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    var theme = Theme.of(context);
    appState.notcurrentmonthchecker = true;

    
    void getMonthData(monthdata) {
    //var populate = MyApp.of(context).flaskConnect.fetchData('month/data');
    // SENDS TO BACKEND
      
      var data = monthdata;
      //gotttopop.then((data){
      var expenseList = data['expense'];
      print('ExpenseList: $expenseList');
      if (expenseList != []){
        for (var expense in expenseList) {
          var id = expense['id'];
          var name = expense['name'];   
          var cost = num.parse(expense['cost']); 
          var tier = expense['tier'];               
          var expenseType = expense['expense_type']; 
          var frequency = expense['frequency']; 
          var date = expense['date']; 

          appState.expenseList.add(("$name ${cost.toStringAsFixed(2)}")); //Interpolation
          appState.expenseCostList.add((name, cost)); // Separate list for calcualtions
          appState.expenseidList.add((id.toString())); //Adds id to list //Havent tested yet
          //appState.expensedatelist.add((date.toString())); //wouldnt need if its jus current month data
          
          //CALCULATION: To change
          //Create colunmn for balance and add value here. WYUEWI
          appState.balance -= cost; // subtract expense from balance
          appState.spent += cost; // add expense cost to spent
          
            //Different WANT/NEED Symbols
            if (expenseType == "Want") {
              appState.wantTotal += cost; //To change
              Padding(
                padding: const EdgeInsets.only(left: 5),
                child: appState.wantneedIcon = Icon(
                  Icons.store_mall_directory,
                  color: Colors.blueAccent,
                ),
              );
            
            } else {
              appState.needTotal += cost;
              Padding(
                padding: const EdgeInsets.only(left: 5),
                child: appState.wantneedIcon = Icon(
                  Icons.house,
                  color: Colors.green
                  ),
              );
            }
          appState.type = appState.wantneedIcon;
          appState.expenseTypeList.add(appState.type);

          //Different EXPENSE RANKINGS Symbols
          if (tier == "T1") {
            Padding(
              padding: const EdgeInsets.only(left: 5, top: 3),
              child: appState.rankIcon = Icon(
                Icons.looks_one,
                color: Color.fromARGB(255, 180, 166, 35),
              ),
            );                        
          } 
          else if (tier == "T2") {
              Padding(
              padding: const EdgeInsets.only(left: 5, top: 3),
              child: appState.rankIcon = Icon(
                Icons.looks_two,
                color: Colors.orange
                ),
            );
          } 
          else if (tier == "T3") {
                Padding(
                padding: const EdgeInsets.only(left: 5, top: 3),
                child: appState.rankIcon = Icon(
                Icons.looks_3,
                color: Colors.red
                ),
                );
          }
          appState.rankIcon = appState.rankIcon;
          appState.rankList.add(appState.rankIcon);

          if (frequency == "One-Time"){  //Different INCOME FREQUENCY Symbols
            Padding(
              padding: const EdgeInsets.only(left: 5, top: 3),
              child: appState.frequencyIcon = Icon(
                Icons.one_x_mobiledata_outlined,
                color: Colors.blueGrey,
              ),
            );
            }
          else{ 
            Padding(
              padding: const EdgeInsets.only(left: 5),
              child: appState.frequencyIcon = Icon(
                Icons.calendar_month,
                color: Colors.blueGrey
                ),
            );
          }
          appState.expenseFreqList.add(appState.frequencyIcon);




      }//end for 
    }//end if-empty 
      

      var incomeList = data['income'];
      print('IncomeList: $incomeList');
      if(incomeList != []){
        for (var income in incomeList) {
          var id = income['id'];
          var name = income['name'];   
          var monthlyEarning = num.parse(income['monthly_earning']); 
          var frequency = income['frequency']; 
          var date = income['date']; 

          appState.incomeList.add(("$name ${monthlyEarning.toStringAsFixed(2)}")); //Interpolation
          appState.incomeValueList.add((name, monthlyEarning)); // Separate list for calcualtions
          appState.incomeidList.add((id.toString()));

          //CALCULATION: To change
          appState.balance += monthlyEarning; // adds income to remaining balance
          appState.income += monthlyEarning; // add income value to income
          
          if (frequency == "One-Time"){  //Different INCOME FREQUENCY Symbols
            Padding(
              padding: const EdgeInsets.only(left: 5, top: 3),
              child: appState.incomeFrequencyIcon = Icon(
                Icons.one_x_mobiledata_outlined,
                color: Colors.blueGrey,
              ),
            );
            }
          else{ 
            Padding(
              padding: const EdgeInsets.only(left: 5),
              child: appState.incomeFrequencyIcon = Icon(
                Icons.calendar_month,
                color: Colors.blueGrey
                ),
            );
          }
          appState.incomeFreqList.add(appState.incomeFrequencyIcon);
          // CALCULATE WANT/NEED/SAVINGS PERCENTAGES [want/need amounts in relation to total income] To Change
          appState.wantPercentage = appState.wantTotal / appState.income;
          appState.needPercentage = appState.needTotal / appState.income;
          appState.savingsPercentage = 100 - (appState.wantPercentage*100 + appState.needPercentage*100);

          
         
        }
      }
      //});  //end first populate

      double bwants = 0.00;
      double bneeds = 0.00; 
      double bsavings = 0.00;
      double rwants = 0.00;
      double rneeds = 0.00;
      double rsavings = 0.00;
      double increasedecrease = 0.00; 
      var currDate = '';
      double monthBegBalance = 0.00;
        
      //var recPopulate = MyApp.of(context).flaskConnect.fetchData('splits');
      //recPopulate.then((data){
      var splitList = data['splits'];
      //print('Message: $splitList');
      if (splitList != []){  //add to the function months yzm
        for (var splits in splitList) {
        
          bwants = double.parse(splits['wants']); 
          bneeds = double.parse(splits['needs']); 
          bsavings = double.parse(splits['savings']); 
          rwants = double.parse(splits['rwants']); 
          rneeds = double.parse(splits['rneeds']); 
          rsavings = double.parse(splits['rsavings']);
          increasedecrease = double.parse(splits['increase_decrease']); 
          currDate = splits['date']; 
          monthBegBalance = double.parse(splits['beginning_balance']); //UNCOMMENT
          //appState.beginbalance = monthBegBalance; //OR
          appState.monthBeginAmt = monthBegBalance;

          print('monthBegBalance  ${appState.monthBeginAmt}');
          appState.recommendedWantsPercentage = rwants;
          appState.recommendedNeedsPercentage = rneeds;
          appState.recommendedSavingsPercentage = rsavings;

          // appState.wantPercentage = bwants;
          // appState.needPercentage = bneeds;
          // appState.savingsPercentage = bsavings; //change

          appState.increaseDecreasePercent = increasedecrease;
          //if(appState.increaseDecreasePercent==0.00){appState.increaseDecreasePercent=10.00;}
          print(appState.increaseDecreasePercent);
        }} }//End for and if }
      //});

    
    List<Color> piechartcolours = [Colors.lightGreen.withOpacity(0.6), Colors.blueAccent.withOpacity(0.6), Colors.deepPurple.withOpacity(0.6)]; //Create list of colours for pie chart
    //String piechartText = "Income \n ${appState.income + appState.beginbalance}"; // Income = Monthly Income + Initial Balance. Shows in chart center
    String piechartText = "Total Income \n ${appState.income} \n\n Overspent \n ${double.parse(((appState.wantTotal + appState.needTotal) +((appState.savingsPercentage/100)*appState.income)).toStringAsFixed(2))-appState.income}"; // Income = Income, Gross Balance = Income + Beginning Balance

    // Current Wants/Needs/Savings Percentages
    var wantsPercentage = (appState.wantPercentage*100).toStringAsFixed(2); //toStringAsFixed is pretty much round()
    var needsPercentage = (appState.needPercentage*100).toStringAsFixed(2);
    var savingsPercentage = (appState.savingsPercentage).toStringAsFixed(2);
    // print('hello');
    // print((appState.savingsPercentage/100)*appState.income);
    // print(appState.income);
    // print(appState.needTotal);
    // print(appState.wantTotal);

    // print(double.parse(((appState.wantTotal + appState.needTotal) +((appState.savingsPercentage/100)*appState.income)).toStringAsFixed(2))-appState.income);
    //${double.parse((((appState.savingsPercentage/100)*appState.income)).toStringAsFixed(2))};
    

    // Goal Stuff [rework in future]
    double goalAmount = appState.savingsgoal;

    // Recommended Percentages [not done]
    // double recommendedWantsPercentage = 0.00;
    // double recommendedNeedsPercentage = 0.00;
    // double recommendedSavingsPercentage = 0.00;

    //place this @ function maybe? cuz it runs in the for loop not outside it
    //is the solution adding it to a list in appstate and searching for it here?
    
   
    var zippedLists = IterableZip([appState.expenseList, appState.expenseTypeList, appState.rankList, appState.expenseFreqList]);

    // Get Month:
    DateTime currentDate = DateTime.now(); //Get Current Date
    var monthNumber = "${appState.repMonth}"; //Get Current Month (as integer)
    var currentMonth;
    var nextMonth;
  
    double currentMonthNumber = 0.0;
    double nextMonthNumber = 0.0;
    double prevMonthNumber = 0.0;
    double recommendationMonthNumber = 0.0;

    print(monthNumber);
    
    //print(appState.balance);
    //print(appState.increaseDecreasePercent);

    if (int.parse(monthNumber) == 1){
      currentMonth = "January";
      nextMonth = "February";
      currentMonthNumber = 1;
      nextMonthNumber = 2;
      recommendationMonthNumber = 3;
      prevMonthNumber = 12;
    }
    else if(int.parse(monthNumber) == 2){
      currentMonth = "February";
      nextMonth = "March";
      currentMonthNumber = 2;
      nextMonthNumber = 3;
      recommendationMonthNumber = 4;
      prevMonthNumber = 1;
    }
    else if(int.parse(monthNumber) == 3){
      currentMonth = "March";
      nextMonth = "April";
      currentMonthNumber = 3;
      nextMonthNumber = 4;
      recommendationMonthNumber = 5;
      prevMonthNumber = 2;
    }
    else if(int.parse(monthNumber) == 4){
      currentMonth = "April";
      nextMonth = "May";
      currentMonthNumber = 4;
      nextMonthNumber = 5;
      recommendationMonthNumber = 6;
      prevMonthNumber = 3;
    }
    else if(int.parse(monthNumber) == 5){
      currentMonth = "May";
      nextMonth = "June";
      currentMonthNumber = 5;
      nextMonthNumber = 6;
      recommendationMonthNumber = 7;
      prevMonthNumber = 4;
    }
    else if(int.parse(monthNumber) == 6){
      currentMonth = "June";
      nextMonth = "July";
      currentMonthNumber = 6;
      nextMonthNumber = 7;
      recommendationMonthNumber = 8;
      prevMonthNumber = 5;
    }
    else if(int.parse(monthNumber) == 7){
      currentMonth = "July";
      nextMonth = "August";
      currentMonthNumber = 7;
      nextMonthNumber = 8;
      recommendationMonthNumber = 9;
      prevMonthNumber = 6;
    }
    else if(int.parse(monthNumber) == 8){
      currentMonth = "August";
      nextMonth = "September";
      currentMonthNumber = 8;
      nextMonthNumber = 9;
      recommendationMonthNumber = 10;
      prevMonthNumber = 7;
    }
    else if(int.parse(monthNumber) == 9){
      currentMonth = "September";
      nextMonth = "October";
      currentMonthNumber = 9;
      nextMonthNumber = 10;
      recommendationMonthNumber = 11;
      prevMonthNumber = 8;
    }
    else if(int.parse(monthNumber) == 10){
      currentMonth = "October";
      nextMonth = "November";
      currentMonthNumber = 10;
      nextMonthNumber = 11;
      recommendationMonthNumber = 12;
      prevMonthNumber = 9;
    }
    else if(int.parse(monthNumber) == 11){
      currentMonth = "November";
      nextMonth = "December";
      currentMonthNumber = 11;
      nextMonthNumber = 12;
      recommendationMonthNumber = 1;
      prevMonthNumber = 10;
    }
    else if(int.parse(monthNumber) == 12){
      currentMonth = "December";
      nextMonth = "January";
      currentMonthNumber = 12;
      nextMonthNumber = 1;
      recommendationMonthNumber = 2;
      prevMonthNumber = 11;
    }
    // Icon values used to pick which Expenses to add to Removal list in Help Icon
    Icon lowRankExpense1 = Icon(
      Icons.looks_one,
      color: Color.fromARGB(255, 180, 166, 35),
    );
    Icon lowRankExpense2 = Icon(
      Icons.looks_two,
      color: Colors.orange
      );
    Icon wantExpense = Icon(
      Icons.store_mall_directory,
      color: Colors.blueAccent,
    );
    Icon needExpense = Icon(
      Icons.house,
      color: Colors.green
      );
    //Create Data points for pie chart
    Map<String, double> dataMap = {
      "Needs": appState.needTotal,
      "Wants": appState.wantTotal,
      "Savings": appState.income - (appState.needTotal + appState.wantTotal),
    };
    return Scaffold(
      body: SingleChildScrollView(
        child: Stack(
          children: [
            Column(
          children: [
            Padding( // REPORT HEADING
              padding: const EdgeInsets.only(
                left: 50,
                right: 0,
                top: 10,
                bottom: 0,
              ),
              child: Align(
                alignment: Alignment.topLeft,
                child: Text("Report",
                  style: TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    fontFamily: "Nato Sans"
                  ),
                ),
              ),
            ),
      
            //Divider(),
      
            Row(
              children: [
                Expanded(child: Text(""),), // just to align stuff

                // PREVIOUS MONTH BUTTON
                IconButton(
                  onPressed: ()async {
                    appState.shownextmonth=true;
                  //onPressed: (){
                    appState.clearAllLists();
                   
                    appState.repMonth --;
                    if (appState.repMonth == 0){
                      appState.repMonth = 12;
                    }
                    monthNumber = '${appState.repMonth}';
                    final sendtopop= {'month': '${appState.repMonth}', 'year': '2023'};                                
                    final monthdata= await  MyApp.of(context).flaskConnect.sendData('month/data', sendtopop);
                    setState(() {
                  getMonthData(monthdata);
                    });
                  }, // Code to go to previous month goes here

                  icon: Icon(Icons.arrow_circle_left_outlined),
                  selectedIcon: Icon(Icons.arrow_circle_left),
                  ),

            Padding( // DATE HEADING
              padding: const EdgeInsets.only(
                left: 0,
                right: 0,
                top: 0,
                bottom: 5,
              ),
              child: Align(
                alignment: Alignment.center,
                //Sets date to current month - next month
                child: Text("${currentMonth.toString()} → ${nextMonth.toString()}",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    fontFamily: "Nato Sans"
                  ),
                ),
              ),
            ),

            // NEXT MONTH BUTTON
            
           appState.shownextmonth? Padding(
      
              padding: const EdgeInsets.only(right:70),
              child: IconButton(
                onPressed: ()async {
                  appState.clearAllLists();

             
                  appState.repMonth++; ///issue may arise
                   if (appState.repMonth == 13){
                      appState.repMonth = 1;
                    }
                  if (appState.repMonth==appState.currMonth)
                  {
                    appState.shownextmonth=false;
                  }  
                  monthNumber = '${appState.repMonth}';
                  final sendtopop= {'month': '${appState.repMonth}', 'year': '2023'};                                
                  final monthdata= await  MyApp.of(context).flaskConnect.sendData('month/data', sendtopop);
                  setState(() {
                    getMonthData(monthdata);
                    });
                }, // Code to go to next month goes here

                icon: Icon(Icons.arrow_circle_right_outlined),
                selectedIcon: Icon(Icons.arrow_circle_right),
                ),
            ): Padding(
              padding: const EdgeInsets.only(right:70),
              child: const SizedBox.shrink(),
            ),
              Expanded(child: Text("")), // just to align stuff
            ],
          ),
        
            Padding( // REMAINING HEADING
              padding: const EdgeInsets.only(
                left: 0,
                right: 70,
                top: 0,
                bottom: 0,
              ),
              child: Row(
                children: [
                  Expanded( //Center below text
                    child: Text(''),
                  ),
                  // The Remaining Number
                  Text(appState.balance.toStringAsFixed(2),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      fontFamily: "Nato Sans"
                    ),
                  ),
                  // The Text After
                  Text(" leftover",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      fontFamily: "Nato Sans"
                    ),
                  ),
                  Expanded( //Center above text
                    child: Text(''),
                  ),
                ],
              ),
            ),
      
            Divider(), //Horizontal Line
      
            // EVERYTHING BELOW THE LINE

            // GOALS
            if(appState.balance >= appState.savingsgoal) // If Goal is reached:
              Align(alignment: Alignment.center, 
              child: Padding(
                padding: const EdgeInsets.only(right: 70),
                child: Container(
                  width: 150,
                  height: 30,
                  decoration: BoxDecoration(
                    border: Border.all(width: 1, color: Colors.black.withOpacity(0)),
                    borderRadius: BorderRadius.all(Radius.circular(5)),
                    color: Colors.lightGreen.withOpacity(0.5),
                  ),
                  child: Align(
                    alignment: Alignment.center,
                    child: Text("Goal: $goalAmount",
                    style: TextStyle(
                      color: Color.fromARGB(255, 18, 139, 22),
                    ),
                    ),
                  ),
                ),
              )
              ),

            if(appState.balance < appState.savingsgoal) // If Goal is not reached:
              Align(alignment: Alignment.center, 
              child: Padding(
                padding: const EdgeInsets.only(right: 70),
                child: Container(
                  width: 150,
                  height: 30,
                  decoration: BoxDecoration(
                    border: Border.all(width: 1, color: Colors.black.withOpacity(0)),
                    borderRadius: BorderRadius.all(Radius.circular(5)),
                    color: Colors.redAccent.withOpacity(0.5),
                  ),
                  child: Align(
                    alignment: Alignment.center,
                    child: Text("Goal: $goalAmount",
                    style: TextStyle(
                      color: Color.fromARGB(255, 121, 19, 11),
                    ),
                    ),
                  ),
                ),
              )
              ),
  
            Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(
                    left: 100,
                    right: 0,
                    top: 30,
                    bottom: 15,
                  ),
                  child: pc.PieChart(  // PIE CHART
                    dataMap: dataMap,
                    initialAngleInDegree: 180, //Change this to rotate the chart
                    chartType: pc.ChartType.ring, // Set the pie chart type to be a ring, use 'disc' otherwise
                    chartRadius: MediaQuery.of(context).size.width/6, // Size of Pie Chart
                    centerText: piechartText, //Sets the text in the center of chart
                    chartLegendSpacing: 32, //Distance of legend from Pie Chart
                    animationDuration: Duration(milliseconds: 1200), //Length of Pie Chart animation
                    colorList: piechartcolours, //Set pie chart colours, variable initialized earlier
                    legendOptions: pc.LegendOptions(
                      legendShape: BoxShape.circle, //Makes the legends boxes circles
                      legendTextStyle: TextStyle(
                        fontFamily: 'Nato Sans',
                        fontWeight: FontWeight.bold,
                      )
                    ),
                    chartValuesOptions: pc.ChartValuesOptions( //Configure values in chart
                      showChartValues: true,
                      showChartValuesOutside: true,
                      showChartValuesInPercentage: true,
                      showChartValueBackground: true,
                      chartValueBackgroundColor: Colors.grey.withOpacity(0),
                      chartValueStyle: TextStyle(
                        color: Colors.black,
                        fontFamily: 'Roboto',
                        //fontWeight: FontWeight.bold,
                        fontSize: 15,
                      )
                    ),
                    ),
                ),

                // RECOMMENDATIONS AREA
                Padding(
                  padding: const EdgeInsets.only(left:146),
                  child: Container(
                    height: 200,
                    width: 500,
                    // color: Colors.amber,
                    child: Column(
                      children: [
                        Align(
                          alignment: Alignment.topCenter,
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: Text("Recommendations",
                              style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              fontFamily: "Nato Sans"
                                            ),
                            ),
                          )

                          ),
                        Row( // Row with Current and Optimal Headings
                          children: [
                            Expanded(flex: 2,child: Text(""),),
                            Expanded(flex: 6,child: Padding(
                              padding: const EdgeInsets.only(left: 15),
                              child: Text("Current"),
                            )),
                            Expanded(flex: 4,child: Padding(
                              padding: const EdgeInsets.only(left: 15),
                              child: Text("Optimal"),
                            )),
                          ],
                        ),
                        // Divider Line for Columns
                        Divider(
                          color: Colors.grey,
                          height: 5,
                          indent: 65,
                          endIndent: 65,
                          ),

                        Row( // Row with Current Wants % and Optimal Wants %
                          children: [
                            Expanded(flex: 2,child: Text(""),),
                            
                            Expanded(flex: 6,child: Text("Wants %: $wantsPercentage",
                              style: TextStyle(
                                fontFamily: "Roboto"
                              ),
                            )),
                            Expanded(flex: 4,child: Text("Wants %: ${appState.recommendedWantsPercentage}",
                                style: TextStyle(
                                fontFamily: "Roboto"
                                )
                            )),
                          ],
                        ),
                        Row( // Row with Current Needs % and Optimal Needs % Headings
                          children: [
                            Expanded(flex: 2,child: Text(""),),
                            Expanded(flex: 6,child: Text("Needs %: $needsPercentage",
                                style: TextStyle(
                                fontFamily: "Roboto"
                                )
                            )),
                            Expanded(flex: 4,child: Text("Needs %: ${appState.recommendedNeedsPercentage}",
                                style: TextStyle(
                                fontFamily: "Roboto"
                                )
                            )),
                          ],
                        ),
                        Row( // Row with Current Savings % and Optimal Savings % Headings
                          children: [
                            Expanded(flex: 2,child: Text(""),),
                            Expanded(flex: 6,child: Text("Savings %: $savingsPercentage",
                                style: TextStyle(
                                fontFamily: "Roboto"
                                )
                            )),
                            Expanded(flex: 4,child: Text("Savings %: ${appState.recommendedSavingsPercentage}",
                                style: TextStyle(
                                fontFamily: "Roboto"
                                )
                            )),
                          ],
                        ),

                      ],
                    )
                      ),
                )

              ],
            ),
            SizedBox(height: 20,), // Bit of space between chart and line graphs

            // CURRENT TRAJECTORY & OPTIMAL TRAJECTORY LINE GRAPH HEADINGS
            Row(
              children: [
                //CURRENT TRAJECTORY
                Align(
                  alignment: Alignment.centerRight,
                  child: Padding(
                      padding: const EdgeInsets.only(left: 320,bottom: 20),
                      child: Text("Current Trajectory       VS",
                      style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      fontFamily: "Nato Sans"
                                    ),
                    ),
                  )
                  ),
                //OPTIMAL TRAJECTORY HEADING
                Expanded(
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 42,bottom: 20),
                      child: Text("Optimal Trajectory",
                        style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        fontFamily: "Nato Sans"
                                      ),
                      ),
                    )
                
                    ),
                ),
              ],
            ),
            // ROW WITH LINE GRAPHS
            Row(
              children: [
                // CURRENT TRAJECTORY LINE GRAPH
                Container(
                  width: 1000,
                  height: 300,
                  child: LineChart(
                    LineChartData(
                      /////gridData: FlGridData(drawHorizontalLine: true, drawVerticalLine: true, horizontalInterval:  max(double.parse((appState.balance*(appState.recommendedSavingsPercentage/100)/5).toStringAsFixed(2)),appState.balance/5)), // Grid Settings
                      //gridData: FlGridData(drawHorizontalLine: true, drawVerticalLine: true, horizontalInterval: (appState.balance+1000)/5), // Grid Settings
                      lineTouchData: LineTouchData( // Background color for when you hover a data point
                        touchTooltipData: LineTouchTooltipData(
                          tooltipBgColor: Color.fromARGB(255, 255, 255, 255)
                        )
                      ),
                      titlesData: FlTitlesData(
                        show: true,
                        topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        //leftTitles: AxisTitles(sideTitles: SideTitles(reservedSize: 60, showTitles: true, interval: max(double.parse((appState.balance*(appState.increaseDecreasePercent/100)/5).toStringAsFixed(2)),appState.balance/5))), // CHANGE THIS WITH ACTUAL PROJECTED VARIABLE

                        rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        bottomTitles: AxisTitles(axisNameSize: 16, axisNameWidget: Text("Months"), sideTitles: SideTitles(reservedSize: 24, showTitles: true, interval: 1)) // Interval - Range between each data point E.g. 6-7-8-9 if interval = 1

                        ),
                      borderData: FlBorderData(show: false), // Border line
                      minX: prevMonthNumber,
                      maxX: 12,
                      // maximum Y value should be 20% greater than projected variable
                      //maxY: max(double.parse(((appState.balance*(appState.increaseDecreasePercent/100))+(appState.balance*(appState.increaseDecreasePercent/100))*0.20).toStringAsFixed(2)),appState.balance*1.2), //REPLACE WITH PROJECTED VARIABLES WHEN YOU CAN
                      
                    // CURRENT TRAJECTORY LINE
                      lineBarsData: [
                        LineChartBarData(
                          color: Colors.redAccent,
                            isCurved: true,
                            curveSmoothness: 0.5,
                          spots:[ // it's (x, y)xx
                            FlSpot(prevMonthNumber,0), // Start
                            //FlSpot(currentMonthNumber, appState.beginbalance), // Current Month's Balance 
                            FlSpot(currentMonthNumber, appState.monthBeginAmt+appState.beginbalance), // Current Month's Balance 
                            FlSpot(nextMonthNumber, appState.balance), // New Month's Balance
                            FlSpot(recommendationMonthNumber, double.parse((appState.balance+(appState.balance*(appState.increaseDecreasePercent/100))).toStringAsFixed(2))), 
                            //It should look smthn like this once we have an 'increase' variable:
                            // FlSpot(recommendationMonthNumber, appState.balance*appState.increasePercentage),
                          ]
                        ),

                        //OPTIMAL TRAJECTORY LINE
                          LineChartBarData(
                            color: Colors.deepPurple,
                              isCurved: true,
                              curveSmoothness: 0.3,
                            spots:[ // it's (x, y)
                              FlSpot(prevMonthNumber,0), // Start
                              //FlSpot(currentMonthNumber, appState.beginbalance), // Current Month's Balance monthBeginAmt
                              FlSpot(currentMonthNumber, appState.monthBeginAmt+appState.beginbalance), // Current Month's Balance monthBeginAmt
                              FlSpot(nextMonthNumber, appState.balance), // New Month's Balance
                              FlSpot(recommendationMonthNumber, double.parse((appState.balance+(appState.balance*(appState.recommendedSavingsPercentage/100))).toStringAsFixed(2))), // REPLACE WITH AVERAGE OF THEIR INCREASE TO GET PROJECTED BALANCE 
                              //It should look like this once recommendation works:
                              // FlSpot(recommendationMonthNumber, appState.balance*appState.recommendedSavingsPercentage),
                            ]
                          )
                      ]
                  )),
                ),


                // // OPTIMAL TRAJECTORY LINE GRAPH
                // Padding(
                //   padding: const EdgeInsets.only(left: 80),
                //   child: Container(
                //     width: 500,
                //     height: 200,
                //     child: LineChart(
                //       LineChartData(
                //         //gridData: FlGridData(drawHorizontalLine: true, drawVerticalLine: true, horizontalInterval:  max(double.parse((appState.balance*(appState.recommendedSavingsPercentage/100)/5).toStringAsFixed(2)),appState.balance/5)), // Grid Settings
                //         lineTouchData: LineTouchData( // Background color for when you hover a data point
                //           touchTooltipData: LineTouchTooltipData(
                //             tooltipBgColor: Colors.white10
                //           )
                //         ),
                //         titlesData: FlTitlesData(
                //           show: true,
                //           topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                //           //leftTitles: AxisTitles(sideTitles: SideTitles(reservedSize: 60, showTitles: true, interval: max(double.parse((appState.balance*(appState.recommendedSavingsPercentage/100)/5).toStringAsFixed(2)),appState.balance/5))), // CHANGE THIS WITH ACTUAL PROJECTED VARIABLE
                //           rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                //           bottomTitles: AxisTitles(axisNameSize: 16, axisNameWidget: Text("Months"), sideTitles: SideTitles(reservedSize: 24, showTitles: true, interval: 1)) // Interval - Range between each data point E.g. 6-7-8-9 if interval = 1
                
                //           ),
                //         borderData: FlBorderData(show: false), // Border line
                //         minX: prevMonthNumber,
                //         maxX: 12,
                //         // maximum Y value should be 20% greater than projected variable
                //         //maxY: max(double.parse(((appState.balance*(appState.recommendedSavingsPercentage/100))+(appState.balance*(appState.recommendedSavingsPercentage/100))*0.20).toStringAsFixed(2)),appState.balance*1.2), //REPLACE WITH PROJECTED VARIABLES WHEN YOU CAN
                //         lineBarsData: [
                //           LineChartBarData(
                //             color: Colors.deepPurple,
                //             spots:[ // it's (x, y)
                //               FlSpot(prevMonthNumber,0), // Start
                //               //FlSpot(currentMonthNumber, appState.beginbalance), // Current Month's Balance monthBeginAmt
                //               FlSpot(currentMonthNumber, appState.monthBeginAmt), // Current Month's Balance monthBeginAmt
                //               FlSpot(nextMonthNumber, appState.balance), // New Month's Balance
                //               FlSpot(recommendationMonthNumber, double.parse((appState.balance+(appState.balance*(appState.recommendedSavingsPercentage/100))).toStringAsFixed(2))), // REPLACE WITH AVERAGE OF THEIR INCREASE TO GET PROJECTED BALANCE 
                //               //It should look like this once recommendation works:
                //               // FlSpot(recommendationMonthNumber, appState.balance*appState.recommendedSavingsPercentage),
                //             ]
                //           )
                //         ]
                //     )),
                //   ),
                // )
              ],
            ),
      
            // EXPENSES FOR MONTH
            Row(
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.only(
                    top: 10,
                    ),
                    child: Align( //align container
                      alignment: Alignment.centerLeft,
                      child: Container(
                        width: 500,
                        decoration: BoxDecoration(
                          //border: Border.all(width: 1, color: Colors.black.withOpacity(0.5)),
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                          color: Colors.grey.withOpacity(0.2),
                        ),
      
                        child: Align( //align everything inside box
                          alignment: Alignment.centerLeft,
                          child: SizedBox(
                            width: 920,
                            child: Column(
                              children: [
      
                                Row(
                                  children: [
                                    Expanded(child: Padding( //Income for Current Month
                                      padding: const EdgeInsets.only(left: 10, top: 10),
                                      child: Text('Expenses for $currentMonth                   Cost'),
                                    )),
                                    Expanded(child: Padding( //Cost Text
                                      padding: const EdgeInsets.only(left: 105, top: 10),
                                      child: Text('W/N    Rank     Freq'),
                                    )),
                                  ],
                                ),
      
                                Divider(color: Colors.grey,),
      
                                if (appState.expenseList != []) //Displays Expenses if list isn't emtpy
                                  for (var tuple in zippedLists)//Get all expenses
                                    // 1st = Expense, 2nd = Want/Need, 3rd = Rank, 4th = Frequency
                                    Row(
                                      children: [
                                        //  Money Icon and Expense Text Part
                                          Expanded(
                                            // flex: 2,
                                            child: Padding(
                                              padding: const EdgeInsets.only(left: 15),
                                              child: Text(appState.getExpenseName(tuple.first), //Specifically gets the Name
                                                style: TextStyle(
                                                  color: Colors.black,
                                                ),
                                              ),
                                            ),
                                          ),
                                        Padding(
                                          padding: const EdgeInsets.only(
                                            left: 50,
                                          ),
                                          child: Icon(Icons.attach_money_rounded, 
                                          color: Colors.black,
                                          ),
                                        ),
                                        Expanded( //Specifically gets the Cost
                                          // flex: 2,
                                          child: Align(
                                            alignment: Alignment.centerLeft,
                                            child: Text(appState.getExpenseCost(tuple.first).toString(), //Specifically gets the Name
                                              style: TextStyle(
                                                color: Colors.black,
                                              ),
                                            ),
                                          ),
                                        ),
      
                                        //  Icons
                                        Expanded( // Aligns it nicely to the right
                                          child: Align(
                                            alignment: Alignment.centerRight,
                                            child: Row(
                                              children: [
                                                // SizedBox(width: 10,),
                                                tuple.elementAt(1), // Want/Need Icon
                                                SizedBox(width: 25,),
                                                tuple.elementAt(2), // Rank Icon
                                                SizedBox(width: 28,),
                                                tuple.elementAt(3), // Frequency Icon
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                              ],
                            )
                            ),
                        ),
                      ),
                    ),
                  ),
      
                ),
                // INCOME CHANNELS FOR MONTH
                Padding(
                  padding: const EdgeInsets.only(
                    left: 100,
                    right: 0,
                    top: 0,
                    bottom: 0,
                  ),
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: Padding(
                      padding: const EdgeInsets.only(
                      top: 10,
                      ),
                      child: Align( //align container
                        alignment: Alignment.topCenter,
                        child: Container(
                          width: 500,
                          decoration: BoxDecoration(
                            //border: Border.all(width: 1, color: Colors.black.withOpacity(0.5)),
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                            color: Colors.grey.withOpacity(0.2),
                          ),
      
                          child: Align( //align everything inside box
                            alignment: Alignment.topCenter,
                            child: SizedBox(
                              width: 920,
                              child: Column(
                                children: [
      
                                  Row(
                                    children: [
                                      Expanded(child: Padding( //Income for Current Month
                                        padding: const EdgeInsets.only(left: 10, top: 10),
                                        child: Text('Income for $currentMonth'),
                                      )),
                                      Expanded(child: Padding( //Received Text
                                        padding: const EdgeInsets.only(left: 130, top: 10, right: 10),
                                        child: Text('Received'),
                                      )),
                                    ],
                                  ),
      
                                  Divider(color: Colors.grey,),
                                  if (appState.incomeList != []) //Displays Income if list isn't emtpy
                                    for (var income in appState.incomeList) //Get all income channels
                                      Row(
                                        children: [
                                          // Income Text
                                          Expanded(
                                            child: Padding(
                                              padding: const EdgeInsets.only(left: 15),
                                              child: Text(income.replaceAll(RegExp(r'[^A-Z,a-z]'),''),
                                                style: TextStyle(
                                                  //color: Colors.deepOrangeAccent,
                                                ),
                                              ),
                                            ),
                                          ),
                                          //  Money Icon
                                          Expanded(
                                            child: Padding(
                                            padding: const EdgeInsets.only(
                                              left: 200,
                                            ),
                                            child: Icon(Icons.attach_money_rounded, 
                                            //color: Colors.deepOrangeAccent,
                                            ),
                                          ),
                                          ),
      
                                          //  INCOME EARNINGS
                                          Expanded( // Aligns it nicely to the right
                                            child: Align(
                                              alignment: Alignment.centerLeft,
                                              child: Padding(
                                                  padding: const EdgeInsets.only(left: 56,right: 0),
                                                  child: Text(
                                                    income.replaceAll(RegExp(r'[^0-9,.]'),'') // INCOME Button To Delete
                                                    
                                                  ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
      
                        //  INCOME BOX IF EMPTY
                        if (appState.incomeList.isEmpty) //Displays message if list IS empty
                          Padding(
                            padding: const EdgeInsets.only(
                              top: 10,
                            ),
                            child: Align(
                              alignment: Alignment.centerLeft, //aligns container
                              child: Container(
                                width: 920,
                                decoration: BoxDecoration(
                                  border: Border.all(width: 1, color: Colors.black.withOpacity(0.5)),
                                  borderRadius: BorderRadius.all(Radius.circular(5))
                                ),
                                child: Align( //aligns everything inside box
                                  alignment: Alignment.centerLeft,
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                      left: 0,
                                      right: 0,
                                      top: 5,
                                      bottom: 5,
                                    ),
                                    child: Row( //Row with No Income Icon and Text
                                      children: [
                                        Icon(
                                          //color: Colors.red,
                                          Icons.error,
                                        ),
                                        Text(" There are no Income Channels",
                                          style: TextStyle(
                                            //backgroundColor: Color.fromARGB(255, 214, 209, 209), 
                                          ),
                                        ),
                                      ]
                                    ),
                                  ),
                                  ),
                              ),
                            ),
                          ),  
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 50,) // Extra space at the bottom to make scrolling better
          ],
        ),
          //                                    ALL THE HOVER STUFF IS HERE
            
            Positioned(
              top: 273,
              right: 305,
              child: Column(
                children: [ // REPLACE WITH CURRENT PERCENTAGES - JON'S RECOMMENDED VALUES
                  Text((appState.recommendedWantsPercentage-double.parse(wantsPercentage)).toStringAsFixed(2),style: TextStyle(color:Colors.grey)),
                  Text((appState.recommendedNeedsPercentage-double.parse(needsPercentage )).toStringAsFixed(2),style: TextStyle(color:Colors.grey)),
                  Text((appState.recommendedSavingsPercentage-double.parse(savingsPercentage)).toStringAsFixed(2),style: TextStyle(color:Colors.grey)),
                ],
              ),
              ),
            // CURRENT TRAJECTORY INFO ICON
            Positioned( // Position it where I want it on the screen
              top: 472,
              // left: 350,
              right: 652,
              // bottom: 650, // Position it where I want it on screen
              // right: 120,
              child: MouseRegion( // Selects area and waits for mouse hovers and exits
                
                onEnter: (_) => setState(() { // If the user hovers over the icon, Do this:
                  appState.showCurrentTrajectoryInfo = true;
                  appState.currentTrajectoryIcon = false;
                }),
                onExit: (_) => setState(() { // If the user's mouse leaves the icon, Do this:
                  appState.showCurrentTrajectoryInfo = false;
                  appState.currentTrajectoryIcon = true;
                }),

                child: Column( // Think of stacks of paper, widgets below others take space of widgets above
                  children: [
                    // Appears below next widget in stack
                    appState.currentTrajectoryIcon ? Icon(Icons.timeline, // Current Trajectory icon if not hovered (Appears)
                    size: 22,
                    color: Colors.redAccent,
                    ): const SizedBox.shrink(), // Current Trajectory icon if hovered (Gone)

                    Center(
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 650),
                        child: appState.showCurrentTrajectoryInfo ? Container(
                          color: Colors.white,
                          width: 350,
                          // height: 500,
                          child: Column(
                            children: [
                          
                              // Text under HELP
                              Text(" Predicted balance for next month at current rate.",
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ) : const SizedBox.shrink(),
                      ),
                    )
                  ],
                ),
              ),
            ),

            // OPTIMAL TRAJECTORY INFO ICON
            Positioned( // Position it where I want it on the screen
              top: 472,
              // right: 222,
              left: 574,
              child: MouseRegion( // Selects area and waits for mouse hovers and exits
                
                onEnter: (_) => setState(() { // If the user hovers over the icon, Do this:
                  appState.showOptimalTrajectoryInfo = true;
                  appState.optimalTrajectoryIcon = false;
                }),
                onExit: (_) => setState(() { // If the user's mouse leaves the icon, Do this:
                  appState.showOptimalTrajectoryInfo = false;
                  appState.optimalTrajectoryIcon = true;
                }),
                
                child: Column( // Think of stacks of paper, widgets below others take space of widgets above
                  children: [
                    // Appears below next widget in stack
                    appState.optimalTrajectoryIcon ? Icon(Icons.timeline, // Optimal Trajectory icon if not hovered (Appears)
                    size: 22,
                    color: Colors.deepPurple,
                    ): const SizedBox.shrink(), // Optimal Trajectory icon if hovered (Gone)

                    Center(
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 650),
                        child: appState.showOptimalTrajectoryInfo ? Container(
                          color: Colors.white,
                          width: 350,
                          child: Column(
                            children: [
                          
                              // Text under HELP
                              Text(" Predicted balance for next month at recommended rate.",
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ) : const SizedBox.shrink(),
                      ),
                    )
                  ],
                ),
              ),
            ),

            // HELP BUTTON
            Positioned( // Position it where I want it on the screen
              top: 350,
              right: 320,
              child: MouseRegion( // Selects area and waits for mouse hovers and exits
                onEnter: (_) => setState(() { // If the user hovers over the help icon, Do this:
                  appState.showHelpList = true;
                  appState.showIcon = false;
                }),
                onExit: (_) => setState(() { // If the user's mouse leaves the help icon, Do this:
                  appState.showHelpList = false;
                  appState.showIcon = true;
                }),
                child: Column( // Think of stacks of paper, widgets below others take space of widgets above
                  children: [

                    // Appears below next widget in stack
                    appState.showIcon ? Icon(Icons.help, // Help icon if not hovered (Appears)
                    size: 22,
                    color: Colors.black,
                    ): const SizedBox.shrink(), //Help icon if hovered (Gone)

                    Center(
                      child: AnimatedSwitcher( // Fade animation
                        duration: const Duration(milliseconds: 650),
                        child: appState.showHelpList ? Container(
                          color: Colors.white,
                          width: 450,
                          child: Container(
                            decoration: BoxDecoration( // Border
                              border: Border.all(width: 1, color: Colors.black.withOpacity(0.5)),
                              borderRadius: BorderRadius.all(Radius.circular(5))
                            ),
                            child: Column(
                              children: [
                                // HELP HEADING
                                Padding(
                                  padding: const EdgeInsets.only(top:5),
                                  child: Text("HELP",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'Nato Sans',
                                  ),
                                  ),
                                ),

                                Divider(color: Colors.black,), // Horizontal Line

                                // Text under HELP
                                
                                Padding(
                                  padding: const EdgeInsets.all(2.0),                                 
                                  child: appState.savingsPercentage >= 50 ? Text("Looks Like Your On The Right Track! \n You Saved  \$${double.parse((((appState.savingsPercentage/100)*appState.income)).toStringAsFixed(2))}0 This Month",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w200,
                                      fontStyle: FontStyle.italic,
                                      color: Colors.green,
                                    ),
                                  ): Text("Reduce spending on the following expenses for optimal growth."),
                                ),

                                Divider(color: Colors.grey, height: 5, indent: 10, endIndent: 11),

                                //Help Button Columns
                                Row(
                                  children: [
                                    Expanded(child: Padding( //Income for Current Month
                                      padding: const EdgeInsets.only(left: 10, top: 10),
                                      child: Text('Name of Expense            % of Total Expenses             W/N'),
                                    )),
                                  ],
                                ),
                              
                                Divider(color: Colors.grey, height: 5, indent: 10, endIndent: 11),
                              
                                if (appState.expenseList != []) //Displays Expenses if list isn't emtpy //Put Something here
                                  for (var tuple in zippedLists)//Get all expenses
                                    // 1st = Expense, 2nd = Want/Need, 3rd = Rank, 4th = Frequency
                              
                                    // If the rank is 1 or 2 and it's a Want, suggesst it for removal
                                    // If the rank is 1 and it's a Need, also suggest it for removal
                                    if (tuple.elementAt(2).icon == lowRankExpense1.icon && tuple.elementAt(1).icon == wantExpense.icon || tuple.elementAt(2).icon == lowRankExpense2.icon && tuple.elementAt(1).icon == wantExpense.icon || tuple.elementAt(2).icon == lowRankExpense1.icon && tuple.elementAt(1).icon == needExpense.icon)
                                      Row(
                                        children: [
                                          //  Money Icon and Expense Text Part
                                            Expanded(
                                              child: Padding(
                                                padding: const EdgeInsets.only(left: 15),
                                                child: Text(appState.getExpenseName(tuple.first), //Specifically gets the Name
                                                  style: TextStyle(
                                                    color: Colors.black,
                                                  ),
                                                ),
                                              ),
                                            ),

                                          Expanded( //Specifically gets the Percentage
                                            // flex: 3,
                                            child: Align(
                                              alignment: Alignment.centerRight,
                                              child: Text(((appState.getExpenseCost(tuple.first)/appState.spent)*100).toStringAsFixed(2), //Specifically gets the percentage of total expenses for each expense
                                                style: TextStyle(
                                                  color: Colors.black,
                                                ),
                                              ),
                                            ),
                                          ),

                                          // The Percentage Icon
                                          Padding(
                                            padding: const EdgeInsets.only(
                                              right: 50,
                                            ),
                                            child: Icon(Icons.percent, 
                                            size: 14,
                                            color: Colors.black,
                                            ),
                                          ),
                                          //  Want Need Icon
                                          Expanded( // Aligns it nicely to the right
                                            child: Align(
                                              alignment: Alignment.centerRight,
                                              child: Row(
                                                children: [
                                                  Padding(padding: const EdgeInsets.only(left: 50),
                                                    child: tuple.elementAt(1),
                                                  )
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                
                              ],
                            ),
                          ),
                        ) : const SizedBox.shrink(),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ]
        ),
      ),
    );

  }
}

class SettingsPage extends StatefulWidget{

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {

  final double _min = 0;
  final double _max = 100;
  // double _value = 20.0;

  @override
  Widget build(BuildContext context) {

  var appState = context.watch<MyAppState>();
  var theme = Theme.of(context);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
        home: Scaffold(
            body: Container(
              decoration: BoxDecoration(
                color: Colors.grey,
                image: DecorationImage(
                  image: AssetImage('assets/images/home_background6.jpg'),
                  opacity: 0.9,
                  fit: BoxFit.cover,
                ),
              ),
              child: Column(
              children: [
              Padding( // HOME HEADING
                padding: const EdgeInsets.only(
                  left: 50,
                  right: 0,
                  top: 10,
                  bottom: 10,
                ),
                child: Align(
                  alignment: Alignment.topLeft,
                  child: Text("Settings",
                    style: TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                      fontFamily: "Nato Sans",
                    ),
                  ),
                ),
              ),
                Text("Choose the margin of similarity to other users to be used for recommendations",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
                ),
                SfSlider(
                showTicks: true,
                min: _min,
                max: _max,
                value: appState.sliderValue,
                interval: 10,
                showLabels: true,
                onChanged: (dynamic newValue) {
                  setState(() {
                    appState.sliderValue = newValue;
                    appState.chosenMargin = int.parse(appState.sliderValue.toStringAsFixed(0));
                  });
                },
              ),
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text("Current Value: ${appState.chosenMargin}",
                  style: TextStyle(
                    fontFamily: "Open Sans",
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text("Recommended: 20",
                  style: TextStyle(
                    // fontFamily: "Open Sans",
                    color: Colors. grey,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
              ]
              )
            )
        )
    );
  }
}

class EmptyPage extends StatelessWidget{

  @override
  Widget build(BuildContext context) {
    
    var appState = context.watch<MyAppState>();
    var theme = Theme.of(context);

    return Scaffold();

  }
}

class DataConnection {
  final String baseUrl;

  DataConnection(this.baseUrl);

  Future<Map<String, dynamic>> fetchData(String endpoint) async {
    
    final url = Uri.parse('$baseUrl/$endpoint');
    // Get the JWT token from SharedPreferences
    String? jwtToken = await getTokenFromSharedPreferences();
    final headers = {"Authorization": "Bearer $jwtToken"};
    final response = await http.get(url,headers: headers);

    if (response.statusCode == 200) {
      dynamic decodedData = json.decode(response.body);
      print("decoded data $decodedData");
      return json.decode(response.body);
    } else {
      //throw Exception('Failed to fetch data');
      print('Failed to fetch data: ${response.statusCode}');
      return {}; // or return an appropriate default value based on your use case
    }
  }

  Future<Map<String, dynamic>> sendData(String endpoint, Map<String, dynamic> data) async {
    final url = Uri.parse('$baseUrl/$endpoint');

    Map<String, String> headers = {}; // Declare headers variable

     // Conditionally set headers based on endpoint
    if (endpoint == 'login' || endpoint == 'signup' || endpoint == 'signup/goals') {
      headers = {"Content-Type": "application/x-www-form-urlencoded"};
    } else {
      // Get the JWT token from SharedPreferences
      String? jwtToken = await getTokenFromSharedPreferences();
      headers = {"Content-Type": "application/x-www-form-urlencoded", 'Authorization': 'Bearer $jwtToken'};
    }

    final response = await http.post(url, headers: headers, body: data);

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      //throw Exception('Failed to send data'); 
      print('Failed to fetch data: ${response.statusCode}');
      return {}; // or return an appropriate default value based on your use case
    }
  }
  void saveTokenToSharedPreferences(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('jwt_token', token);
  }

  // Retrieve the JWT token from SharedPreferences
  Future<String?> getTokenFromSharedPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('jwt_token');
  }

}