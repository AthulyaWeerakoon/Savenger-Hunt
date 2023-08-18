import 'package:flutter/material.dart';
import 'package:scavenger_s_hunt/session.dart';

class NavigationPage extends StatefulWidget {
  final SessionConnection session;

  const NavigationPage({super.key, required this.session});

  @override
  State<NavigationPage> createState() => _NavigationPage();
}



class _NavigationPage extends State<NavigationPage> {
  int tabState = 1;
  int totalQ = 0;
  
  @override
  void initState() {
    super.initState();

    widget.session.getTotalQ().then((value) { 
      setState(() {
        totalQ = value;
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  /*
  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
    });
  }
  */

  void setTab(int tab){
    setState(() {
      tabState = tab;
    });
  }

  List<Widget> quizCountList(){
    List<Widget> returnList = List.empty(growable: true);
    for(int i = 1; i <= totalQ; i++){
      returnList.add(
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5),
            color: const Color.fromARGB(255, 145, 226, 157),
          ),
          child: Center(
            child: Text(
              i.toString(),
              style: const TextStyle(
                color: Color.fromARGB(255, 227, 241, 229),
                fontFamily: 'Arial',
                fontSize: 12,
                fontWeight: FontWeight.w600,
                shadows: <Shadow>[
                  Shadow(
                    color: Color.fromARGB(255, 105, 181, 119),
                    offset: Offset(1, 1),
                    blurRadius: 5,
                  )
                ]
              ),
            ),
          ),
        )
      );
    }
    
    return returnList;
  }
  
  Color fromState(bool isIcon, int buttonId){
    switch(tabState){
    case 0:
      if(isIcon) {
        if(buttonId == tabState) {
          return const Color.fromARGB(255, 255, 255, 255);
        } else {
          return const Color.fromARGB(255, 92, 154, 154);
        }
      }
      else{
        if(buttonId == tabState) {
          return const Color.fromARGB(255, 120, 237, 237);
        } else {
          return const Color.fromARGB(255, 202, 244, 244);
        }
      }
    case 1:
      if(isIcon) {
        if(buttonId == tabState) {
          return const Color.fromARGB(255, 255, 255, 255);
        } else {
          return const Color.fromARGB(255, 112, 152, 119);
        }
      }
      else{
        if(buttonId == tabState) {
          return const Color.fromARGB(255, 125, 233, 145);
        } else {
          return const Color.fromARGB(255, 202, 239, 209);
        }
      }
    default:
      if(isIcon) {
        if(buttonId == tabState) {
          return const Color.fromARGB(255, 255, 255, 255);
        } else {
          return const Color.fromARGB(255, 142, 152, 78);
        }
      }
      else{
        if(buttonId == tabState) {
          return  const Color.fromARGB(255, 237, 255, 123);
        } else {
          return const Color.fromARGB(255, 252, 255, 233);
        }
      }
    }
  }
  
  
  Widget pagePush(){
    if (tabState == 0){
      return Center(
        key: ValueKey<int>(tabState),
        child: Image.asset(
          "assets/ui/startup_img.png",
          height: 100,
          width: 100,
        ),
      );
    }
    else if(tabState == 1){
      return SizedBox(
      key: ValueKey<int>(tabState),
      child: Padding(
        padding: const EdgeInsets.all(15.0),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(7.5),
              color: const Color.fromARGB(255, 220, 243, 224)),
            child: CustomScrollView(
              primary: false,
              slivers: <Widget>[
                SliverPadding(
                  padding: const EdgeInsets.all(20),
                  sliver: SliverGrid.count(
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    crossAxisCount: 5,
                    children: quizCountList()
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }
    else{
      return Center(
        key: ValueKey<int>(tabState),
        child: Image.asset(
          "assets/ui/startup_img.png",
          height: 100,
          width: 100,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          AnimatedSwitcher(
              duration: const Duration(milliseconds: 100),
              transitionBuilder: (Widget child, Animation<double> animation) {
                return FadeTransition(opacity: animation, child: child);
              },
              child: pagePush(),
          ),
          SizedBox(
            width: double.infinity,
            height: 50.0,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 100),
              transitionBuilder: (Widget child, Animation<double> animation) {
                return FadeTransition(opacity: animation, child: child);
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                key: ValueKey<int>(tabState),
                children: [
                  Expanded(
                    flex: 1,
                    child: GestureDetector(
                      onTap: () => setTab(0),
                      child: Container(
                        height: 50.0,
                        decoration: BoxDecoration(
                          color: fromState(false, 0),
                          border: Border(
                            left:BorderSide(
                              width: 0.0, 
                              color: fromState(false, 0))
                          ),
                        ),
                        child: Icon(
                          Icons.notifications,
                          color: fromState(true, 0),)
                      ),
                    )
                  ),
                  Expanded(
                    flex: 1,
                    child: GestureDetector(
                      onTap: () => setTab(1),
                      child: Container(
                        height: 50.0,
                        decoration: BoxDecoration(
                          color: fromState(false, 1),
                          border: Border(
                            left:BorderSide(
                              width: 0.0, 
                              color: fromState(false, 1))
                          ),
                        ),
                        child: Icon(
                          Icons.home,
                          color: fromState(true, 1),)
                      ),
                    )
                  ),
                  Expanded(
                    flex: 1,
                    child: GestureDetector(
                      onTap: () => setTab(2),
                      child: Container(
                        height: 50.0,
                        decoration: BoxDecoration(
                          color: fromState(false, 2),
                          border: Border(
                            left:BorderSide(
                              width: 0.0, 
                              color: fromState(false, 2))
                          ),
                        ),
                        child: Icon(
                          Icons.leaderboard,
                          color: fromState(true, 2),
                        )
                      ),
                    )
                  ),
                ]
              ),
            ),
          ),
        ],
        )
      /*
      TabBarView(
        children: <Widget>[
          Center(
            child: Text("It's where all the puzzles are"),
          ),
          Center(
            child: Text("It's where the leaderboard is"),
          ),
          Center(
            child: Text("It's where notifications are"),
          ),
        ],
      ),
      */
    );
  }
}