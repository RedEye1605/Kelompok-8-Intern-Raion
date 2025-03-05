import 'package:flutter/material.dart';
import '../../data/models/home_action.dart';
import './action_button.dart';

class QuickActionsWidget extends StatelessWidget {
  final List<HomeActionModel> actions;
  final Size size;

  const QuickActionsWidget({
    super.key,
    required this.actions,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        SizedBox(height: size.height * 0.02),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: size.width > 600 ? 4 : 2,
            crossAxisSpacing: size.width * 0.04,
            mainAxisSpacing: size.width * 0.04,
            childAspectRatio: 1.5,
          ),
          itemCount: actions.length,
          itemBuilder: (context, index) {
            final action = actions[index];
            return ActionButtonWidget(action: action);
          },
        ),
      ],
    );
  }
}