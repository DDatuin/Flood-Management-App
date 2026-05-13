// import 'package:floodmonitoring/pages/widgets/map/map_small_card.dart';
// import 'package:floodmonitoring/pages/widgets/map/map_vehicle_selection.dart';
// import 'package:flutter/material.dart';

// class VehicleInfoSheet extends StatelessWidget {
//   final ScrollController scrollController;
//   final bool showMainSheet;
//   final String selectedVehicle;
//   final String iconCode;
//   final String currentTime;
//   final String temperature;
//   final String weatherDescription;

//   final Function(String vehicle) onVehicleSelected;
//   final VoidCallback onGoToUser;

//   const VehicleInfoSheet({
//     super.key,
//     required this.scrollController,
//     required this.showMainSheet,
//     required this.selectedVehicle,
//     required this.iconCode,
//     required this.currentTime,
//     required this.temperature,
//     required this.weatherDescription,
//     required this.onVehicleSelected,
//     required this.onGoToUser,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return DraggableScrollableSheet(
//       initialChildSize: 0.45,
//       minChildSize: 0.25,
//       maxChildSize: 0.95,
//       snap: true,
//       snapSizes: const [0.45, 0.95],
//       builder: (context, scrollController) {
//         return GestureDetector(
//           onVerticalDragUpdate: (details) {
//             if (selectedVehicle.isNotEmpty) {
//               scrollController.jumpTo(
//                 scrollController.offset - details.delta.dy,
//               );
//             }
//           },
//           child: NotificationListener<DraggableScrollableNotification>(
//             onNotification: (notification) {
//               if (selectedVehicle.isNotEmpty && notification.extent <= 0.25) {
//                 setState(() => showMainSheet = false);
//               }
//               return true;
//             },
//             child: Container(
//               decoration: BoxDecoration(
//                 color: Colors.white, // clean white background
//                 borderRadius: const BorderRadius.vertical(
//                   top: Radius.circular(24),
//                 ),
//                 boxShadow: [
//                   BoxShadow(
//                     color: Colors.black26,
//                     blurRadius: 12,
//                     offset: const Offset(0, -3),
//                   ),
//                 ],
//               ),
//               child: Column(
//                 children: [
//                   const SizedBox(height: 12),
//                   Center(
//                     child: Container(
//                       width: 50,
//                       height: 6,
//                       decoration: BoxDecoration(
//                         color: Colors.grey[400],
//                         borderRadius: BorderRadius.circular(12),
//                       ),
//                     ),
//                   ),
//                   const SizedBox(height: 12),

//                   Expanded(
//                     child: SingleChildScrollView(
//                       controller: scrollController,
//                       physics: const ClampingScrollPhysics(),
//                       padding: const EdgeInsets.symmetric(
//                         horizontal: 20,
//                         vertical: 0,
//                       ),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           // HEADER
//                           Row(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Icon(
//                                 Icons.directions_car_filled,
//                                 size: 34,
//                                 color: Colors.blueAccent,
//                               ),
//                               const SizedBox(width: 12),
//                               Expanded(
//                                 child: Column(
//                                   crossAxisAlignment: CrossAxisAlignment.start,
//                                   children: const [
//                                     Text(
//                                       "Pick a Vehicle",
//                                       style: TextStyle(
//                                         fontFamily: 'AvenirNext',
//                                         fontSize: 20,
//                                         fontWeight: FontWeight.w700, // Bold
//                                         color: Colors.black87,
//                                       ),
//                                     ),
//                                     SizedBox(height: 2),
//                                     Text(
//                                       "Choose from the options below",
//                                       style: TextStyle(
//                                         fontFamily: 'AvenirNext',
//                                         fontSize: 14,
//                                         fontWeight: FontWeight.w400, // Regular
//                                         color: Colors.black54,
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                             ],
//                           ),
//                           const SizedBox(height: 18),

//                           // VEHICLE SELECTION
//                           SingleChildScrollView(
//                             scrollDirection: Axis.horizontal,
//                             physics: const BouncingScrollPhysics(),
//                             child: Row(
//                               children: [
//                                 vehicleSelection(
//                                   name: 'Bicycle',
//                                   imagePath:
//                                       'assets/images/vehicle/bicycle.png',
//                                   highlightColor: Colors.blueAccent,
//                                   onTap: () {
//                                     setState(() {
//                                       tempSelectedVehicle = selectedVehicle;
//                                       selectedVehicle = 'Bicycle';
//                                     });
//                                     VehicleInfoPopup.show(
//                                       context,
//                                       "Bicycle",
//                                       onConfirm: (v) {
//                                         setState(() {
//                                           selectedVehicle = 'Bicycle';
//                                           showMainSheet = false;
//                                           showDirectionSheet = true;
//                                           _goToUser();
//                                         });
//                                       },
//                                       onCancel: (v) {
//                                         setState(() {
//                                           selectedVehicle = tempSelectedVehicle;
//                                         });
//                                       },
//                                     );
//                                   },
//                                 ),
//                                 const SizedBox(width: 16),
//                                 vehicleSelection(
//                                   name: 'Motorcycle',
//                                   imagePath:
//                                       'assets/images/vehicle/motorcycle.png',
//                                   highlightColor: Colors.blueAccent,
//                                   onTap: () {
//                                     setState(() {
//                                       tempSelectedVehicle = selectedVehicle;
//                                       selectedVehicle = 'Motorcycle';
//                                     });
//                                     VehicleInfoPopup.show(
//                                       context,
//                                       "Motorcycle",
//                                       onConfirm: (v) {
//                                         setState(() {
//                                           selectedVehicle = 'Motorcycle';
//                                           showMainSheet = false;
//                                           showDirectionSheet = true;
//                                           _goToUser();
//                                         });
//                                       },
//                                       onCancel: (v) {
//                                         setState(() {
//                                           selectedVehicle = tempSelectedVehicle;
//                                         });
//                                       },
//                                     );
//                                   },
//                                 ),
//                                 const SizedBox(width: 16),
//                                 vehicleSelection(
//                                   name: 'Car',
//                                   imagePath: 'assets/images/vehicle/car.png',
//                                   highlightColor: Colors.blueAccent,
//                                   onTap: () {
//                                     setState(() {
//                                       tempSelectedVehicle = selectedVehicle;
//                                       selectedVehicle = 'Car';
//                                     });
//                                     VehicleInfoPopup.show(
//                                       context,
//                                       "Car",
//                                       onConfirm: (v) {
//                                         setState(() {
//                                           selectedVehicle = 'Car';
//                                           showMainSheet = false;
//                                           showDirectionSheet = true;
//                                           _goToUser();
//                                         });
//                                       },
//                                       onCancel: (v) {
//                                         setState(() {
//                                           selectedVehicle = tempSelectedVehicle;
//                                         });
//                                       },
//                                     );
//                                   },
//                                 ),
//                                 const SizedBox(width: 16),
//                                 vehicleSelection(
//                                   name: 'Truck',
//                                   imagePath: 'assets/images/vehicle/truck.png',
//                                   highlightColor: Colors.blueAccent,
//                                   onTap: () {
//                                     setState(() {
//                                       tempSelectedVehicle = selectedVehicle;
//                                       selectedVehicle = 'Truck';
//                                     });
//                                     VehicleInfoPopup.show(
//                                       context,
//                                       "Truck",
//                                       onConfirm: (v) {
//                                         setState(() {
//                                           selectedVehicle = 'Truck';
//                                           showMainSheet = false;
//                                           showDirectionSheet = true;
//                                           _goToUser();
//                                         });
//                                       },
//                                       onCancel: (v) {
//                                         setState(() {
//                                           selectedVehicle = tempSelectedVehicle;
//                                         });
//                                       },
//                                     );
//                                   },
//                                 ),
//                               ],
//                             ),
//                           ),
//                           const SizedBox(height: 22),

//                           // RELATED SECTION
//                           const Text(
//                             'Related',
//                             style: TextStyle(
//                               fontFamily: 'AvenirNext',
//                               fontSize: 20,
//                               fontWeight: FontWeight.w600, // Demi
//                               color: Colors.black87,
//                             ),
//                           ),
//                           const SizedBox(height: 16),

//                           // WEATHER CARD
//                           Container(
//                             padding: const EdgeInsets.all(16),
//                             decoration: BoxDecoration(
//                               color: Colors.blue[50],
//                               borderRadius: BorderRadius.circular(16),
//                               boxShadow: [
//                                 BoxShadow(
//                                   color: Colors.black12,
//                                   blurRadius: 6,
//                                   offset: const Offset(0, 2),
//                                 ),
//                               ],
//                             ),
//                             child: Row(
//                               mainAxisAlignment: MainAxisAlignment.spaceAround,
//                               children: [
//                                 Column(
//                                   children: [
//                                     if (iconCode.isNotEmpty)
//                                       Image.asset(
//                                         'assets/images/weather/$iconCode.png',
//                                         width: 90,
//                                         height: 90,
//                                         fit: BoxFit.contain,
//                                       )
//                                     else
//                                       SizedBox(
//                                         width: 90,
//                                         height: 90,
//                                         child: Center(
//                                           child: CircularProgressIndicator(
//                                             strokeWidth: 2,
//                                             color: Colors.blueAccent,
//                                           ),
//                                         ),
//                                       ),
//                                   ],
//                                 ),
//                                 Column(
//                                   children: [
//                                     Text(
//                                       currentTime.isNotEmpty
//                                           ? currentTime
//                                           : '--:--',
//                                       style: const TextStyle(
//                                         fontFamily: 'AvenirNext',
//                                         fontSize: 15,
//                                         fontWeight: FontWeight.w600,
//                                       ),
//                                     ),
//                                     Text(
//                                       temperature != null
//                                           ? '${temperature}°C'
//                                           : '--°C',
//                                       style: const TextStyle(
//                                         fontFamily: 'AvenirNext',
//                                         color: Colors.blueAccent,
//                                         fontSize: 30,
//                                         fontWeight: FontWeight.w800,
//                                       ),
//                                     ),
//                                     Text(
//                                       weatherDescription.isNotEmpty
//                                           ? weatherDescription
//                                           : 'Loading...',
//                                       style: const TextStyle(
//                                         fontFamily: 'AvenirNext',
//                                         fontSize: 15,
//                                         fontWeight: FontWeight.w500,
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               ],
//                             ),
//                           ),
//                           const SizedBox(height: 16),

//                           // BOTTOM CARDS
//                           Row(
//                             children: [
//                               // LEFT BIG CARD
//                               Expanded(
//                                 flex: 4,
//                                 child: GestureDetector(
//                                   onTap: () {
//                                     Navigator.pushNamed(
//                                       context,
//                                       '/recent-alert',
//                                     );
//                                   },
//                                   child: Container(
//                                     height: 120,
//                                     padding: const EdgeInsets.all(12),
//                                     decoration: BoxDecoration(
//                                       color: Colors.blueAccent,
//                                       borderRadius: BorderRadius.circular(16),
//                                       boxShadow: [
//                                         BoxShadow(
//                                           color: Colors.black12,
//                                           blurRadius: 6,
//                                           offset: const Offset(0, 3),
//                                         ),
//                                       ],
//                                     ),
//                                     child: Column(
//                                       crossAxisAlignment:
//                                           CrossAxisAlignment.center,
//                                       children: [
//                                         Expanded(
//                                           child: Image.asset(
//                                             'assets/images/3d-images/bell-3d.png',
//                                             fit: BoxFit.contain,
//                                           ),
//                                         ),
//                                         const Text(
//                                           "Recent Alerts",
//                                           textAlign: TextAlign.center,
//                                           style: TextStyle(
//                                             fontFamily: 'AvenirNext',
//                                             color: Colors.white,
//                                             fontSize: 18,
//                                             fontWeight: FontWeight.w600,
//                                           ),
//                                         ),
//                                       ],
//                                     ),
//                                   ),
//                                 ),
//                               ),
//                               const SizedBox(width: 12),

//                               // RIGHT COLUMN
//                               Expanded(
//                                 flex: 5,
//                                 child: Column(
//                                   children: [
//                                     GestureDetector(
//                                       onTap: () {
//                                         Navigator.pushNamed(
//                                           context,
//                                           '/flood-tips',
//                                         );
//                                       },
//                                       child: smallCard(
//                                         color: Colors.lightBlueAccent.shade100,
//                                         image:
//                                             'assets/images/3d-images/rescue-3d.png',
//                                         text: "Flood Tips",
//                                       ),
//                                     ),
//                                     const SizedBox(height: 12),
//                                     GestureDetector(
//                                       onTap: () {
//                                         Navigator.pushNamed(
//                                           context,
//                                           '/rescue-call',
//                                         );
//                                       },
//                                       child: smallCard(
//                                         color: Colors.blueAccent.shade100,
//                                         image:
//                                             'assets/images/3d-images/help-3d.png',
//                                         text: "Rescue Call",
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                             ],
//                           ),
//                           const SizedBox(height: 16),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         );
//       },
//     );
//   }
// }
