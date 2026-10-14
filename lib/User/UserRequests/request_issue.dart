import 'package:flutter/material.dart';
import 'package:mech_go/User/UserRequests/request_detail.dart';

class RequestIssue extends StatefulWidget {
  const RequestIssue({super.key});

  @override
  State<RequestIssue> createState() => _RequestIssueState();
}

class _RequestIssueState extends State<RequestIssue> {

  final Color primaryRed =
      const Color.fromARGB(255, 198, 24, 11);

  int selectedProblemIndex = -1;
  
  List<Map<String, dynamic>> vehicleType=[
    {
      'onClick': 'MotorBike',
      'icon': Icons.motorcycle,
      'vehicleName': 'Bike'
    },
    {
      'onClick': 'Car',
      'icon': Icons.car_crash_rounded,
      'vehicleName': 'Car'
    },
    {
      'onClick': 'Bus',
      'icon': Icons.bus_alert,
      'vehicleName': 'Bus'
    }
  ];

  int selectedVehicleIndex=0;


  List<Map<String,dynamic>> problemType=[
   {
    'problem': 'Engine Problem',
   },
   {
    'problem': 'Tire/Puncture',
   },
   {
    'problem': 'Battery Problem',
   },
   {
    'problem': 'Fuel Problem',
   },
   {
    'problem': 'Electrical Issue',
   },
   {
    'problem': 'Other Problem',
   },
  ];
  @override
  Widget build(BuildContext context) {
    final size=MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        iconTheme: IconThemeData(
          color: Colors.white
        ),
        backgroundColor: primaryRed,
        title: Text('What is your Issue?', style: TextStyle(
          color:Colors.white,
          fontFamily: 'Times New Roman',
          fontSize: size.height*0.02,
          fontWeight: FontWeight.bold,
        ),),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: size.height*0.01,
          ),
          Center(
            child: Text('Tell us about your vehicle problem', style: TextStyle(
              color: Colors.black54,
              fontWeight: FontWeight.bold,
            ),),
          ),
          SizedBox(
            height: size.height*0.03,
          ),
           Padding(
             padding: const EdgeInsets.all(10),
             child: Text('Select Vehicle Type', style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: size.height*0.02
                       ),),
           ),
           SizedBox(
            height: size.height*0.13,
             child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: vehicleType.length,
              padding: EdgeInsets.symmetric(horizontal: 11),
              itemBuilder: (context , index){
                bool isSelected=selectedVehicleIndex==index;
              return GestureDetector(
              onTap: (){
                 setState(() {
                      selectedVehicleIndex =
                          index;
                    });
      
                    debugPrint(
                      vehicleType[index]
                          ['onClick'],
                    );
              },
               child: AnimatedContainer(
                duration: Duration(
                  milliseconds: 250,
                ),
                margin: EdgeInsets.only(right: 12),
                width: size.width*0.29,
                height: size.height*0.10,
                decoration: BoxDecoration(
                  color: isSelected ? primaryRed : Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(
                    color: isSelected ? primaryRed : Colors.black26,
                    width: 1.5
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 8,
                      offset: Offset(0, 3)
                    )
                  ]
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                             
                    Icon(vehicleType[index]['icon'], 
                    color: isSelected ? Colors.white : Colors.black, size: 50,),
                    Text(vehicleType[index]['vehicleName'],style: TextStyle(
                      color: isSelected ? Colors.white : Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 15
                             
                    ),)
                  ],
                ),
               ),
             );
             }),
           ),
           SizedBox(
            height: size.height*0.02,
          ),
           Padding(
             padding: const EdgeInsets.all(10),
             child: Text('Select Problem', style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: size.height*0.02
                       ),),
           ),
           Expanded(
             child: ListView.builder(
              itemCount: problemType.length,
              itemBuilder: (context, index){
               final item = problemType[index];
               bool isSelected=selectedProblemIndex==index;
                 return Column(
                              
                   children: [
                              
                     Padding(
                              
                               padding:
                                   EdgeInsets.only(left: 8, right: 8, top: 3),
                      
                               child: ListTile(
                                shape: ShapedInputBorder(shape: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8)
                                )),
                                title: Text(item['problem'],style: TextStyle(
                      color: Colors.black87,
                      fontWeight:
                          FontWeight.w500,
                      fontSize: 14,
                    ),),
                    trailing: Checkbox(
                      activeColor: primaryRed,
                      value: isSelected, 
                                onChanged: (value){
                                setState(() {
                                  if(value==true){
                                    selectedProblemIndex=index;
                                  }else{
                                    selectedProblemIndex=-1;
                                  }
                                });
                                }),
                                onTap: (){
                                  setState(() {
                                    selectedProblemIndex=index;
                                  });
                                },
                                   ),
                               ),
                     
                       
                   ],
                 );
             }),
           ),
           GestureDetector(
                        onTap: (){
                          if(selectedProblemIndex == -1){
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Please select your vehicle problem'),)
                            );
                            return;
                          }
                          Navigator.push(context, 
                          MaterialPageRoute(builder:
                           (context)=>RequestDetail(
                            vehicleType: vehicleType[selectedVehicleIndex]['vehicleName'],
                            problemType: problemType[selectedProblemIndex]['problem'],
                           )));
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                            width: double.infinity,
                            height: size.height*0.06,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              color: primaryRed,
                            ),
                            child: Center(
                              child: Text('Next', style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold
                              ),),
                            ),
                          ),
                        ),
                      )
        ],
      ),
    );
  }
}