import 'package:tsiwa_mahber/core/theme/app_theme.dart';

/// Centralized translation strings for Amharic and English.
class S {
  static bool get _am => LocaleProvider.instance.isAmharic;

  // ── Common ──
  static String get appName => _am ? 'ጽዋ ማህበር' : 'Tsiwa Mahber';
  static String get appSubtitle =>
      _am ? 'ጽዋ ማህበር አስተዳደር' : 'Tsiwa Mahber Management';
  static String get loading => _am ? 'በመጫን ላይ...' : 'Loading...';
  static String get preparingData =>
      _am ? 'መረጃ በመዘጋጀት ላይ...' : 'Preparing data...';
  static String get error => _am ? 'ስህተት' : 'Error';
  static String errorMsg(String e) => _am ? 'ስህተት: $e' : 'Error: $e';
  static String get dataLoadFailed =>
      _am ? 'መረጃ ማግኘት አልተቻለም' : 'Failed to load data';
  static String get saveFailed => _am ? 'ማስቀመጥ አልተቻለም' : 'Failed to save';
  static String get deleteFailed => _am ? 'መሰረዝ አልተቻለም' : 'Failed to delete';
  static String get save => _am ? 'አስቀምጥ' : 'Save';
  static String get create => _am ? 'ፍጠር' : 'Create';
  static String get cancel => _am ? 'ተወው' : 'Cancel';
  static String get delete => _am ? 'ሰርዝ' : 'Delete';
  static String get edit => _am ? 'አስተካክል' : 'Edit';
  static String get add => _am ? 'ጨምር' : 'Add';
  static String get confirm => _am ? 'አረጋግጥ' : 'Confirm';
  static String get retry => _am ? 'እንደገና ሞክር' : 'Retry';
  static String get yes => _am ? 'አዎ' : 'Yes';
  static String get no => _am ? 'አይ' : 'No';
  static String get active => _am ? 'ንቁ' : 'Active';
  static String get total => _am ? 'ጠቅላላ' : 'Total';
  static String get note => _am ? 'ማስታወሻ' : 'Note';
  static String get name => _am ? 'ስም' : 'Name';
  static String get phone => _am ? 'ስልክ' : 'Phone';
  static String get status => _am ? 'ሁኔታ' : 'Status';
  static String get role => _am ? 'ሚና' : 'Role';
  static String get description => _am ? 'መግለጫ' : 'Description';
  static String get today => _am ? 'ዛሬ' : 'Today';
  static String get tomorrow => _am ? 'ነገ' : 'Tomorrow';
  static String get now => _am ? 'አሁን' : 'Now';
  static String get saved => _am ? 'ተቀምጧል' : 'Saved';
  static String get record => _am ? 'መዝግብ' : 'Record';
  static String get services => _am ? 'አገልግሎቶች' : 'Services';

  // ── Auth / Login ──
  static String get email => _am ? 'ኢሜይል' : 'Email';
  static String get password => _am ? 'ይለፍ ቃል' : 'Password';
  static String get signIn => _am ? 'ግባ' : 'Sign In';
  static String get register => _am ? 'ይመዝገቡ' : 'Register';
  static String get signOut => _am ? 'ውጣ ከአካውንት' : 'Sign Out';
  static String get forgotPassword => _am ? 'ይለፍ ቃል ረሱ?' : 'Forgot password?';
  static String get noAccount =>
      _am ? 'አካውንት የለዎትም?' : "Don't have an account?";
  static String get emailRequired => _am ? 'ኢሜይል ያስፈልጋል' : 'Email is required';
  static String get validEmail =>
      _am ? 'ትክክለኛ ኢሜይል ያስገቡ' : 'Enter a valid email';
  static String get passwordRequired =>
      _am ? 'ይለፍ ቃል ያስፈልጋል' : 'Password is required';
  static String get resetEmailSent =>
      _am ? 'ይለፍ ቃል ማስቀየሪያ ወደ ኢሜይልዎ ተልኳል' : 'Password reset email sent';
  static String get enterEmailForReset => _am
      ? 'ኢሜይል ያስገቡ ከዚያ "ይለፍ ቃል ረሱ?" ይጫኑ'
      : 'Enter your email then tap "Forgot password?"';
  static String get accountBlocked =>
      _am ? 'አካውንትዎ ታግዷል' : 'Your account is blocked';
  static String get contactAdmin =>
      _am ? 'አስተዳዳሪን ያነጋግሩ' : 'Contact administrator';
  static String get loadingUser => _am ? 'ተጠቃሚ በመጫን ላይ...' : 'Loading user...';
  static String get exitAccount => _am ? 'ውጣ' : 'Sign Out';

  // ── Register screen ──
  static String get fullName => _am ? 'ሙሉ ስም' : 'Full Name';
  static String get nameRequired => _am ? 'ስም ያስፈልጋል' : 'Name is required';
  static String get fullNameRequired => _am ? 'ሙሉ ስም ያስገቡ' : 'Enter full name';
  static String get confirmPassword =>
      _am ? 'ይለፍ ቃል ያረጋግጡ' : 'Confirm password';
  static String get passwordsNoMatch =>
      _am ? 'ይለፍ ቃል አይመሳሰልም' : 'Passwords do not match';
  static String get haveAccount =>
      _am ? 'አካውንት አለዎት?' : 'Already have an account?';

  // ── Popup Menu ──
  static String get lightTheme => _am ? 'ብሩህ ገጽታ' : 'Light Theme';
  static String get darkTheme => _am ? 'ጨለማ ገጽታ' : 'Dark Theme';
  static String get devSignIn => _am ? 'ገንቢ ግባ' : 'Developer Sign In';
  static String get exitApp => _am ? 'መተግበሪያ ዝጋ' : 'Exit App';

  // ── Area Selection ──
  static String get selectArea => _am ? 'አካባቢ ይምረጡ' : 'Select Area';
  static String get newArea => _am ? 'አዲስ አካባቢ' : 'New Area';
  static String get shortName => _am ? 'አጭር ስም' : 'Short Name';
  static String get address => _am ? 'አድራሻ' : 'Address';
  static String get nameAndShortRequired =>
      _am ? 'ስም እና አጭር ስም ያስፈልጋል' : 'Name and short name are required';

  // ── Area Home ──
  static String get notifications => _am ? 'ማሳወቂያዎች' : 'Notifications';
  static String get users => _am ? 'ተጠቃሚዎች' : 'Users';
  static String get profile => _am ? 'መገለጫ' : 'Profile';
  static String get tsiwaGroups => _am ? 'ፅዋ ማህበሮች' : 'Tsiwa Groups';
  static String get manageTsiwaGroups =>
      _am ? 'ፅዋ ማህበሮችን ያስተዳድሩ' : 'Manage Tsiwa groups';
  static String get leaders => _am ? 'አመራሮች' : 'Leaders';
  static String get manageLeaders => _am ? 'አመራሮችን ያስተዳድሩ' : 'Manage leaders';
  static String get edir => _am ? 'እድር' : 'Edir';
  static String get manageEdir => _am ? 'እድርን ያስተዳድሩ' : 'Manage Edir';
  static String get announcements => _am ? 'ማስታወቂያዎች' : 'Announcements';
  static String get viewAnnouncements =>
      _am ? 'ማስታወቂያዎችን ያየ' : 'View announcements';
  static String get telegram => _am ? 'ቴሌግራም' : 'Telegram';
  static String get telegramBot =>
      _am ? 'ቴሌግራም ባት ማገናኛ' : 'Telegram bot connection';
  static String get csvExportMenu => _am ? 'CSV ላክ' : 'CSV Export';
  static String get csvExportSub =>
      _am ? 'መረጃ ወደ CSV ፋይል ላክ' : 'Export data to CSV';
  static String get csvImportMenu => _am ? 'CSV አስገባ' : 'CSV Import';
  static String get csvImportSub =>
      _am ? 'CSV ፋይል ወደ ውስጥ አስገባ' : 'Import CSV file';
  static String get reports => _am ? 'ሪፖርቶች' : 'Reports';
  static String get reportsAndAnalytics =>
      _am ? 'ሪፖርቶች እና ትንታኔ' : 'Reports & Analytics';
  static String get developers => _am ? 'ገንቢዎች' : 'Developers';
  static String get developerManagement =>
      _am ? 'ገንቢ አስተዳደር' : 'Developer management';
  static String get announcement => _am ? 'ማስታወቂያ' : 'Announcement';

  // ── User Roles ──
  static String get roleDeveloper => _am ? 'ገንቢ' : 'Developer';
  static String get roleAdmin => _am ? 'አስተዳዳሪ' : 'Admin';
  static String get roleLeader => _am ? 'አመራር' : 'Leader';
  static String get roleMember => _am ? 'አባል' : 'Member';
  static String get roleViewer => _am ? 'ታዛቢ' : 'Viewer';

  // ── Leader Roles ──
  static String get leaderOwner => _am ? 'ባለቤት' : 'Owner';
  static String get leaderAmerar => _am ? 'አመራር' : 'Leader';
  static String get leaderMemakir => _am ? 'መማክርት' : 'Advisor';
  static String get leaderEdirAmerar => _am ? 'የእድር አመራር' : 'Edir Leader';
  static String get leaderViewerRole => _am ? 'ታዛቢ' : 'Viewer';

  // ── Edir Leader Roles ──
  static String get edirChairman => _am ? 'ሊቀ መንበር' : 'Chairman';
  static String get edirViceChairman => _am ? 'ም/ሊቀ መንበር' : 'Vice Chairman';
  static String get edirSecretary => _am ? 'ጸሐፊ' : 'Secretary';
  static String get edirAccountant => _am ? 'ሒሳብ ሹም' : 'Accountant';
  static String get edirTreasurer => _am ? 'ግምጃ ቤት' : 'Treasurer';

  // ── Leader screens ──
  static String get noLeadersYet =>
      _am ? 'እስካሁን አመራር አልተመዘገበም።' : 'No leaders registered yet.';
  static String get addLeaderHint => _am
      ? 'አዲስ አመራር ለመጨመር ከታች ያለውን ቁልፍ ይጫኑ'
      : 'Tap the button below to add a new leader';
  static String get newLeader => _am ? 'አዲስ አመራር' : 'New Leader';
  static String get editLeader => _am ? 'አመራር አርትዕ' : 'Edit Leader';
  static String get deleteLeader => _am ? 'አመራር ሰርዝ' : 'Delete Leader';
  static String get deleteLeaderFailed =>
      _am ? 'አመራሩን መሰረዝ አልተቻለም።' : 'Failed to delete leader.';
  static String get ownerSection => _am ? 'ባለቤት' : 'Owner';
  static String get leaderSection => _am ? 'አመራሮች' : 'Leaders';
  static String get advisorSection => _am ? 'መማክርት' : 'Advisors';
  static String get edirLeaderSection => _am ? 'የእድር አመራሮች' : 'Edir Leaders';
  static String get viewerSection => _am ? 'ታዛቢዎች' : 'Viewers';
  static String get personalInfo => _am ? 'የግል መረጃ' : 'Personal Info';
  static String get christianName => _am ? 'የክርስትና ስም' : 'Christian Name';
  static String get phoneNumber => _am ? 'ስልክ ቁጥር' : 'Phone Number';
  static String get additionalPhone => _am ? 'ተጨማሪ ስልክ' : 'Additional Phone';
  static String get edirRole => _am ? 'የእድር ሚና' : 'Edir Role';
  static String get assignedTsiwas =>
      _am ? 'የተመደበባቸው ፅዋ ማህበሮች' : 'Assigned Tsiwa Groups';
  static String get isActive => _am ? 'ንቁ' : 'Active';
  static String get leaderIsActive => _am ? 'አመራሩ ንቁ ነው' : 'Leader is active';
  static String get stopped => _am ? 'ቆሟል' : 'Stopped';

  // ── Tsiwa screens ──
  static String get noTsiwaYet =>
      _am ? 'እስካሁን ፅዋ ማህበር አልተመዘገበም።' : 'No Tsiwa group registered yet.';
  static String get addTsiwaHint => _am
      ? 'አዲስ ፅዋ ማህበር ለመጨመር ከታች ያለውን ቁልፍ ይጫኑ'
      : 'Tap the button below to add a new Tsiwa';
  static String get newTsiwa => _am ? 'አዲስ ፅዋ' : 'New Tsiwa';
  static String get editTsiwa => _am ? 'ፅዋ አርትዕ' : 'Edit Tsiwa';
  static String get tsiwaDetail => _am ? 'ፅዋ ዝርዝር' : 'Tsiwa Detail';
  static String get tsiwaNotFound =>
      _am ? 'ፅዋ ማህበሩ አልተገኘም' : 'Tsiwa group not found';
  static String get deleteTsiwa => _am ? 'ፅዋ ሰርዝ' : 'Delete Tsiwa';
  static String get basicInfo => _am ? 'መሰረታዊ መረጃ' : 'Basic Info';
  static String get tsiwaName => _am ? 'ፅዋ ስም *' : 'Tsiwa Name *';
  static String get enterTsiwaName => _am ? 'ፅዋ ስም ያስገቡ' : 'Enter Tsiwa name';
  static String get churchName => _am ? 'የቤተ ክርስቲያን ስም' : 'Church Name';
  static String get saintName => _am ? 'የቅዱስ/ቅድስት ስም' : 'Saint Name';
  static String get location => _am ? 'ቦታ' : 'Location';
  static String get monthlyTsiwaDay =>
      _am ? 'የወርሃዊ ፅዋ ቀን' : 'Monthly Tsiwa Day';
  static String get day => _am ? 'ቀን' : 'Day';
  static String get dayRange => _am ? 'ቀን (1-30) *' : 'Day (1-30) *';
  static String get enterDay =>
      _am ? 'የወርሃዊ ፅዋ ቀን ያስገቡ' : 'Enter monthly Tsiwa day';
  static String get dayMustBe1to30 =>
      _am ? 'ቀን ከ1 እስከ 30 መሆን አለበት' : 'Day must be between 1 and 30';
  static String get zikirDay => _am ? 'የዝክር ቀን' : 'Memorial Day';
  static String get title => _am ? 'ርዕስ' : 'Title';
  static String get monthRange => _am ? 'ወር (1-12)' : 'Month (1-12)';
  static String get dayRange2 => _am ? 'ቀን (1-30)' : 'Day (1-30)';
  static String get feedingDay => _am ? 'ነድያንን የማብላት ቀን' : 'Feeding Day';
  static String get archive => _am ? 'ማህደር' : 'Archive';
  static String get tsiwaIsActive =>
      _am ? 'ፅዋው በንቁ ሁኔታ ላይ ነው' : 'Tsiwa is active';
  static String get archiveTsiwa =>
      _am ? 'ፅዋውን ወደ ማህደር ያስገቡ' : 'Archive this Tsiwa';
  static String get yearlyZikirTitle =>
      _am ? 'የዓመታዊ በዓል ዝክር' : 'Yearly Holiday Memorial';
  static String get addYearlyZikir =>
      _am ? 'የዓመታዊ በዓል ዝክር ጨምር' : 'Add Yearly Holiday Memorial';
  static String get noYearlyZikirYet => _am
      ? 'እስካሁን የዓመታዊ በዓል ዝክር አልተመዘገበም'
      : 'No yearly holiday memorial registered yet';
  static String get month => _am ? 'ወር' : 'Month';
  static String get zikirFeedingSection =>
      _am ? 'ዝክር / ማብላት' : 'Memorial / Feeding';
  static String get noZikirOrFeeding => _am
      ? 'እስካሁን የዝክር ወይም የማብላት ቀን አልተመዘገበም'
      : 'No memorial or feeding day registered yet';
  static String get members => _am ? 'አባላት' : 'Members';
  static String get calendar => _am ? 'የቀን መርሐ ግብር' : 'Calendar';
  static String get rotationAndHistory =>
      _am ? 'የፅዋ ተራ እና ታሪክ' : 'Rotation & History';
  static String get rotationOrder =>
      _am ? 'ተራ ቅደም ተከተል እና የክንውን ታሪክ' : 'Rotation order and event history';
  static String tsiwaDay(int day) => _am ? 'ፅዋ ቀን $day' : 'Tsiwa Day $day';
  static String get monthMustBe1to13 =>
      _am ? 'ወር ከ1 እስከ 12 መሆን አለበት' : 'Month must be between 1 and 12';
  static String get enterDayVal => _am ? 'ቀን ያስገቡ' : 'Enter day';
  static String get enterMonthVal => _am ? 'ወር ያስገቡ' : 'Enter month';
  static String get dataDeleteFailed =>
      _am ? 'መረጃውን መሰረዝ አልተቻለም።' : 'Failed to delete data.';
  static String get dataSaveFailed =>
      _am ? 'መረጃውን ማስቀመጥ አልተቻለም።' : 'Failed to save data.';

  // ── Rotation screen ──
  static String get rotation => _am ? 'የፅዋ ተራ' : 'Tsiwa Rotation';
  static String get rotationOrderTab => _am ? 'ተራ ቅደም ተከተል' : 'Rotation Order';
  static String get eventHistory => _am ? 'የክንውን ታሪክ' : 'Event History';
  static String get noMembersInRotation =>
      _am ? 'በተራ ውስጥ ያለ ማህበርተኛ የለም' : 'No members in rotation';
  static String get membersMustBeInRotation => _am
      ? 'ማህበርተኞች ተመዝግበው በተራ ውስጥ መሆን አለባቸው'
      : 'Members must be registered and in rotation';
  static String get currentTurn => _am ? 'አሁን ተራ' : 'Current Turn';
  static String get nextTurn => _am ? 'ቀጣይ ተራ' : 'Next Turn';
  static String get next => _am ? 'ቀጣይ' : 'Next';
  static String get rotationUpdateFailed =>
      _am ? 'ተራውን ማዘመን አልተቻለም' : 'Failed to update rotation';
  static String get noEventsYet =>
      _am ? 'እስካሁን ክንውን አልተመዘገበም' : 'No events recorded yet';
  static String get addEventHint => _am
      ? 'ክንውን ለመመዝገብ ከታች ያለውን ቁልፍ ይጫኑ'
      : 'Tap button below to record an event';
  static String get recordEvent => _am ? 'ክንውን መዝግብ' : 'Record Event';
  static String get eventRecordFailed =>
      _am ? 'ክንውን መመዝገብ አልተቻለም' : 'Failed to record event';
  static String get statusUpdateFailed =>
      _am ? 'ሁኔታውን ማዘመን አልተቻለም' : 'Failed to update status';
  static String get completed => _am ? 'ተፈጸመ' : 'Completed';
  static String get cancelled => _am ? 'ተሰረዘ' : 'Cancelled';
  static String get type => _am ? 'ዓይነት' : 'Type';
  static String get responsibleMember => _am ? 'ኃላፊ ማህበርተኛ' : 'Responsible Member';

  // ── Tsiwa Event Types ──
  static String get monthlyTsiwa => _am ? 'የወርሃዊ ፅዋ' : 'Monthly Tsiwa';
  static String get zikir => _am ? 'ዝክር' : 'Memorial';
  static String get feeding => _am ? 'ማብላት' : 'Feeding';
  static String get other => _am ? 'ሌላ' : 'Other';
  static String get planned => _am ? 'የታቀደ' : 'Planned';
  static String get eventCompleted => _am ? 'የተፈጸመ' : 'Completed';
  static String get eventCancelled => _am ? 'የተሰረዘ' : 'Cancelled';

  // ── Edir screens ──
  static String get noEdirYet =>
      _am ? 'እስካሁን እድር አልተመዘገበም።' : 'No Edir registered yet.';
  static String get addEdirHint => _am
      ? 'አዲስ እድር ለመጨመር ከታች ያለውን ቁልፍ ይጫኑ'
      : 'Tap the button below to add a new Edir';
  static String get newEdir => _am ? 'አዲስ እድር' : 'New Edir';
  static String get editEdir => _am ? 'እድር አስተካክል' : 'Edit Edir';
  static String get deleteEdir => _am ? 'እድር ሰርዝ' : 'Delete Edir';
  static String get edirNotFound => _am ? 'እድር አልተገኘም' : 'Edir not found';
  static String get edirName => _am ? 'የእድሩ ስም' : 'Edir name';
  static String get aboutEdir =>
      _am ? 'ስለ እድሩ አጭር መግለጫ' : 'Brief description about the Edir';
  static String get monthlyContribution =>
      _am ? 'ወርሃዊ መዋጮ (ብር) *' : 'Monthly Contribution (Birr) *';
  static String get monthlyContribRequired =>
      _am ? 'ወርሃዊ መዋጮ ያስፈልጋል' : 'Monthly contribution is required';
  static String get validAmountRequired =>
      _am ? 'ትክክለኛ መጠን ያስገቡ' : 'Enter a valid amount';
  static String get penaltyAmount =>
      _am ? 'የቅጣት መጠን (ብር)' : 'Penalty Amount (Birr)';
  static String get paymentDay => _am ? 'የክፍያ ቀን (1-30)' : 'Payment Day (1-30)';
  static String get payments => _am ? 'ክፍያዎች' : 'Payments';
  static String get paymentReport =>
      _am ? 'ክፍያ ሪፖርት ይመልከቱ' : 'View payment report';
  static String get monthlyDue => _am ? 'ወርሃዊ መዋጮ' : 'Monthly Due';
  static String get penalty => _am ? 'ቅጣት' : 'Penalty';
  static String paymentDayOf(int d) => _am ? 'በወር $d' : 'Day $d of month';
  static String get treasury => _am ? 'ግምጃ ቤት' : 'Treasury';
  static String treasuryBirr(String v) =>
      _am ? 'ግምጃ ቤት: $v ብር' : 'Treasury: $v Birr';
  static String get treasuryBirrLabel =>
      _am ? 'ግምጃ ቤት (ብር)' : 'Treasury (Birr)';

  // ── Edir Members ──
  static String get noMembersYet =>
      _am ? 'እስካሁን አባል አልተመዘገበም።' : 'No members registered yet.';
  static String get addMemberHint => _am
      ? 'አዲስ አባል ለመጨመር ከታች ያለውን ቁልፍ ይጫኑ'
      : 'Tap the button below to add a new member';
  static String get newMember => _am ? 'አዲስ አባል' : 'New Member';
  static String get editMember => _am ? 'አባል አስተካክል' : 'Edit Member';
  static String get deleteMember => _am ? 'አባል ሰርዝ' : 'Delete Member';
  static String get memberFullName => _am ? 'የአባሉ ሙሉ ስም' : "Member's full name";
  static String get memberChristianName =>
      _am ? 'የአባሉ የክርስትና ስም' : "Member's Christian name";
  static String paidAmount(String v) => _am ? 'ከፍሏል: $v ብር' : 'Paid: $v Birr';
  static String balanceDue(String v) =>
      _am ? 'ቀሪ ዕዳ: $v ብር' : 'Balance: $v Birr';
  static String get recordPayment => _am ? 'ክፍያ መዝግብ' : 'Record Payment';

  // ── Record Payment ──
  static String get paymentType => _am ? 'የክፍያ ዓይነት' : 'Payment Type';
  static String get amountBirr => _am ? 'መጠን (ብር) *' : 'Amount (Birr) *';
  static String get amountRequired => _am ? 'መጠን ያስፈልጋል' : 'Amount is required';
  static String get forMonth => _am ? 'ለየትኛው ወር' : 'For which month';
  static String get year => _am ? 'ዓ.ም.' : 'Year (E.C.)';
  static String get additionalNote => _am ? 'ተጨማሪ ማስታወሻ' : 'Additional note';
  static String get paymentRecorded => _am ? 'ክፍያ ተመዝግቧል' : 'Payment recorded';

  // ── Payment Types ──
  static String get payMonthly => _am ? 'ወርሃዊ' : 'Monthly';
  static String get payPenalty => _am ? 'ቅጣት' : 'Penalty';
  static String get payOther => _am ? 'ሌላ' : 'Other';

  // ── Edir Member Status ──
  static String get statusActive => _am ? 'ንቁ' : 'Active';
  static String get statusInactive => _am ? 'ቦዝኗል' : 'Inactive';
  static String get statusSuspended => _am ? 'የታገደ' : 'Suspended';

  // ── Edir Payment List ──
  static String get noPaymentsYet =>
      _am ? 'እስካሁን ክፍያ አልተመዘገበም።' : 'No payments recorded yet.';
  static String get paymentFromMemberList => _am
      ? 'ከአባላት ዝርዝር ክፍያ ማስመዝገብ ይችላሉ'
      : 'You can record payments from the member list';

  // ── Notifications ──
  static String get notificationTitle => _am ? 'ማሳወቂያዎች' : 'Notifications';
  static String get markAllRead =>
      _am ? 'ሁሉንም እንደተነበበ ምልክት አድርግ' : 'Mark all as read';
  static String get clearAll => _am ? 'ሁሉንም አጽዳ' : 'Clear all';
  static String get noNotifications =>
      _am ? 'ምንም ማሳወቂያ የለም' : 'No notifications';
  static String get clearAllConfirm =>
      _am ? 'ሁሉንም ማሳወቂያዎች አጽዳ' : 'Clear all notifications';
  static String get clearAllConfirmMsg => _am
      ? 'ሁሉንም ማሳወቂያዎች ለመሰረዝ እርግጠኛ ነዎት?'
      : 'Are you sure you want to clear all notifications?';
  static String get clear => _am ? 'አጽዳ' : 'Clear';

  // ── Notification Types ──
  static String get notifAnnouncement => _am ? 'ማስታወቂያ' : 'Announcement';
  static String get notifEvent => _am ? 'ክስተት' : 'Event';
  static String get notifPayment => _am ? 'ክፍያ' : 'Payment';
  static String get notifSystem => _am ? 'ስርዓት' : 'System';

  // ── Announcements ──
  static String get noAnnouncementsYet =>
      _am ? 'እስካሁን ማስታወቂያ የለም።' : 'No announcements yet.';
  static String get addAnnouncementHint => _am
      ? 'አዲስ ማስታወቂያ ለመጨመር ከታች ያለውን ቁልፍ ይጫኑ'
      : 'Tap the button below to add an announcement';
  static String get newAnnouncement => _am ? 'አዲስ ማስታወቂያ' : 'New Announcement';
  static String get editAnnouncement =>
      _am ? 'ማስታወቂያ አስተካክል' : 'Edit Announcement';
  static String get deleteAnnouncement =>
      _am ? 'ማስታወቂያ ሰርዝ' : 'Delete Announcement';
  static String get announcementDeleted =>
      _am ? 'ማስታወቂያ ተሰርዟል' : 'Announcement deleted';
  static String get announcementNotFound =>
      _am ? 'ማስታወቂያ አልተገኘም' : 'Announcement not found';
  static String get titleRequired => _am ? 'ርዕስ ያስፈልጋል' : 'Title is required';
  static String get detailRequired =>
      _am ? 'ዝርዝር ያስፈልጋል' : 'Detail is required';
  static String get detail => _am ? 'ዝርዝር *' : 'Detail *';
  static String get level => _am ? 'ደረጃ' : 'Level';
  static String get iHaveRead => _am ? 'አንብቤአለሁ' : 'I have read';
  static String get markAsRead => _am ? 'አንብቤአለሁ ምልክት አድርግ' : 'Mark as read';
  static String get readBy => _am ? 'ያነበቡ ሰዎች' : 'Read by';
  static String get noOneReadYet =>
      _am ? 'እስካሁን ማንም አላነበበም' : 'No one has read yet';

  // ── Announcement Levels ──
  static String get levelNormal => _am ? 'መደበኛ' : 'Normal';
  static String get levelImportant => _am ? 'አስፈላጊ' : 'Important';
  static String get levelUrgent => _am ? 'አስቸኳይ' : 'Urgent';

  // ── Telegram ──
  static String get telegramConnection =>
      _am ? 'ቴሌግራም ማገናኛ' : 'Telegram Connection';
  static String get telegramBotTitle => _am ? 'ቴሌግራም ቦት' : 'Telegram Bot';
  static String get telegramDesc => _am
      ? 'ማስታወቂያዎችን ወደ ቴሌግራም ግሩፕ ያስተላልፉ'
      : 'Send announcements to Telegram group';
  static String get botSettings => _am ? 'ቦት ማስተካከያ' : 'Bot Settings';
  static String get botCreateHint => _am
      ? 'ቦት ለመፍጠር @BotFather ን በቴሌግራም ያግኙ'
      : 'Use @BotFather on Telegram to create a bot';
  static String get testConnection => _am ? 'ግንኙነት ፈትሽ' : 'Test Connection';
  static String get notifTypes => _am ? 'ማሳወቂያ ዓይነቶች' : 'Notification Types';
  static String get sendAnnouncements => _am
      ? 'አዲስ ማስታወቂያ ሲፈጠር ወደ ቴሌግራም ላክ'
      : 'Send new announcements to Telegram';
  static String get events => _am ? 'ክስተቶች' : 'Events';
  static String get sendEvents =>
      _am ? 'የክስተት ማስታወሻ ወደ ቴሌግራም ላክ' : 'Send event reminders to Telegram';
  static String connectionSuccess(bool ok) => ok
      ? (_am ? 'ግንኙነት ተሳክቷል!' : 'Connection successful!')
      : (_am ? 'ግንኙነት አልተሳካም' : 'Connection failed');

  // ── User Management ──
  static String get noUsersFound => _am ? 'ተጠቃሚ አልተገኘም' : 'No users found';

  // ── Developer Management ──
  static String get addDeveloper => _am ? 'አዲስ ገንቢ ጨምር' : 'Add New Developer';
  static String get developerList => _am ? 'ገንቢዎች ዝርዝር' : 'Developer List';
  static String get noDevelopers =>
      _am ? 'ምንም ገንቢ አልተመዘገበም' : 'No developers registered';
  static String get deleteDeveloper => _am ? 'ገንቢ ሰርዝ' : 'Delete Developer';
  static String get devDeleteFailed => _am ? 'መሰረዝ አልተቻለም' : 'Failed to delete';

  // ── CSV ──
  static String get selectDataType =>
      _am ? 'የመረጃ ዓይነት ይምረጡ' : 'Select data type';
  static String get csvExportDesc => _am
      ? 'መረጃውን CSV ፋይል አድርገው ያውርዱ ወይም ያጋሩ'
      : 'Download or share data as CSV file';
  static String get loadingTsiwas =>
      _am ? 'ፅዋ ማህበሮችን በመጫን ላይ...' : 'Loading Tsiwa groups...';
  static String get noTsiwaRegistered =>
      _am ? 'ምንም ፅዋ ማህበር አልተመዘገበም' : 'No Tsiwa groups registered';
  static String get selectTsiwa => _am ? 'ፅዋ ማህበር ይምረጡ' : 'Select Tsiwa Group';
  static String get loadingEdirs =>
      _am ? 'እድሮችን በመጫን ላይ...' : 'Loading Edirs...';
  static String get noEdirRegistered =>
      _am ? 'ምንም እድር አልተመዘገበም' : 'No Edirs registered';
  static String get selectEdir => _am ? 'እድር ይምረጡ' : 'Select Edir';
  static String get exportCsv => _am ? 'CSV ላክ' : 'Export CSV';
  static String get exporting => _am ? 'በመላክ ላይ...' : 'Exporting...';
  static String get selectFile => _am ? 'CSV ፋይል ምረጥ' : 'Select CSV File';
  static String get selectAnotherFile =>
      _am ? 'ሌላ ፋይል ምረጥ' : 'Select Another File';
  static String get importing => _am ? 'በማስገባት ላይ...' : 'Importing...';
  static String importCount(int n) => _am ? '$n መረጃ አስገባ' : 'Import $n items';
  static String get fileReadFailed =>
      _am ? 'ፋይሉን ማንበብ አልተቻለም' : 'Failed to read file';
  static String get fileNeedsHeaderAndData =>
      _am ? 'ፋይሉ ራስ ጌና መረጃ ሊኖረው ይገባል' : 'File must have a header row and data';
  static String get importConfirm => _am ? 'ማረጋገጫ' : 'Confirmation';
  static String get importConfirmMsg => _am
      ? 'መረጃዎቹን ወደ ውስጥ ማስገባት ይፈልጋሉ?\nነባር መረጃዎች አይቀየሩም — አዲስ ብቻ ይጨመራሉ።'
      : 'Do you want to import the data?\nExisting data will not be changed — only new items will be added.';
  static String get importBtn => _am ? 'አስገባ' : 'Import';

  // ── CSV entity types ──
  static String get tsiwaMembers => _am ? 'የፅዋ አባላት' : 'Tsiwa Members';
  static String get leadersCsv => _am ? 'አመራሮች' : 'Leaders';
  static String get edirMembers => _am ? 'የእድር አባላት' : 'Edir Members';

  // ── Reports ──
  static String get loadingReports =>
      _am ? 'ሪፖርቶችን በመጫን ላይ...' : 'Loading reports...';
  static String get refresh => _am ? 'አድስ' : 'Refresh';
  static String get overallSummary => _am ? 'አጠቃላይ ማጠቃለያ' : 'Overall Summary';
  static String get inAllTsiwas => _am ? 'በሁሉም ፅዋ' : 'In all Tsiwas';
  static String get detailedReports => _am ? 'ዝርዝር ሪፖርቶች' : 'Detailed Reports';
  static String get tsiwaReport => _am ? 'የፅዋ ሪፖርት' : 'Tsiwa Report';
  static String get tsiwaReportSub =>
      _am ? 'የአባላት ብዛት፣ ሚና ስርጭት' : 'Member count, role distribution';
  static String get edirReport => _am ? 'የእድር ሪፖርት' : 'Edir Report';
  static String get edirReportSub =>
      _am ? 'የክፍያ ማጠቃለያ፣ ቀሪ ሂሳብ' : 'Payment summary, balance';
  static String get noEdirData => _am ? 'ምንም እድር አልተመዘገበም' : 'No Edir data';
  static String get noTsiwaData =>
      _am ? 'ምንም ፅዋ ማህበር አልተመዘገበም' : 'No Tsiwa data';
  static String get financialSummary =>
      _am ? 'አጠቃላይ የገንዘብ ማጠቃለያ' : 'Overall Financial Summary';
  static String get treasuryByEdir => _am ? 'ግምጃ ቤት በእድር' : 'Treasury by Edir';
  static String get totalPayment => _am ? 'ጠቅላላ ክፍያ' : 'Total Payment';
  static String get balance => _am ? 'ቀሪ ሂሳብ' : 'Balance';
  static String get paymentDistribution =>
      _am ? 'የክፍያ ስርጭት' : 'Payment Distribution';
  static String get membersByStatus => _am ? 'አባላት በሁኔታ' : 'Members by Status';
  static String get topBalances => _am ? 'ከፍተኛ ቀሪ ሂሳብ' : 'Top Balances';
  static String get noMembersWithBalance =>
      _am ? 'ቀሪ ሂሳብ ያለው አባል የለም' : 'No members with balance';
  static String get membersByTsiwa => _am ? 'አባላት በየፅዋው' : 'Members by Tsiwa';
  static String get roleDistribution => _am ? 'የሚና ስርጭት' : 'Role Distribution';
  static String get leadersByRole => _am ? 'አመራሮች በሚና' : 'Leaders by Role';
  static String get byTsiwaGroup => _am ? 'በፅዋ ማህበር' : 'By Tsiwa Group';
  static String get inRotation => _am ? 'በተራ' : 'In Rotation';

  // ── Auth errors ──
  static String get userNotFound => _am ? 'ተጠቃሚ አልተገኘም' : 'User not found';
  static String get wrongPassword => _am ? 'የተሳሳተ ይለፍ ቃል' : 'Wrong password';
  static String get emailInUse =>
      _am ? 'ይህ ኢሜይል አስቀድሞ ተመዝግቧል' : 'Email already registered';
  static String get weakPassword => _am
      ? 'ይለፍ ቃል ደካማ ነው (ቢያንስ 6 ቁምፊ)'
      : 'Password too weak (min 6 characters)';
  static String get invalidEmail =>
      _am ? 'ትክክለኛ ኢሜይል ያስገቡ' : 'Enter a valid email';
  static String get invalidCredential => _am
      ? 'ስልክ ቁጥር ወይም ይለፍ ቃል ትክክል አይደለም'
      : 'Invalid phone number or password';
  static String get tooManyRequests => _am
      ? 'በጣም ብዙ ሙከራ — ትንሽ ቆይተው ይሞክሩ'
      : 'Too many attempts — try again later';
  static String get networkError =>
      _am ? 'የኢንተርኔት ግንኙነት ያረጋግጡ' : 'Check internet connection';
  static String unexpectedError(String e) =>
      _am ? 'ያልተጠበቀ ስህተት: $e' : 'Unexpected error: $e';

  // ── Developer Sign-In ──
  static String get signInCancelled => _am ? 'ግብዓት ተሰርዟል' : 'Sign-in cancelled';
  static String emailNotAuthorized(String email) => _am
      ? 'ይህ ኢሜይል ($email) የገንቢ ፈቃድ የለውም'
      : 'This email ($email) is not authorized as developer';

  // ── Phone + Password Auth ──
  static String get phoneRequired =>
      _am ? 'ስልክ ቁጥር ያስፈልጋል' : 'Phone number is required';
  static String get passwordCode => _am ? 'የይለፍ ኮድ' : 'Access Code';
  static String get codeRequired =>
      _am ? 'የይለፍ ኮድ ያስፈልጋል' : 'Access code is required';
  static String get phoneNotRegistered =>
      _am ? 'ይህ ስልክ ቁጥር አልተመዘገበም' : 'This phone number is not registered';
  static String get wrongCode => _am ? 'የተሳሳተ የይለፍ ኮድ' : 'Wrong access code';
  static String get accountKicked => _am
      ? 'ከአካውንት ተባርረዋል — አስተዳዳሪን ያነጋግሩ'
      : 'You have been logged out — contact admin';
  static String get memberLogin => _am ? 'የማህበርተኛ መግቢያ' : 'Member Login';
  static String get enterPhoneAndCode => _am
      ? 'ስልክ ቁጥርዎን እና የይለፍ ኮድዎን ያስገቡ'
      : 'Enter your phone number and access code';
  static String get setPassword => _am ? 'ይለፍ ኮድ ቀይር' : 'Set Access Code';
  static String get newPassword => _am ? 'አዲስ የይለፍ ኮድ' : 'New Access Code';
  static String get passwordUpdated =>
      _am ? 'ይለፍ ኮድ ተቀይሯል' : 'Access code updated';
  static String get kickOut => _am ? 'አስወጣ' : 'Kick Out';
  static String get kickOutConfirm => _am
      ? 'ይህን ማህበርተኛ ከአካውንት ማስወጣት ይፈልጋሉ?'
      : 'Do you want to kick out this member?';
  static String get kicked => _am ? 'ተባርሯል' : 'Kicked out';
  static String get reinstated => _am ? 'ተመልሷል' : 'Reinstated';
  static String get addMemberAccount =>
      _am ? 'ማህበርተኛ ተጠቃሚ ፍጠር' : 'Create Member Account';
  static String get memberAccountCreated =>
      _am ? 'የማህበርተኛ አካውንት ተፈጥሯል' : 'Member account created';
  static String get phoneAlreadyRegistered => _am
      ? 'ይህ ስልክ ቁጥር አስቀድሞ ተመዝግቧል'
      : 'This phone number is already registered';
  static String get areaLabel => _am ? 'አካባቢ' : 'Area';
  static String get deleteUser => _am ? 'ተጠቃሚ ሰርዝ' : 'Delete User';
  static String get deleteUserConfirm => _am
      ? 'ይህን ተጠቃሚ ለመሰረዝ እርግጠኛ ነዎት?'
      : 'Are you sure you want to delete this user?';
  static String get userDeleted => _am ? 'ተጠቃሚ ተሰርዟል' : 'User deleted';
  static String get editPhone => _am ? 'ስልክ ቁጥር ቀይር' : 'Edit Phone Number';
  static String get phoneUpdated =>
      _am ? 'ስልክ ቁጥር ተቀይሯል' : 'Phone number updated';
  static String get allUsers => _am ? 'ሁሉም ተጠቃሚዎች' : 'All Users';

  // ── Global Members ──
  static String get optionalField => _am ? '(አይጋደልም)' : '(Optional)';
  static String get globalMembers => _am ? 'አባላት' : 'Members';
  static String get manageGlobalMembers =>
      _am ? 'አባላትን ያስተዳድሩ' : 'Manage Members';
  static String get noGlobalMembersYet =>
      _am ? 'እስካሁን አባል አልተመዘገበም።' : 'No members registered yet.';
  static String get addGlobalMemberHint => _am
      ? 'አዲስ አባል ለመጨመር ከታች ያለውን ቁልፍ ይጫኑ'
      : 'Tap the button below to add a new member';
  static String get newGlobalMember => _am ? 'አዲስ አባል' : 'New Member';
  static String get editGlobalMember => _am ? 'አባል አስተካክል' : 'Edit Member';
  static String get deleteGlobalMember => _am ? 'አባል ሰርዝ' : 'Delete Member';
  static String get deleteGlobalMemberConfirm => _am
      ? 'ይህን አባል ለመሰረዝ እርግጠኛ ነዎት?'
      : 'Are you sure you want to delete this member?';
  static String get globalMemberDeleted => _am ? 'አባል ተሰርዟል' : 'Member deleted';
  static String get globalMemberSaved => _am ? 'አባል ተቀምጧል' : 'Member saved';
  static String get assignToTsiwa => _am ? 'ወደ ፅዋ ማህበር መደብ' : 'Assign to Tsiwa';
  static String get assignToEdir => _am ? 'ወደ እድር መደብ' : 'Assign to Edir';
  static String get tsiwaAssignments =>
      _am ? 'የፅዋ ማህበር ምደባ' : 'Tsiwa Assignments';
  static String get edirAssignments => _am ? 'የእድር ምደባ' : 'Edir Assignments';
  static String get selectTsiwas =>
      _am ? 'ፅዋ ማህበሮችን ይምረጡ' : 'Select Tsiwa Groups';
  static String get selectEdirs => _am ? 'እድሮችን ይምረጡ' : 'Select Edirs';
  static String get tsiwaRole => _am ? 'የፅዋ ሚና' : 'Tsiwa Role';
  static String get roleMuse => _am ? 'ሙሴ' : 'Muse';
  static String get roleAssistantMuse => _am ? 'ረዳት ሙሴ' : 'Assistant Muse';
  static String get roleMemberTsiwa => _am ? 'ማህበርተኛ' : 'Member';
  static String get roleObserver => _am ? 'ታዛቢ' : 'Observer';
  static String get isEdirAmerar => _am ? 'የእድር አመራር' : 'Edir Leader';
  static String get edirAmerarDesc =>
      _am ? 'ክፍያ ማስመዝገብ ይችላል' : 'Can record payments';
  static String get csvImportMembers =>
      _am ? 'CSV አባላት አስገባ' : 'CSV Import Members';
  static String get csvImportMembersDesc =>
      _am ? 'CSV ፋይል ከመረጃ ጋር አባላትን አስገባ' : 'Import members from CSV file';
  static String get importMembers =>
      _am ? 'ማህበርተኞች አስገባ' : 'Import Members';
  static String get importMembersDesc => _am
      ? 'CSV ወይም XLSX ፋይል ከመረጃ ጋር ማህበርተኞችን አስገባ'
      : 'Import members from CSV or XLSX file';
  static String get importPreview => _am ? 'ቅድመ ዕይታ' : 'Preview';
  static String importingMembers(int n) =>
      _am ? '$n ማህበርተኞች በማስገባት ላይ...' : 'Importing $n members...';
  static String membersImported(int n) =>
      _am ? '$n ማህበርተኞች ተገብተዋል' : '$n members imported';
  static String get accessCode => _am ? 'የመግቢያ ኮድ' : 'Access Code';

  // ── Member Home ──
  static String get myTsiwa => _am ? 'ፅዋዬ' : 'My Tsiwa';
  static String get myEdir => _am ? 'እድሬ' : 'My Edir';
  static String get home => _am ? 'መነሻ' : 'Home';
  static String get teregna => _am ? 'ተረኛ' : 'Current Turn';
  static String get teregnaCalendar => _am ? 'የተረኛ መርሃ ግብር' : 'Turn Schedule';
  static String get thisMonth => _am ? 'በዚህ ወር' : 'This Month';
  static String get nextMonths => _am ? 'ቀጣይ ወራት' : 'Next Months';
  static String get monthlyPayments =>
      _am ? 'ወርሃዊ መዋጮ' : 'Monthly Contributions';
  static String get paid => _am ? 'ከፍሏል' : 'Paid';
  static String get unpaid => _am ? 'አልከፈለም' : 'Unpaid';
  static String get paymentStatus => _am ? 'የክፍያ ሁኔታ' : 'Payment Status';
  static String get noAssignments =>
      _am ? 'ወደ ምንም ፅዋ ወይም እድር አልተመደቡም' : 'Not assigned to any Tsiwa or Edir';
  static String get contactAdminForAssignment =>
      _am ? 'አስተዳዳሪን ያነጋግሩ ለምደባ' : 'Contact admin for assignment';
  static String get welcome => _am ? 'እንኳን ደህና መጡ' : 'Welcome';
  static String get makeAdmin => _am ? 'አስተዳዳሪ አድርግ' : 'Make Admin';
  static String paidBirr(String v) => _am ? '$v ብር ከፍሏል' : '$v Birr paid';
  static String owedBirr(String v) => _am ? '$v ብር ቀሪ' : '$v Birr owed';

  // ── Monthly Order ──
  static String get monthlyOrder => _am ? 'የወር ተራ' : 'Monthly Order';
  static String get monthlyOrderTable => _am ? 'የወር ተራ ሰንጠረዥ' : 'Monthly Order Table';
  static String get assignOrder => _am ? 'ተራ ስጥ' : 'Assign Order';
  static String get selectMember => _am ? 'ማህበርተኛ ይምረጡ' : 'Select Member';
  static String get unassigned => _am ? 'አልተመደበም' : 'Unassigned';
  static String get orderSaved => _am ? 'ተራ ተቀምጧል' : 'Order saved';
  static String get orderSaveFailed => _am ? 'ተራ ማስቀመጥ አልተቻለም' : 'Failed to save order';
  static String get yourNextOrder => _am ? 'የእርስዎ ቀጣይ ተራ' : 'Your Next Order';
  static String get currentOrder => _am ? 'የአሁኑ ወር ተራ' : 'Current Month Order';
  static String get upcomingOrders => _am ? 'ቀጣይ ተራዎች' : 'Upcoming Orders';
  static String get allOrders => _am ? 'ሁሉም ተራዎች' : 'All Orders';
  static String daysRemaining(int d) => _am ? '$d ቀናት ቀርተዋል' : '$d days remaining';
  static String monthsRemaining(int m, int d) => _am ? '$m ወር ከ$d ቀናት' : '$m months $d days';

  // ── Bulk add members ──
  static String get addMembersFromGlobal =>
      _am ? 'ማህበርተኞች ጨምር' : 'Add Members';
  static String get selectMembersToAdd =>
      _am ? 'ለዚህ ፅዋ የሚጨመሩ ማህበርተኞችን ይምረጡ' : 'Select members to add to this Tsiwa';
  static String get noUnassignedMembers =>
      _am ? 'ሁሉም አባላት ቀድሞ ተመድበዋል' : 'All members are already assigned';
  static String membersAdded(int n) =>
      _am ? '$n ማህበርተኞች ተጨምረዋል' : '$n members added';
  static String get addingMembers =>
      _am ? 'ማህበርተኞች በመጨመር ላይ...' : 'Adding members...';
  static String get failedToAddMembers =>
      _am ? 'ማህበርተኞች መጨመር አልተቻለም' : 'Failed to add members';
  static String get searchMembers =>
      _am ? 'ማህበርተኛ ፈልግ...' : 'Search members...';
  static String selected(int n) =>
      _am ? '$n ተመርጠዋል' : '$n selected';

  // ── Year switcher ──
  static String yearLabel(int y) => _am ? '$y ዓ.ም.' : 'Year $y';

  // ── Order swap ──
  static String get swapOrder => _am ? 'ተራ ቀያይር' : 'Swap Order';
  static String get swapWith => _am ? 'ከየትኛው ወር ጋር ይቀያይር?' : 'Swap with which month?';
  static String get orderSwapped => _am ? 'ተራ ተቀይሯል' : 'Order swapped';
  static String get swapFailed => _am ? 'ተራ መቀያየር አልተቻለም' : 'Swap failed';

  // ── Tsiwa reorder ──
  static String get reorderTsiwas => _am ? 'ፅዋ ማህበራትን ቅደም ተከተል ቀይር' : 'Reorder Tsiwas';
  static String get orderUpdated => _am ? 'ቅደም ተከተል ተቀይሯል' : 'Order updated';

  // ── Edir sync ──
  static String get syncingEdirMembers =>
      _am ? 'የእድር አባላት በማመሳሰል ላይ...' : 'Syncing edir members...';
  static String get edirMembersSynced =>
      _am ? 'የእድር አባላት ተመሳስለዋል' : 'Edir members synced';

  // ── Notification types ──
  static String get notifTurnReminder =>
      _am ? 'የተራ ማስታወሻ' : 'Turn Reminder';
  static String get notifTurnAlert =>
      _am ? 'የተራ ማሳወቂያ' : 'Turn Alert';

  // ── Announcement targeting ──
  static String get postTo => _am ? 'ለ' : 'Post to';
  static String get allMembers => _am ? 'ለሁሉም አባላት' : 'All members';
  static String get specificTsiwa => _am ? 'ለተወሰነ ፅዋ ማህበር' : 'Specific Tsiwa';
  static String get announcementPosted =>
      _am ? 'ማስታወቂያ ተልኳል' : 'Announcement posted';

  // ── Edir visibility ──
  static String get hideEdir => _am ? 'እድር ደብቅ' : 'Hide Edir';
  static String get showEdir => _am ? 'እድር አሳይ' : 'Show Edir';
  static String get edirHidden => _am ? 'እድር ተደብቋል' : 'Edir hidden';
  static String get edirVisible => _am ? 'እድር ይታያል' : 'Edir visible';
  static String get hidden => _am ? 'የተደበቀ' : 'Hidden';

  // ── Turn reminders ──
  static String get sendReminder => _am ? 'ማስታወሻ ላክ' : 'Send Reminder';
  static String get reminderSent => _am ? 'ማስታወሻ ተልኳል' : 'Reminder sent';
  static String get sendAlert => _am ? 'ማሳወቂያ ላክ' : 'Send Alert';
  static String get alertSent => _am ? 'ማሳወቂያ ተልኳል' : 'Alert sent';
  static String get resendNotification =>
      _am ? 'ማሳወቂያ ደግሞ ላክ' : 'Resend Notification';
  static String get notificationResent =>
      _am ? 'ማሳወቂያ ደግሞ ተልኳል' : 'Notification resent';
  static String turnReminderBody(String month, int days) =>
      _am
          ? 'የ$month ወር ተራዎ $days ቀናት ቀርተዋል'
          : 'Your turn in $month is $days days away';
  static String turnAlertBody(String month) =>
      _am ? 'የ$month ወር ተራዎ ደርሷል!' : 'Your turn for $month has arrived!';
  static String turnReminderAll(String month, String name) =>
      _am
          ? 'የ$month ወር ተራ $name ነው'
          : "$name's turn for $month";
}
