import 'package:flutter/material.dart';
import 'package:mobile/app/theme.dart';
import 'package:mobile/features/menu/widgets/cars_card.dart';
import 'package:mobile/features/menu/widgets/executors_card.dart';
import 'package:mobile/features/menu/widgets/loyalty_program_card.dart';
import 'package:mobile/features/menu/widgets/problems_card.dart';

class MenuScreen extends StatelessWidget {
  const MenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: const [
              ExecutorsCard(),
              SizedBox(height: 16),
              CarsCard(),
              SizedBox(height: 16),
              LoyaltyProgramCard(),
              SizedBox(height: 16),
              ProblemsCard(),
            ],
          ),
        ),
      ),
    );
  }
}
