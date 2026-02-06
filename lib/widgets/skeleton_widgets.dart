import 'package:flutter/material.dart';

class SkeletonCard extends StatefulWidget {
  final double height;
  final double? width;

  const SkeletonCard({
    super.key,
    this.height = 100,
    this.width,
  });

  @override
  State<SkeletonCard> createState() => _SkeletonCardState();
}

class _SkeletonCardState extends State<SkeletonCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();
    
    _animation = Tween<double>(begin: 0.3, end: 0.6).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          height: widget.height,
          width: widget.width,
          decoration: BoxDecoration(
            color: Theme.of(context)
                .colorScheme
                .surfaceContainerHighest
                .withOpacity(_animation.value),
            borderRadius: BorderRadius.circular(12),
          ),
        );
      },
    );
  }
}

class SkeletonList extends StatelessWidget {
  final int itemCount;
  final double itemHeight;

  const SkeletonList({
    super.key,
    this.itemCount = 5,
    this.itemHeight = 72,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: itemCount,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        return SkeletonCard(height: itemHeight);
      },
    );
  }
}

class SkeletonStats extends StatelessWidget {
  const SkeletonStats({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: SkeletonCard(height: 120)),
        const SizedBox(width: 16),
        Expanded(child: SkeletonCard(height: 120)),
      ],
    );
  }
}

class SkeletonText extends StatefulWidget {
  final double width;
  final double height;

  const SkeletonText({
    super.key,
    required this.width,
    this.height = 16,
  });

  @override
  State<SkeletonText> createState() => _SkeletonTextState();
}

class _SkeletonTextState extends State<SkeletonText>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();
    
    _animation = Tween<double>(begin: 0.3, end: 0.6).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            color: Theme.of(context)
                .colorScheme
                .surfaceContainerHighest
                .withOpacity(_animation.value),
            borderRadius: BorderRadius.circular(4),
          ),
        );
      },
    );
  }
}

class SkeletonDashboard extends StatelessWidget {
  const SkeletonDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header skeleton
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SkeletonText(width: 120, height: 16),
              const SizedBox(height: 8),
              SkeletonText(width: 200, height: 32),
            ],
          ),
          const SizedBox(height: 24),
          
          // Stats skeleton
          const SkeletonStats(),
          const SizedBox(height: 16),
          SkeletonCard(height: 100, width: double.infinity),
          const SizedBox(height: 32),
          
          // Quick actions skeleton
          SkeletonText(width: 150, height: 24),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: SkeletonCard(height: 100)),
              const SizedBox(width: 16),
              Expanded(child: SkeletonCard(height: 100)),
              const SizedBox(width: 16),
              Expanded(child: SkeletonCard(height: 100)),
            ],
          ),
          const SizedBox(height: 32),
          
          // Recent invoices skeleton
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SkeletonText(width: 150, height: 24),
              SkeletonText(width: 60, height: 20),
            ],
          ),
          const SizedBox(height: 16),
          const SkeletonList(itemCount: 5),
        ],
      ),
    );
  }
}
