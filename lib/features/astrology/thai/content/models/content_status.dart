/// Lifecycle state for authored Thai astrology content.
enum ContentStatus {
  placeholder,
  draft,
  reviewed,
  approved,
}

extension ContentStatusLabels on ContentStatus {
  String get id {
    switch (this) {
      case ContentStatus.placeholder:
        return 'placeholder';
      case ContentStatus.draft:
        return 'draft';
      case ContentStatus.reviewed:
        return 'reviewed';
      case ContentStatus.approved:
        return 'approved';
    }
  }
}

/// Default lifecycle state for new or legacy content entries.
const ContentStatus kDefaultContentStatus = ContentStatus.placeholder;

ContentStatus? parseContentStatus(String raw) {
  final normalized = raw.trim().toLowerCase();
  for (final status in ContentStatus.values) {
    if (status.id == normalized) return status;
  }
  return null;
}
