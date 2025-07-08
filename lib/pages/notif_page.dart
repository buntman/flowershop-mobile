import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flowershop/pages/cart_page.dart';
import 'package:flowershop/pages/customize_page.dart';
import 'package:flowershop/pages/home_page.dart';

class NotifPage extends StatefulWidget {
  const NotifPage({super.key});

  @override
  State<NotifPage> createState() => _NotifPageState();
}

class _NotifPageState extends State<NotifPage> {

  int _selectedIndex = 3; 

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      switch (_selectedIndex){
        case 0:
          Navigator.push(context, MaterialPageRoute(builder: (context) => HomePage()));
        case 1:
          Navigator.push(context, MaterialPageRoute(builder: (context) => CustomizePage()));
        case 2:
          Navigator.push(context, MaterialPageRoute(builder: (context) => CartPage()));
        case 3:
          Navigator.push(context, MaterialPageRoute(builder: (context) => NotifPage()));
      }
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
       backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          "Rizza FlowerShop",
          style: GoogleFonts.dancingScript(
            fontWeight: FontWeight.bold,
            fontSize: 28,
            color: Color.fromRGBO(190, 54, 165, 1),
          ),
        ),
        actions: [
          Icon(Icons.notifications, color: Color.fromRGBO(190, 54, 165, 1)),
          SizedBox(width: 10),
          Icon(Icons.shopping_cart, color: Color.fromRGBO(190, 54, 165, 1)),
          SizedBox(width: 10),
          Icon(Icons.search, color: Color.fromRGBO(190, 54, 165, 1)),
          SizedBox(width: 20),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.purple,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.grid_view), label: "Gallery"),
          BottomNavigationBarItem(icon: Icon(Icons.dashboard_customize), label: "Customize"),
          BottomNavigationBarItem(icon: Icon(Icons.shopping_cart), label: "Checkout"),
          BottomNavigationBarItem(icon: Icon(Icons.notifications), label: "Notification"),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color.fromRGBO(190, 54, 165, 1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: Text("All", style: TextStyle(color: Colors.white)),
                ),
                SizedBox(width: 10),
                TextButton(onPressed: (){}, child: Text(
                  "Unread", style: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold)
                )),
                Spacer(),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color.fromRGBO(190, 54, 165, 1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: Text("Mark all as read", style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
            SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: 10,
                itemBuilder: (context, index) {
                  return Card(
                    child: ListTile(
                      leading: Container(
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Color.fromRGBO(190, 54, 165, 1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(Icons.warning, color: Colors.white),
                      ),
                      title: Text("Order Pickup Alert", style: TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text("Your order is almost ready! Stay tuned!"),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text("27/11/24", style: TextStyle(fontSize: 12)),
                          SizedBox(height: 4),
                          SizedBox(
                            width: 20,
                            child: IconButton(
                              icon: Icon(Icons.delete, color: Colors.red),
                              onPressed: () {},
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
