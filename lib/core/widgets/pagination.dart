import 'package:flutter/material.dart';

class Pagination extends StatelessWidget {
  final int page;
  final int total;
  final ValueChanged<int>? onPage;

  const Pagination({super.key, this.page = 1, this.total = 1, this.onPage});

  @override
  Widget build(BuildContext context) {
    return Row(children: [Text('$page / $total')]);
  }
}
