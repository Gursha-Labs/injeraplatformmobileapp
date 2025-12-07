// widgets/loading_shimmer.dart
import 'package:flutter/material.dart';

class LoadingShimmer extends StatelessWidget {
  const LoadingShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: 3,
      itemBuilder: (context, index) {
        return Container(
          height: MediaQuery.of(context).size.height,
          color: Colors.grey.shade900,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: Container(color: Colors.grey.shade800)),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 200,
                      height: 20,
                      color: Colors.grey.shade700,
                      margin: const EdgeInsets.only(bottom: 8),
                    ),
                    Container(
                      width: 150,
                      height: 16,
                      color: Colors.grey.shade700,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
