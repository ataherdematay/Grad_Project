import 'package:bitadilat_admin/features/common/labels.dart';
import 'package:bitadilat_admin/l10n/app_localizations.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('admin_actions kodları sözleşmedeki adlarla eşlenir', () {
    final l = lookupAppLocalizations(const Locale('tr'));
    expect(adminActionLabel(l, 'APPROVE_APPLICATION'), l.actionApproved);
    expect(adminActionLabel(l, 'REJECT_APPLICATION'), l.actionRejected);
    expect(
      adminActionLabel(l, 'REQUEST_DOCUMENTS'),
      l.actionDocumentsRequested,
    );
    expect(adminActionLabel(l, 'REVIEW_COMPLAINT'), l.actionReviewed);
    expect(adminActionLabel(l, 'DECIDE_COMPLAINT'), l.actionDecided);
    expect(adminActionLabel(l, 'WARN_PRO'), l.actionWarned);
    expect(adminActionLabel(l, 'SUSPEND_PRO'), l.actionSuspended);
    expect(adminActionLabel(l, 'SUSPEND_USER'), l.actionSuspended);
    expect(adminActionLabel(l, 'REACTIVATE_USER'), l.actionReactivated);
    // Bilinmeyen kod çökertmez, olduğu gibi gösterilir.
    expect(adminActionLabel(l, 'SOMETHING_NEW'), 'SOMETHING_NEW');
  });

  test('bilinmeyen emanet durumu olduğu gibi gösterilir', () {
    final l = lookupAppLocalizations(const Locale('en'));
    expect(escrowLabel(l, 'REFUND_NEEDS_REVIEW'), 'REFUND_NEEDS_REVIEW');
    expect(escrowLabel(l, 'LOCKED'), l.escrowLocked);
  });
}
