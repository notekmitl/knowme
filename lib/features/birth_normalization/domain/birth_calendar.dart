/// The calendar system the raw birth date is expressed in.
///
/// Today every raw input is a civil **Gregorian** date; this enum exists so the
/// normalization contract can grow (e.g. a Thai solar/lunar source date) without
/// changing [NormalizedBirth]'s shape.
enum BirthCalendar {
  gregorian,
}
