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
            return ListView.builder(
              itemCount: locationHistory.length,
              itemBuilder: (context, index) {
                final location = locationHistory[index];
                return ListTile(
                  leading: Text("${index + 1}"),
                  title: Text('Timestamp: ${location['datetime']}'),
                  subtitle: Text('Latitude: ${location['lat']}, Longitude: ${location['long']}, Synced: ${location['isSynced'] == 1 ? 'Yes' : 'No'}'),
                  trailing: Icon(
                    location['isSynced'] == 1 ? Icons.check_circle : Icons.error,
                    color: location['isSynced'] == 1 ? Colors.green : Colors.red,
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}