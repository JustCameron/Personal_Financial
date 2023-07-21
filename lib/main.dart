
import 'dart:io';
//import 'package:tuple/tuple.dart';
import 'dart:developer';
import 'dart:math';
import 'dart:ui';
import 'package:collection/collection.dart';
import 'package:pie_chart/pie_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:window_manager/window_manager.dart';


void main() async{
  WidgetsFlutterBinding.ensureInitialized(); //Everything here controls size of app when resized
  await windowManager.ensureInitialized();
  if (Platform.isWindows) {
    WindowManager.instance.setMinimumSize(const Size(768, 736));

  }
  runApp(MyApp());
}    

class MyApp extends StatelessWidget {
  const MyApp({super.key});

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
  double currExpCost = 0.00;
  double currIncEarn = 0.00;
  var currExpName = "";
  var currIncName = "";

  //WANTS/NEEDS/SAVINGS PERCENTAGES
  double wantPercentage = 0.00;
  double needPercentage = 0.00;
  double savingsPercentage = 0.00;

  //Stuff For Jon
  double wantTotal = 0.00; // Keep track of total spent on wants - For Jon
  double needTotal = 0.00; // Keep track of total spent on needs - For Jon


  void removeExpense(exp){ //Remove clicked Expense from Expense List
    expenseList.remove(exp);
    //   appState.balance -= appState.expenseCost; // subtract expense from balance
    // appState.spent += appState.expenseCost; // add expense cost to spent
    balance += double.parse(exp.replaceAll(RegExp(r'[^0-9,.]'),'')); // add removed expense cost to balance [replaceAll is used here to only get the numbers from the String]
    spent -= double.parse(exp.replaceAll(RegExp(r'[^0-9,.]'),'')); // subtract removed expense cost from spent [replaceAll is used here to only get the numbers from the String]
    print (double.parse(exp.replaceAll(RegExp(r'[^0-9,.]'),'')));
    notifyListeners();
  }

   removeIncome(inc){ //Remove clicked Income from Income List
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


    return Scaffold(
      body: Column(
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
            child: TextField(
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
            child: TextField(
              obscureText: true, //Adds the Asteriks for Password confidentiality
              decoration: InputDecoration(
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
                onPressed: (){ //After clicking Login
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => MainPage()), //Goes to main page
                  );
                }, 
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

        ],
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
      page = Placeholder();
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
                    label: Text('Placeholder'),
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

class _HomeMenuState extends State<HomeMenu> {
  @override
  Widget build(BuildContext context) {
    
    var theme = Theme.of(context);
    var appState = context.watch<MyAppState>();
    final usdController = TextEditingController();
    final jmdController = TextEditingController();
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
                  child: Text("Account",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      fontFamily: "Nato Sans"
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
                        child: Text('Transactions',
                          textAlign: TextAlign.left,
                          style: TextStyle(
                            fontFamily: 'Nato Sans',
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                      ),

                      //  IF TOTAL TRANSACTIONS IS GREATER THAN 5, RUN THIS COMMAND TO ONLY GET 5 LATEST
                      if (appState.transactionList != [] && appState.transactionList.length >= 5) //Displays Transactions if list isn't emtpy
                        for (var i=0; i<=4; i++) //Get the 5 latest Transactions
                          Align(
                            alignment: Alignment.centerLeft,
                            child: SizedBox(
                              width: 250,
                              child: Row(
                                children: [
                                  Icon(Icons.attach_money_rounded,
                                    size: 20,
                                  ),
                                  Text(appState.transactionList[i].toString(), //Shows each individual variable
                                  //child: Text(appState.transactionList[count] as String //Shows each entry
                                  style: TextStyle(
                                    fontFamily: 'Open Sans',
                                    fontSize: 15,
                                    color: const Color.fromARGB(255, 253, 112, 69),
                                    height: 1, //brings icon more in line with text
                                  ),
                                  ),
                                ],
                              )
                              ),
                          ),
                      // ELSE IF TOTAL TRANSACTIONS IS LESS THAN 5, RUN THIS COMMAND
                      if (appState.transactionList != [] && appState.transactionList.length < 4) //Displays Transactions if list isn't emtpy
                        for (var trans in appState.transactionList) //Get the 5 latest Transactions
                          Align(
                            alignment: Alignment.centerLeft,
                            child: SizedBox(
                              width: 250,
                              child: Row(
                                children: [
                                  Icon(Icons.attach_money_rounded,
                                    size: 20,
                                  ),
                                  Text(trans.toString(), //Shows each individual variable
                                  //child: Text(appState.transactionList[count] as String //Shows each entry
                                  style: TextStyle(
                                    fontFamily: 'Open Sans',
                                    fontSize: 15,
                                    color: const Color.fromARGB(255, 253, 112, 69),
                                    height: 1, //brings icon more in line with text
                                  ),
                                  ),
                                ],
                              )
                              ),
                          ),

                      if (appState.transactionList.isEmpty) //Displays message if list IS empty
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

    // To check if the expense type is want or need (used in Add Expense)
    Icon want = Icon(
      Icons.store_mall_directory,
      color: Colors.blueAccent,
      );
    Icon need = Icon(
      Icons.house,
      color: Colors.green
      );

    var zippedLists = IterableZip([appState.expenseList, appState.expenseTypeList, appState.rankList, appState.expenseFreqList]);
    var incomeZippedLists = IterableZip([appState.incomeList, appState.incomeFreqList]);

    final addExpenseNameController = TextEditingController();
    final addExpenseCostController = TextEditingController();
    final addIncomeNameController = TextEditingController();
    final addIncomeValueController = TextEditingController();


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
                  child: Text("Dashboard",
                    style: TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                      fontFamily: "Nato Sans"
                    ),
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
                  child: Text("Information",
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
                            onPressed: (){
                              setState(() {
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
                            }, 
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

                      //          INCOME LIST

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
                            onPressed: (){
                              setState(() {
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

class _SignUpPageState extends State<SignUpPage> {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    Widget page;


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
      
      
            Padding(          // The text and padding between Email and Email Text Field
              padding: const EdgeInsets.only(
                left: 400,
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
                left: 390,
                right: 400,
                top: 0,
                bottom: 20,
              ),
              child: SizedBox(
                width: 460,
                height: 50,
                child: TextField(
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
              child: SizedBox(
                width: 460,
                height: 50,
                child: TextField(
                  obscureText: true, //Adds the Asteriks for Password confidentiality
                  decoration: InputDecoration(
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
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => FinancialAccountCreationPage()),
                      );
                    }, 
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
    final balanceController = TextEditingController();
    final annualincomeController = TextEditingController();
    final livingexpenseController = TextEditingController();
    final subscriptionexpenseController = TextEditingController();
    final mortgageController = TextEditingController();
    final annualinterestController = TextEditingController();
    final savingsgoalController = TextEditingController();
    String beginningbalance;
    String annualincome;
    String livingexpense;
    String subscriptionexpense;
    String mortgage;
    String annualinterest;
    String savingsgoal;
    //Checkboxes
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
                    onPressed: () {
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

    List<Color> piechartcolours = [Colors.lightGreen.withOpacity(0.6), Colors.blueAccent.withOpacity(0.6), Colors.deepPurple.withOpacity(0.6)]; //Create list of colours for pie chart
    //String piechartText = "Income \n ${appState.income + appState.beginbalance}"; // Income = Monthly Income + Initial Balance. Shows in chart center
    String piechartText = "Total Income \n ${appState.income} \n\n Gross Balance \n ${appState.beginbalance+appState.income}"; // Income = Income, Gross Balance = Income + Beginning Balance

    // Current Percentages
    print(appState.wantTotal);
    print(appState.spent);
    var wantsPercentage = (appState.wantPercentage*100).toStringAsFixed(2); //toStringAsFixed is pretty much round()
    var needsPercentage = (appState.needPercentage*100).toStringAsFixed(2);
    var savingsPercentage = (appState.savingsPercentage).toStringAsFixed(2);

    // Recommended Percentages [not done]
    double recommendedWantsPercentage = 0.0;
    double recommendedNeedsPercentage = 0.0;
    double recommendedSavingsPercentage = 0.0;
    

    // Get Month:
    DateTime currentDate = DateTime.now(); //Get Current Date
    var monthNumber = "${currentDate.month}"; //Get Current Month (as integer)
    var currentMonth;
    var nextMonth;
    if (int.parse(monthNumber) == 1){
      currentMonth = "January";
      nextMonth = "February";
    }
    else if(int.parse(monthNumber) == 2){
      currentMonth = "February";
      nextMonth = "March";
    }
    else if(int.parse(monthNumber) == 3){
      currentMonth = "March";
      nextMonth = "April";
    }
    else if(int.parse(monthNumber) == 4){
      currentMonth = "April";
      nextMonth = "May";
    }
    else if(int.parse(monthNumber) == 5){
      currentMonth = "May";
      nextMonth = "June";
    }
    else if(int.parse(monthNumber) == 6){
      currentMonth = "June";
      nextMonth = "July";
    }
    else if(int.parse(monthNumber) == 7){
      currentMonth = "July";
      nextMonth = "August";
    }
    else if(int.parse(monthNumber) == 8){
      currentMonth = "August";
      nextMonth = "September";
    }
    else if(int.parse(monthNumber) == 9){
      currentMonth = "September";
      nextMonth = "October";
    }
    else if(int.parse(monthNumber) == 10){
      currentMonth = "October";
      nextMonth = "November";
    }
    else if(int.parse(monthNumber) == 11){
      currentMonth = "November";
      nextMonth = "December";
    }
    else if(int.parse(monthNumber) == 12){
      currentMonth = "December";
      nextMonth = "January";
    }


    //Create Data points for pie chart
    Map<String, double> dataMap = {
      "Needs": appState.needTotal,
      "Wants": appState.wantTotal,
      "Savings": appState.income - (appState.needTotal + appState.wantTotal),
    };
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
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
      
            Padding( // DATE HEADING
              padding: const EdgeInsets.only(
                left: 0,
                right: 70,
                top: 10,
                bottom: 0,
              ),
              child: Align(
                alignment: Alignment.center,
                //Sets date to current month - next month
                child: Text("${currentMonth.toString()} - ${nextMonth.toString()}",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    fontFamily: "Nato Sans"
                  ),
                ),
              ),
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
      
            //Everything below Budget Heading
            Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(
                    left: 50,
                    right: 0,
                    top: 30,
                    bottom: 15,
                  ),
                  child: PieChart(  // PIE CHART
                    dataMap: dataMap,
                    initialAngleInDegree: 180, //Change this to rotate the chart
                    chartType: ChartType.ring, // Set the pie chart type to be a ring, use 'disc' otherwise
                    chartRadius: MediaQuery.of(context).size.width/6, // Size of Pie Chart
                    centerText: piechartText, //Sets the text in the center of chart
                    chartLegendSpacing: 32, //Distance of legend from Pie Chart
                    animationDuration: Duration(milliseconds: 1200), //Length of Pie Chart animation
                    colorList: piechartcolours, //Set pie chart colours, variable initialized earlier
                    legendOptions: LegendOptions(
                      legendShape: BoxShape.circle, //Makes the legends boxes circles
                      legendTextStyle: TextStyle(
                        fontFamily: 'Nato Sans',
                        fontWeight: FontWeight.bold,
                      )
                    ),
                    chartValuesOptions: ChartValuesOptions( //Configure values in chart
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
                  padding: const EdgeInsets.only(left:210),
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
                            Expanded(flex: 4,child: Text("Wants %: $recommendedWantsPercentage",
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
                            Expanded(flex: 4,child: Text("Needs %: $recommendedNeedsPercentage",
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
                            Expanded(flex: 4,child: Text("Savings %: $recommendedSavingsPercentage",
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
                                      child: Text('Expenses for $currentMonth'),
                                    )),
                                    Expanded(child: Padding( //Cost Text
                                      padding: const EdgeInsets.only(left: 184, top: 10),
                                      child: Text('Cost'),
                                    )),
                                  ],
                                ),
      
                                Divider(color: Colors.grey,),
      
                                if (appState.expenseList != []) //Displays Expenses if list isn't emtpy
                                  for (var expense in appState.expenseList) //Get all expenses
                                    Row(
                                      children: [
                                        //  Money Icon and Expense Text Part
                                        Padding(
                                          padding: const EdgeInsets.only(
                                            left: 5,
                                          ),
                                          child: Icon(Icons.attach_money_rounded, 
                                          //color: Colors.deepOrangeAccent,
                                          ),
                                        ),
                                        Text(expense.replaceAll(RegExp(r'[^A-Z,a-z]'),''),
                                          style: TextStyle(
                                            //color: Colors.deepOrangeAccent,
                                          ),
                                        ),
      
                                        //  COST OF EXPENSE
                                        Expanded( // Aligns it nicely to the right
                                          child: Align(
                                            alignment: Alignment.centerRight,
                                            child: Padding(
                                              padding: const EdgeInsets.only(right: 30),
                                              child: Text(expense.replaceAll(RegExp(r'[^0-9,.]'),'') // Expense Button To Delete
                                                  
                                                ),
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
                                        child: Text('Income for $currentMonth'),
                                      )),
                                      Expanded(child: Padding( //Received Text
                                        padding: const EdgeInsets.only(left: 160, top: 10, right: 10),
                                        child: Text('Received'),
                                      )),
                                    ],
                                  ),
      
                                  Divider(color: Colors.grey,),
                                  if (appState.incomeList != []) //Displays Income if list isn't emtpy
                                    for (var income in appState.incomeList) //Get all income channels
                                      Row(
                                        children: [
                                          //  Money Icon and Income Text Part
                                          Padding(
                                            padding: const EdgeInsets.only(
                                              left: 5,
                                            ),
                                            child: Icon(Icons.attach_money_rounded, 
                                            //color: Colors.deepOrangeAccent,
                                            ),
                                          ),
                                          Text(income.replaceAll(RegExp(r'[^A-Z,a-z]'),''),
                                            style: TextStyle(
                                              //color: Colors.deepOrangeAccent,
                                            ),
                                          ),
      
                                          //  INCOME EARNINGS
                                          Expanded( // Aligns it nicely to the right
                                            child: Align(
                                              alignment: Alignment.centerRight,
                                              child: Padding(
                                                padding: const EdgeInsets.only(right: 30),
                                                child: Text(income.replaceAll(RegExp(r'[^0-9,.]'),'') // INCOME Button To Delete
                                                    
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
          ],
        ),
      ),
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