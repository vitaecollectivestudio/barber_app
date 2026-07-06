import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/service_model.dart';

class ServicesService {

  static Stream<List<ServiceModel>>
      activeServicesStream() {

    return FirebaseFirestore.instance
        .collection('services')
        .snapshots()
        .map((snapshot) {

      final services = snapshot.docs.map((doc) {

        return ServiceModel.fromFirestore(
          doc.id,
          doc.data(),
        );

      }).toList();

      services.sort(
        (a, b) => a.sortOrder.compareTo(b.sortOrder),
      );

      return services;
    });
  }
}