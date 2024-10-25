// import 'package:enkryptia/data/database_helper.dart';
// import 'package:flutter/material.dart';

// class LocationHistory extends StatefulWidget {
//   const LocationHistory({super.key});

//   @override
//   State<LocationHistory> createState() => _LocationHistoryState();
// }

// class _LocationHistoryState extends State<LocationHistory> {
//   late Future<List<Map<String, dynamic>>> _locationHistory;

//   @override
//   void initState() {
//     super.initState();
//     _locationHistory = DatabaseHelper().getLocationHistory();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Location History'),
//       ),
//       body: FutureBuilder<List<Map<String, dynamic>>>(
//         future: _locationHistory,
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return const Center(child: CircularProgressIndicator());
//           } else if (snapshot.hasError) {
//             return Center(child: Text('Error: ${snapshot.error}'));
//           } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
//             return const Center(child: Text('No location history found.'));
//           } else {
//             final locationHistory = snapshot.data!;
//             return ListView.builder(
//               itemCount: locationHistory.length,
//               itemBuilder: (context, index) {
//                 final location = locationHistory[index];
//                 return ListTile(
//                   leading: Text("${index + 1}"),
//                   title: Text('Timestamp: ${location['datetime']}'),
//                   subtitle: Text('Latitude: ${location['lat']}, Longitude: ${location['long']}, Synced: ${location['isSynced'] == 1 ? 'Yes' : 'No'}'),
//                   trailing: Icon(
//                     location['isSynced'] == 1 ? Icons.check_circle : Icons.error,
//                     color: location['isSynced'] == 1 ? Colors.green : Colors.red,
//                   ),
//                 );
//               },
//             );
//           }
//         },
//       ),
//     );
//   }
// }

import 'package:enkryptia/data/database_helper.dart';
import 'package:flutter/material.dart';

class LocationHistory extends StatefulWidget {
  const LocationHistory({super.key});

  @override
  State<LocationHistory> createState() => _LocationHistoryState();
}

class _LocationHistoryState extends State<LocationHistory> {
  late Future<List<Map<String, dynamic>>> _locationHistory;

  @override
  void initState() {
    super.initState();
    _locationHistory = DatabaseHelper().getLocationHistory();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Location History'),
        backgroundColor: Colors.pinkAccent,
        elevation: 0,
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _locationHistory,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No location history found.'));
          } else {
            final locationHistory = snapshot.data!;
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: ListView.builder(
                itemCount: locationHistory.length,
                itemBuilder: (context, index) {
                  final location = locationHistory[index];
                  return Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    elevation: 5,
                    margin: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Location ${index + 1}",
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.pinkAccent,
                                ),
                              ),
                              Icon(
                                location['isSynced'] == 1 ? Icons.check_circle : Icons.error,
                                color: location['isSynced'] == 1 ? Colors.green : Colors.red,
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(Icons.access_time, color: Colors.grey),
                              const SizedBox(width: 8),
                              Flexible(
                                child: Text(
                                  'Timestamp: ${location['datetime']}',
                                  style: const TextStyle(color: Colors.black54),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(Icons.location_pin, color: Colors.grey),
                              const SizedBox(width: 8),
                              Flexible(
                                child: Text(
                                  'Latitude: ${location['lat']}, Longitude: ${location['long']}',
                                  style: const TextStyle(color: Colors.black54),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(Icons.sync, color: Colors.grey),
                              const SizedBox(width: 8),
                              Text(
                                'Synced: ${location['isSynced'] == 1 ? 'Yes' : 'No'}',
                                style: const TextStyle(color: Colors.black54),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            );
          }
        },
      ),
    );
  }
}