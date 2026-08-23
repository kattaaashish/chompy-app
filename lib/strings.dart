// Chompy v0 — user-facing copy, verbatim from the design.
//
// Every string the child or parent sees lives here. Nothing inline in widgets.
// If you localise later (Hindi is plausible for this market), these become the
// English ARB entries — keep the keys.
//
// Two rules the copy follows and must keep following:
//   1. Grade-2 reading level or below in Dhruv's views. Short sentences, words
//      a 7-year-old says out loud.
//   2. No numbers in Dhruv's experience — no calories, macros, grams, scores or
//      percentages. Quantities in real-world units ("2 pieces", "1 bowl") are
//      fine; those are things, not measurements.

class ChompyStrings {
  // ── Welcome ──
  static const welcomeTitle = "Hi!\nI'm Chompy";
  static const welcomeBody = 'I help you eat all your food colours. Let\u2019s start.';
  static const welcomeCta = 'Get started';

  // ── Phone number ──
  static const phoneStep = 'Step 1 of 3';
  static const phoneTitle = 'Your phone number';
  static const phoneBody =
      'A grown-up\u2019s number is best \u2014 we send a 6-digit code to it.';
  static const phonePlaceholder = '98765 43210';
  static const phoneHintEmpty = '10 numbers, no spaces needed.';
  static String phoneHintRemaining(int n) =>
      '$n more ${n == 1 ? 'number' : 'numbers'} to go';
  static const phoneHintValid = 'Looks good!';
  static const phoneCta = 'Send my code';

  // ── Sending the code ──
  static const sendingTitle = 'Sending your code\u2026';
  static String sendingBody(String phone) => 'To +91 $phone. This takes a few seconds.';

  // ── OTP ──
  static const otpStep = 'Step 2 of 3';
  static const otpTitle = 'Type the code';
  static String otpBody(String phone) =>
      'We sent 6 numbers to +91 $phone. The code works for 5 minutes.';
  static const otpCta = 'Check my code';
  static const otpChangeNumber = 'Change phone number \u2192';

  // Wrong and expired are different problems and never share a message.
  static const otpWrongTitle = 'Those numbers don\u2019t match';
  static const otpWrongBody =
      'Check the message again and type the 6 numbers. If you can\u2019t find it, '
      'start again with your phone number.';
  static const otpExpiredTitle = 'That code got too old';
  static const otpExpiredBody =
      'Codes only work for 5 minutes. Put your phone number in again to get a fresh one.';

  static const verifyingTitle = 'Checking your code\u2026';
  static const verifyingBody = 'Hang on one moment.';

  // ── Profile (parent-filled) ──
  static const profileStep = 'Step 3 of 3 \u00b7 for a grown-up';
  static const profileTitle = 'About Dhruv';
  static const labelName = 'Name';
  static const labelDob = 'Date of birth';
  static const labelGender = 'Gender';
  static const labelHeight = 'Height';
  static const labelWeight = 'Weight';
  static const genders = ['Boy', 'Girl', 'Other'];
  static const profileHelper =
      'Height and weight help set goals. A grown-up can update them any time as Dhruv grows.';
  static const profileCtaIncomplete = 'Add name and birthday';
  static const profileCtaReady = 'Start using Chompy';

  // ── Home ──
  static String greeting(String name) => 'Hi ${name.isEmpty ? 'Dhruv' : name}!';
  static String homeStatus(int meals) => meals >= 3
      ? 'Three meals logged. You are on a roll.'
      : 'You logged $meals meals today. What was next?';
  static const homeCta = 'Log a meal';
  static const homeProgress = 'My progress';
  static const homeFoodGroups = "Today's food groups";
  static const homeMeals = 'Meals today';
  static const mealNames = ['Breakfast', 'Lunch', 'Snack', 'Dinner'];
  static const mealEmpty = 'Nothing yet';

  // First-run tip — this is the entire help system. No help centre.
  static const tipLabel = 'Tip';
  static const tipBody =
      'You can take a photo of your plate, type what you ate, or just say it out loud. '
      'Chompy figures out the rest.';
  static const tipDismiss = 'Got it';

  // ── Progress ──
  static const progressTitle = 'My progress';
  static const spanToday = 'Today';
  static const spanWeek = 'This week';
  static const progressGroupsToday = 'Food groups today';
  static const progressGoals = 'My goals';
  static const goals = [
    'Eat a vegetable at lunch',
    'Try one new food this week',
    'Log all three meals today',
  ];
  static const weekPeekLabel = 'This week \u2014 a peek';
  static const weekPeekExplainer =
      'Each block is one food group you ate that day. Taller is more colours on your plate.';
  static const weekBestTitle = 'Best day: Wednesday';
  static const weekBestBody = 'You ate all five groups. Chompy did a happy dance.';

  // Food groups — always shown as a word, never colour alone.
  static const foodGroups = ['Vegetable', 'Grain', 'Protein', 'Dairy', 'Fruit'];

  // ── Entry modes ──
  static const modeTitle = 'What did you eat?';
  static const modePhoto = 'Take a photo';
  static const modePhotoHint = 'Point at your plate. Fastest way.';
  static const modeType = 'Type it';
  static const modeTypeHint = 'Write what you ate, or tap a food you like.';
  static const modeSpeak = 'Say it out loud';
  static const modeSpeakHint = 'Just talk. Chompy listens.';
  static const modeFooter =
      'Any way you pick, you can fix it later. Nothing is saved until you say so.';

  // ── Camera ──
  static const cameraPlaceholder = '[ camera preview ]\npoint at your plate';
  static const cameraCancel = 'Cancel';
  static const cameraShutter = 'Snap';
  static const cancelledTitle = 'No photo yet';
  static const cancelledBody =
      'That\u2019s okay. You can try the camera again, or tell Chompy another way.';
  static const cancelledRetry = 'Take a photo';
  static const cancelledOther = 'Pick another way';

  // ── Typed entry ──
  static const typeTitle = 'Type your food';
  static const typePlaceholder = '2 roti, dal, some cucumber';
  static const likedFoodsLabel = 'Foods you like';
  static const typeCta = 'See what Chompy finds';

  // ── Speech entry ──
  static const speakTitle = 'I\u2019m listening\u2026';
  static const speakBody = 'Say what you ate, like "two roti and dal".';
  static const speakDone = 'Done talking';
  static const speakStop = 'Stop';

  // ── Detecting ──
  static const detectingTitle = 'Chompy is looking\u2026';
  // Fallibility announced before results, not after a mistake.
  static const detectingBody = 'Finding the food. You can fix anything I get wrong.';

  // ── Review & edit ──
  static const reviewTitle = 'Is this right?';
  static const reviewBody = 'Fix anything, then tell me it\u2019s right.';
  static const reviewTitleEmpty = 'Let\u2019s add it together';
  static const reviewBodyEmpty = 'Chompy needs a little help this time.';
  static const reviewWhen = 'When was it?';
  static const reviewFound = 'Chompy found';
  static const reviewYourFood = 'Your food';
  static const reviewAddMissed = 'Add something I missed';
  static const reviewCta = 'Yes, that\u2019s right';
  static const reviewCtaEmpty = 'Add one food first';
  static const reviewHelper = 'A grown-up can change this later.';
  static const reviewHelperEmpty = 'Tap a food above to switch this on.';
  static const categories = ['Breakfast', 'Lunch', 'Dinner', 'Snacks'];

  // Empty detection — Chompy's limitation, never the child's mistake.
  static const emptyDetectTitle = 'I didn\u2019t spot anything';
  static const emptyDetectBody =
      'No problem \u2014 tap a food below to add it yourself, and I\u2019ll learn.';

  // ── Saving / result ──
  static const savingTitle = 'Saving your meal\u2026';
  static const savingBody = 'Keeping it safe.';
  static const factKicker = 'Chompy fact';
  static const factNext = 'One more fact \u2192';
  static const factFinish = 'Finish \u2192';
  static const savedTitle = 'All done!';
  static String savedBody(String category, int count) =>
      'Chompy saved your ${category.toLowerCase()}. $count foods on the list.';
  static const savedNewToday = 'New today';
  static const savedCta = 'Back home';

  static const failedTitle = 'It didn\u2019t save';
  static const failedBody =
      'The internet went wobbly. Your food is still here \u2014 nothing is lost.';
  static const failedRetry = 'Try again';
  static const failedBack = 'Back to my food';

  // ── Fun facts ── one per food, kid-level, never a number.
  static const facts = <String, String>{
    'Roti': 'Roti is made from wheat that grew in a field. It gives your legs energy for running.',
    'Dal': 'Dal is tiny seeds called lentils. They help your body build strong muscles.',
    'Cucumber': 'A cucumber is mostly water. Crunching one is like drinking a little glass.',
    'Banana': 'Bananas grow pointing up at the sun, not hanging down.',
    'Curd': 'Curd is full of friendly tiny helpers that look after your tummy.',
    'Paneer': 'Paneer starts as milk and turns soft and squishy. It helps your bones.',
    'Idli': 'Idli is steamed, not fried. The little holes are bubbles of air.',
    'Carrot': 'Carrots are orange because of something that helps your eyes work in the dark.',
  };
  static const factFallback = 'Every food does a different job in your body.';

  // ── Sample data used in the prototype ──
  // Liked foods (parent-managed in a later release).
  static const likedFoods = ['Banana', 'Curd', 'Paneer', 'Idli', 'Carrot'];
  // Quantity units — real-world words only. Never grams.
  static const units = ['piece', 'pieces', 'bowl', 'bowls', 'slices', 'sticks'];
}
