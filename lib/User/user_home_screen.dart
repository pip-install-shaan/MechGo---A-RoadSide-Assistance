import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mech_go/Services/geo_locator.dart';
import 'package:mech_go/User/UserRequests/request_issue.dart';
import 'package:mech_go/User/UserNotifications/user_notification.dart';


class UserHomeScreen extends StatefulWidget {
  final VoidCallback? onViewAllRequests;

  const UserHomeScreen({super.key, this.onViewAllRequests});

  @override
  State<UserHomeScreen> createState() => _UserHomeScreenState();
}


class _UserHomeScreenState extends State<UserHomeScreen> {

  final Color primaryRed =
      const Color.fromARGB(255, 198, 24, 11);


  GoogleMapController? mapController;

  LatLng? currentLocation;

  bool loadingLocation = true;

  
  int selectedIndex = 0;

  final List<Map<String, dynamic>> services = [

    {
      'icon': Icons.car_repair,
      'title': 'Engine',
      'subtitle': 'Problem',
    },

    {
      'icon': Icons.tire_repair,
      'title': 'Tire',
      'subtitle': 'Problem',
    },

    {
      'icon': Icons.battery_alert,
      'title': 'Battery',
      'subtitle': 'Problem',
    },

    {
      'icon': Icons.local_gas_station,
      'title': 'Fuel',
      'subtitle': 'Problem',
    },

    {
      'icon': Icons.electrical_services,
      'title': 'Electrical',
      'subtitle': 'Problem',
    },

    {
      'icon': Icons.build,
      'title': 'Other',
      'subtitle': 'Problem',
    },
  ];



  final List<Map<String, dynamic>> requests = [];


  @override
  void initState() {
    super.initState();

    getLocation();
  }

  Future<void> getLocation() async {
  if (!mounted) return;

  setState(() {
    loadingLocation = true;
  });

  try {
    final Position? position =
        await LocationService.getCurrentLocation();

    if (!mounted) return;

    if (position == null) {
      setState(() {
        loadingLocation = false;
        currentLocation = null;
      });

      return;
    }

    final LatLng location = LatLng(
      position.latitude,
      position.longitude,
    );

    setState(() {
      currentLocation = location;
      loadingLocation = false;
    });

    if (mapController != null) {
      await mapController!.animateCamera(
        CameraUpdate.newLatLngZoom(
          location,
          16,
        ),
      );
    }
  } catch (e, stackTrace) {
    debugPrint('LOCATION ERROR: $e');
    debugPrintStack(stackTrace: stackTrace);

    if (!mounted) return;

    setState(() {
      loadingLocation = false;
      currentLocation = null;
    });
  }
}

  void showLocationError() {

    ScaffoldMessenger.of(context)
        .showSnackBar(
      const SnackBar(
        content: Text(
          'Please enable location to use MechGo.',
        ),
      ),
    );
  }

  void selectService(
      Map<String, dynamic> service) {

    String problem =
        service['title'];

    debugPrint(
      'Selected problem: $problem',
    );

  }


  Widget buildMap() {

    if (loadingLocation) {

      return Container(
        color: Colors.grey.shade200,

        child: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }


    if (currentLocation == null) {

      return Container(
        color: Colors.grey.shade200,

        child: Center(
          child: Column(
            mainAxisAlignment:
                MainAxisAlignment.center,

            children: [

              const Icon(
                Icons.location_off,
                size: 45,
                color: Colors.grey,
              ),

              const SizedBox(height: 10),

              const Text(
                'Location unavailable',
              ),

              const SizedBox(height: 10),

              ElevatedButton(
                onPressed: getLocation,

                child: const Text(
                  'Try Again',
                ),
              ),
            ],
          ),
        ),
      );
    }


    return GoogleMap(

      initialCameraPosition:
          CameraPosition(
        target: currentLocation!,
        zoom: 16,
      ),

      myLocationEnabled: true,

      myLocationButtonEnabled: true,

      zoomControlsEnabled: false,

      compassEnabled: true,

      mapToolbarEnabled: false,
      zoomGesturesEnabled: true,
    scrollGesturesEnabled: true,
    rotateGesturesEnabled: true,
    tiltGesturesEnabled: true,

      onMapCreated: (GoogleMapController controller) {

        mapController = controller;
      controller.animateCamera(
        CameraUpdate.newLatLngZoom(
          currentLocation!,
          16,
        ),
      );
    },

      markers: {

        Marker(
          markerId:
              const MarkerId('user_location'),

          position:
              currentLocation!,

          infoWindow:
              const InfoWindow(
            title: 'You Location',
          ),
        ),
      },
    );
  }





  Widget buildRequests() {

    return Padding(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 15,
      ),

      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [

          const Divider(),

          Row(
            children: [

              const Text(
                'My Requests',

                style: TextStyle(
                  fontSize: 18,
                  fontWeight:
                      FontWeight.bold,
                ),
              ),

              const Spacer(),

              TextButton(
                onPressed: widget.onViewAllRequests,

                child: Text(
                  'View All',

                  style: TextStyle(
                    color: primaryRed,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 5),

          if (requests.isEmpty)

            const SizedBox(
              height: 70,

              child: Center(
                child: Text(
                  'You have no active requests',
                  style: TextStyle(
                    color: Colors.black54,
                  ),
                ),
              ),
            )

          else

            Column(
              children:
                  requests.map(
                (request) {

                  return ListTile(
                    leading:
                        const CircleAvatar(
                      child: Icon(
                        Icons.build,
                      ),
                    ),

                    title: Text(
                      request['problem'],
                    ),

                    subtitle:
                        Text(
                      request['status'],
                    ),
                  );
                },
              ).toList(),
            ),
        ],
      ),
    );
  }
  @override
  Widget build(BuildContext context) {

    final size =
        MediaQuery.of(context).size;

    return Scaffold(

      appBar: AppBar(

        backgroundColor:
            primaryRed,

        iconTheme:
            const IconThemeData(
          color: Colors.white,
        ),
        title:
            Text(
          'MechGo',

          style: GoogleFonts.caveat(
            color:
                Colors.white,
            fontSize: size.height*0.05,
            fontWeight:
                FontWeight.bold,
          ),
        ),

        actions: [

          IconButton(

            onPressed: () {
              Navigator.push(context, 
              MaterialPageRoute(builder: (context)=>UserNotification()));
            },

            icon:
                const Icon(
              Icons.notifications_none,
              color:
                  Colors.white,
            ),
          ),
        ],
      ),


      body: SingleChildScrollView(

        child: Column(

          children: [


            SizedBox(
              height:
                  size.height * 0.38,

              width:
                  double.infinity,

              child:
                  buildMap(),
            ),


            const SizedBox(
              height: 15,
            ),

            Padding(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 15,
      ),

      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [

          Text(
            'Quick Services',

            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Theme.of(context)
        .textTheme
        .bodyLarge
        ?.color,
            ),
          ),

          const SizedBox(height: 15),

GridView.builder(
  shrinkWrap: true,

  physics: const NeverScrollableScrollPhysics(),

  itemCount: services.length + 1,

  gridDelegate:
      const SliverGridDelegateWithFixedCrossAxisCount(
    crossAxisCount: 4,
    crossAxisSpacing: 8,
    mainAxisSpacing: 17,
    childAspectRatio: 0.95,
  ),

  itemBuilder: (context, index) {

    if (index == services.length) {
      return GestureDetector(
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (context)=>RequestIssue()));
        },

        child: Container(
          width: size.width*0.7,
          height: size.height * 0.03,

          decoration: BoxDecoration(
            color: primaryRed,
            borderRadius: BorderRadius.circular(12),

            boxShadow: const [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 5,
                offset: Offset(0, 2),
              ),
            ],
          ),

          child: Center(
            child: Column(
              children: [
                SizedBox(height: size.height*0.01,),
                Icon(Icons.add_circle_outline_outlined, 
                color: Colors.white, size: 25,),
                Text(
                  'Request Help',
                  textAlign: TextAlign.center,
                
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }


    final service = services[index];

    return GestureDetector(
      onTap: () {
        selectService(service);
      },

      child: Column(
        children: [

          Container(
            width: 52,
            height: 52,

            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,

              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 5,
                  offset: Offset(0, 2),
                ),
              ],
            ),

            child: Icon(
              service['icon'],
              color: primaryRed,
              size: 28,
            ),
          ),

          const SizedBox(height: 6),

          Text(
            service['title'],

            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 11,
            ),

            textAlign: TextAlign.center,
          ),

          Text(
            service['subtitle'],

            style:TextStyle(
              color: Theme.of(context)
    .textTheme
    .bodyMedium
    ?.color
    ?.withOpacity(0.65),
              fontSize: 10,
            ),

            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  },
),
    
            buildRequests(),


            const SizedBox(
              height: 20,
            ),
          ],
        ),
      ),
          ]
    )
      )
      );
  }
}