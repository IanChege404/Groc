import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class DontHaveAccountRow extends StatelessWidget {
  const DontHaveAccountRow({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text('Don\'t Have Account?'),
        TextButton(
          onPressed: () => context.push('/signup'),
          child: const Text('Sign Up'),
        ),
      ],
    );
  }
}
