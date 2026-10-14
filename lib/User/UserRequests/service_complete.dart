import 'package:flutter/material.dart';

class ServiceComplete extends StatefulWidget {
  const ServiceComplete({super.key});

  @override
  State<ServiceComplete> createState() => _ServiceCompleteState();
}

class _ServiceCompleteState extends State<ServiceComplete> {
 int characterCount=0;
 TextEditingController reviewController=TextEditingController();
  final Color primaryRed = const Color.fromARGB(255, 250, 41, 26);

  @override
  Widget build(BuildContext context) {
    final size=MediaQuery.of(context).size;
    return Scaffold(
      body: Column(
        children: [
          SizedBox(
            height: size.height*0.08,
          ),
          Center(child: Icon(Icons.check_circle,
           color: primaryRed,size: 115,)),
           SizedBox(
            height: size.height*0.01,
          ),
          Center(
            child: Text('Service Completed!', style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 24
            ),),
          ),
          SizedBox(
            height: size.height*0.01,
          ),
          Center(
            child: Text('Your vehicle is ready to go', style: TextStyle(
              color: Colors.black54,
              fontWeight: FontWeight.bold,
              fontSize: 14
            ),),
          ),
          SizedBox(
            height: size.height*0.02,
          ),
          Container(
            width: size.width-15,
            height: size.height*0.2,
            decoration: BoxDecoration(
              color: Colors.white60,
              borderRadius: BorderRadius.circular(13),
              border: BoxBorder.all(
                style: BorderStyle.solid,
                color: Colors.black54
              )
            ),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 12.0, right: 8, top: 8),
                  child: Row(
                    children: [
                      Text('Service', style: TextStyle(
                        fontSize: 14
                      ),),
                      Spacer(),
                      Text('Engine Repair', style: TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                        fontWeight: FontWeight.bold
                      ),),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 12.0, right: 8, top: 8),
                  child: Row(
                    children: [
                      Text('Mechanic', style: TextStyle(
                        fontSize: 14
                      ),),
                      Spacer(),
                      Text('All Auto Expert', style: TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                        fontWeight: FontWeight.bold
                      ),),
                    ],
                  ),
                ),
                Divider(),
                Padding(
                  padding: const EdgeInsets.only(left: 12.0, right: 8, top: 8),
                  child: Row(
                    children: [
                      Text('Total Paid', style: TextStyle(
                        fontSize: 14
                      ),),
                      Spacer(),
                      Text('PKR 1,500', style: TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                        fontWeight: FontWeight.bold
                      ),),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 12.0, right: 8, top: 8),
                  child: Row(
                    children: [
                      Text('Payment Method', style: TextStyle(
                        fontSize: 14
                      ),),
                      Spacer(),
                      Text('Cash', style: TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                        fontWeight: FontWeight.bold
                      ),),
                    ],
                  ),
                )
              ],
            ),
          ),
           SizedBox(
            height: size.height*0.02,
          ),
          Center(
            child: Text('How was your experience?', style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 20
            ),),
          ),
          Center(
            child: Text('Rate the Mechanic', style: TextStyle(
              color: Colors.black54,
              fontWeight: FontWeight.bold,
              fontSize: 14
            ),),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(onPressed: (){}, icon: Icon(Icons.star, 
              color: primaryRed, size: 37,)),
              IconButton(onPressed: (){}, icon: Icon(Icons.star, 
              color: primaryRed, size: 37,)),
              IconButton(onPressed: (){}, icon: Icon(Icons.star, 
              color: primaryRed, size: 37,)),
              IconButton(onPressed: (){}, icon: Icon(Icons.star, 
              color: primaryRed, size: 37,)),
              IconButton(onPressed: (){}, icon: Icon(Icons.star, 
              color: primaryRed, size: 37,)),
              
            ],
          ),
           SizedBox(
            height: size.height*0.03,
          ),
          Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text('Write a Review (Optional)', style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 16
              ),),
            ),
          ),
          Padding(
             padding: const EdgeInsets.only(left:8.0, right: 8),
             child: Container(
             
                    height:
                        size.height * 0.10,
                    decoration:
                        BoxDecoration(
             
                      borderRadius:
                          BorderRadius.circular(
                        14,
                      ),
             
                      border: Border.all(
                        color:
                            Colors.black26,
                      ),
                    ),
             
                    child: Stack(
             
                      children: [
             
                        Padding(
             
                          padding:
                              const EdgeInsets.only(
                            left: 12,
                            right: 12,
                            top: 8,
                            bottom: 25,
                          ),
             
                          child: TextField(
             
                            controller:
                                reviewController,
             
                            maxLength: 250,
             
                            maxLines: null,
             
                            expands: true,
             
                            textAlignVertical:
                                TextAlignVertical.top,
             
                            onChanged:
                                (value) {
             
                              setState(() {
                                characterCount =
                                    value.length;
                              });
                            },
             
                            decoration:
                                const InputDecoration(
             
                              border:
                                  InputBorder.none,
             
                              counterText: '',
             
                              hintText:
                                  'Greate service very professional and quick.....',
             
                              hintStyle:
                                  TextStyle(
                                color:
                                    Colors.black45,
                              ),
                            ),
                          ),
                        ),
             
                        // CHARACTER COUNTER
                        
                      ],
                    ),
                  ),
           ),
           SizedBox(
            height: size.height*0.03,
           ),
           Padding(padding: EdgeInsets.all(8),
                   child: SizedBox(
                    width: double.infinity,
                    height: size.height*0.065,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryRed,
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadiusGeometry.circular(10)
                        )
                      ),
                      onPressed: (){
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Request send successfully',)));
                      }, child: Text('Submit Reveiw', style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16
                      ),)),
                   ),)

        ],
      ),
    );
  }
}