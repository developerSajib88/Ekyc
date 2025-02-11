# face_liveness_detection

A real-time facial verification feature using Google ML Kit for liveliness detection. It ensures user interaction through smiling, blinking, and head movements. Features include face detection, dynamic feedback, a countdown timer, and customizable UI—ideal for secure authentication and anti-spoofisng verification. 🚀

## Features

- **Detects user presence** with a face detection engine.
- **Displays dynamic UI feedback** for each rule.
- **Animated transitions** when detecting face presence.
- **Handles countdown timers** before validation.
- **Efficient state management** with rule tracking.

## Usage

To use this widget, add it inside a Flutter screen:

![image](https://github.com/user-attachments/assets/eb0ca715-27f8-4aa5-9e23-fd11825e8960)
![image](https://github.com/user-attachments/assets/5f6729b3-8ec8-4d2a-b728-bcbb299379ae)

```dart
 import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class FaceVerificationWidget extends StatefulWidget {
  @override
  _FaceVerificationWidgetState createState() => _FaceVerificationWidgetState();
}

class _FaceVerificationWidgetState extends State<FaceVerificationWidget> {
  final List<String> _completedRuleset = [];

  @override
  Widget build(BuildContext context) {
    return FaceDetectorView(
      onSuccessValidation: (validated) {},
      onChildren: ({required countdown, required state, required hasFace}) {
        return [
          const SizedBox(height: 20),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('assets/face_verification_icon.png', height: 30, width: 30),
              const SizedBox(width: 10),
              Flexible(
                child: AnimatedSize(
                  duration: const Duration(milliseconds: 150),
                  child: Text(
                    hasFace ? 'User face found' : 'User face not found',
                    style: _textStyle,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 30),
          Text(
            _rulesetHints[state] ?? 'Please follow instructions',
            style: _textStyle.copyWith(fontSize: 20, fontWeight: FontWeight.w600),
          ),
          if (countdown > 0)
            Text.rich(
              TextSpan(
                children: [
                  const TextSpan(text: 'IN\n'),
                  TextSpan(
                    text: countdown.toString(),
                    style: _textStyle.copyWith(fontSize: 22, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              textAlign: TextAlign.center,
              style: _textStyle.copyWith(fontSize: 16),
            )
          else
            const Column(
              children: [
                SizedBox(height: 50),
                CupertinoActivityIndicator(),
              ],
            ),
        ];
      },
      onRulesetCompleted: (ruleset) {
        if (!_completedRuleset.contains(ruleset)) {
          setState(() => _completedRuleset.add(ruleset));
        }
      },
    );
  }
}

/// Text style for UI consistency
const TextStyle _textStyle = TextStyle(
  color: Colors.black,
  fontWeight: FontWeight.w400,
  fontSize: 12,
);

/// Ruleset hints for better performance (eliminating switch-case)
const Map<Rulesets, String> _rulesetHints = {
  Rulesets.smiling: 'Please Smile',
  Rulesets.blink: 'Please Blink',
  Rulesets.tiltUp: 'Please Look Up',
  Rulesets.tiltDown: 'Please Look Down',
  Rulesets.toLeft: 'Please Look Left',
  Rulesets.toRight: 'Please Look Right',
};
```
