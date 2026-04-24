import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';

class InvoiceListSkeleton extends StatelessWidget {
  const InvoiceListSkeleton({super.key});

  @override
  Widget build(final BuildContext context) {
    return Skeletonizer(
      child: ListView.builder(
        itemCount: 10,
        itemBuilder: (final context, final index) => const ListTile(
          leading: Bone.circle(size: 40),
          title: Bone.text(words: 2),
          subtitle: Bone.text(words: 3),
          trailing: Bone.text(words: 1),
        ),
      ),
    );
  }
}

class InvoiceSummarySkeleton extends StatelessWidget {
  const InvoiceSummarySkeleton({super.key});

  @override
  Widget build(final BuildContext context) {
    return const Skeletonizer(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Bone.text(words: 2),
              Bone.text(words: 1),
            ],
          ),
          SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Bone.text(words: 2),
              Bone.text(words: 1),
            ],
          ),
        ],
      ),
    );
  }
}
