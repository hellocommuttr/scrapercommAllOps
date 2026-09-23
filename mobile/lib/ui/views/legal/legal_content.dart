// LEGAL REVIEW REQUIRED BEFORE RELEASE: this text was drafted to match how the app
// actually behaves (SPEC §1, §4, §5.18) but has not been reviewed by a lawyer. Have
// the Terms and the Privacy Policy (POPIA) checked, then update [legalLastUpdated].
//
// Section headings follow the designer's mockups (docs/DESIGN.md) word for word; the
// bodies say what is true for Commuttr, which has no accounts and takes no payments.

import '../../../core/config.dart';

/// Which document the Legal screen shows. Passed as a route argument.
enum LegalKind {
  terms('Terms & Conditions'),
  privacy('Privacy Policy');

  const LegalKind(this.title);
  final String title;
}

const legalLastUpdated = '19 September 2026';

/// A numbered, collapsible part of a legal document. Each paragraph is shown as-is;
/// paragraphs starting with "• " are list items, and a paragraph containing the support
/// email address makes the address a tappable link.
class LegalSection {
  const LegalSection(this.title, this.paragraphs);
  final String title;
  final List<String> paragraphs;
}

class LegalDocument {
  const LegalDocument({required this.intro, required this.sections, required this.footer});
  final String intro;
  final List<LegalSection> sections;

  /// Shown in the info card under the sections.
  final String footer;
}

LegalDocument legalDocument(LegalKind kind) => switch (kind) {
  LegalKind.terms => _terms,
  LegalKind.privacy => _privacy,
};

const _email = AppConfig.supportEmail;

const _terms = LegalDocument(
  intro: 'Please read these terms carefully before using Commuttr.',
  sections: [
    LegalSection('Acceptance of Terms', [
      'These terms apply when you use the Commuttr app and website. By using Commuttr you agree to them. If you do '
          'not agree, please do not use Commuttr.',
      'Commuttr is an independent journey planner. It is not affiliated with, endorsed by or operated by Golden '
          'Arrow Bus Services (Pty) Ltd, Metrorail, the Passenger Rail Agency of South Africa (PRASA), MyCiTi or the '
          'City of Cape Town, or any other transport operator. We name Golden Arrow, MyCiTi and Metrorail only to '
          'describe the timetables and fares we use. '
          'Their names and trademarks belong to them.',
      'These terms are governed by the laws of the Republic of South Africa.',
    ]),
    LegalSection('Use of the App', [
      "Golden Arrow bus times and fares in Commuttr come from Golden Arrow's published timetables and fare tables. "
          "MyCiTi bus times come from the City of Cape Town's published MyCiTi route timetables, and MyCiTi stop "
          'positions come from OpenStreetMap. MyCiTi fares are not shown. Train times and fares come from '
          "Metrorail's published timetables and fare zones. We read them automatically, so "
          'mistakes can happen, and a timetable or fare may have changed since we last read it.',
      'Commuttr shows scheduled times only. It does not track vehicles and does not show delays, cancellations, '
          'breakdowns, route changes or other disruptions. Trip progress is worked out from the timetable and the '
          'clock. Some times are estimated between published stops and are marked as such.',
      'Please check with the operator, Golden Arrow at gabs.co.za, MyCiTi at www.myciti.org.za or Metrorail at '
          'metrorail.co.za, before you '
          'rely on a time or a fare, and allow extra time. You are responsible for your own travel decisions and '
          'your own safety.',
      'Please use Commuttr for personal journey planning. You must not:',
      '• try to disrupt, overload or break into the app, its server or its data;',
      '• scrape or bulk-download data from the Commuttr service;',
      '• present Commuttr, or information from it, as official Golden Arrow, MyCiTi or Metrorail information;',
      '• use Commuttr for anything unlawful.',
      'We may block access to the service if it is misused.',
    ]),
    LegalSection('User Accounts', [
      'Commuttr has no user accounts. There is no sign-up, no login and no password, and we will never ask you for '
          'one.',
      'The profile details you choose to add (such as your name, photo, phone number, email address and area), '
          'your planner, favourites and settings are stored only on this device. They are never uploaded, so we '
          'cannot see, restore or recover them. Use Export backup if you want to keep a copy, and keep backup files '
          'safe, because they are not encrypted.',
    ]),
    LegalSection('Payments & Wallet', [
      'Commuttr is free. It does not sell tickets, cards or passes, does not take payments, has no wallet and holds '
          'no money for you. There is nothing to top up and nothing to refund.',
      'Where an operator publishes a cash fare for a journey, Commuttr shows it. Fares are the last published '
          'figures, shown with the date they took effect. They may be out of date, may depend on the time of day, '
          'and are not a quote or a guarantee of what you will be charged. Where no fare is published, none is shown.',
      'Buy tickets from the operator: Metrorail tickets at the station, Golden Arrow tickets and cards as '
          'described on gabs.co.za, and MyCiTi myconnect cards as described on www.myciti.org.za. Refunds on tickets and cards are the operator\'s responsibility.',
    ]),
    LegalSection('Third-Party Services', [
      'For tickets, lost property, complaints and service information, contact the operator directly: Golden Arrow '
          'through gabs.co.za, MyCiTi through www.myciti.org.za, or Metrorail through metrorail.co.za. We cannot act for them or pass complaints on.',
      'Maps and place-name search use OpenStreetMap services. Map data © OpenStreetMap contributors.',
      'Links to operator websites, your email app and your phone dialler open services we do not run. Their own '
          'terms and privacy policies apply there.',
    ]),
    LegalSection('Limitation of Liability', [
      'Commuttr is provided free of charge, "as is" and "as available". We do not promise that it will be accurate, '
          'complete, up to date or always available.',
      'As far as the law allows, we are not liable for any loss or damage arising from your use of Commuttr or from '
          'relying on its information, for example a missed bus or train, a missed connection, lost time, a fare '
          'that differs from the one shown, or travel costs.',
      'Nothing in these terms limits rights you have under the Consumer Protection Act that cannot legally be '
          'excluded.',
    ]),
    LegalSection('Changes to Terms', [
      'We may update these terms as Commuttr changes. The date at the top shows when they last changed. If you keep '
          'using Commuttr after a change, the new terms apply.',
      'Questions about these terms? Email $_email.',
    ]),
  ],
  footer: 'By continuing to use Commuttr, you accept the latest Terms & Conditions.',
);

const _privacy = LegalDocument(
  intro: 'Your privacy is important to us. This policy explains how we collect, use and protect your information.',
  sections: [
    LegalSection('Information We Collect', [
      'Commuttr has no accounts and is built to need as little of your information as possible, in line with the '
          'Protection of Personal Information Act (POPIA). We process only:',
      '• Trip searches: the stops or map points you plan between, and the travel date and time, sent to the '
          'Commuttr server to work out your trip.',
      '• Place searches: the text you type to find a place by name, sent to the Commuttr server.',
      '• Server logs: like most web services, the Commuttr server logs the requests it receives, including your IP '
          'address, the time and what was searched.',
      '• Reports and emails: what you choose to send us, including your email address.',
      '• How the network is used: which trips and places are searched, how many results came back, and an id this '
          'app makes on first launch. The id is a random value. It is not a device identifier, it is not linked to '
          'your name, number, email or account, and it exists so that ten searches from one phone are not counted '
          'as ten people. You can stop all of this and forget the id in Preferences, under Privacy.',
      'Your location is used only when you tap "Use my location" or "Nearby stops", and only with your permission. '
          'It is used on your device to find nearby stops and is not stored or sent to us, unless you choose to '
          'search from a map point, which is sent as a trip search.',
      'These stay on this device (or in this browser, on the web) and are never uploaded: your profile details and '
          'photo, planner, favourites, recent searches, settings and saved copies of timetables.',
    ]),
    LegalSection('How We Use Your Information', [
      '• To plan your trips and find the places you search for.',
      '• To run the service, fix problems and prevent abuse (server logs).',
      '• To answer your reports and emails and improve Commuttr.',
      '• To measure how Cape Town travels: which trips, places and routes are searched, at what times, and where '
          'people look for a service that does not exist. We may publish or sell this as counts and patterns, and '
          'we may share it with transport operators, the City of Cape Town and researchers, so that planning is '
          'based on what commuters actually look for.',
      'What is sold or shared is always counts and patterns, never you. It carries no name, number, email, account '
          'or IP address, and never the id this app made. Before anything leaves us it is grouped so that no row '
          'describes one person or one phone, and we do not attempt to identify anybody from it or allow anyone '
          'else to.',
      'We do not use your information for advertising or profiling. Commuttr is a general-audience travel tool and '
          'does not knowingly collect information from children.',
    ]),
    LegalSection('Sharing Your Information', [
      '• We never sell, rent or trade your personal information, and there is none attached to a name here to '
          'sell. We do sell and share aggregate counts and patterns, as described above.',
      '• Place-name searches are forwarded by our server to OpenStreetMap Nominatim to find the place. Nominatim '
          'receives the search text from our server, not your IP address.',
      '• When maps are shown, map tiles are downloaded from OpenStreetMap servers, which see your IP address, as for '
          'any website. You can turn maps off in Preferences.',
      '• Commuttr has no advertising, no third-party trackers and no analytics SDKs. How the network is used is '
          'counted by our own server, and by nobody else.',
      '• We may share aggregate counts with Golden Arrow, Metrorail, PRASA, MyCiTi, the City of Cape Town and '
          'others. We do not share your searches, your reports or anything about you individually with them.',
      '• We will disclose information only if the law requires us to.',
    ]),
    LegalSection('Data Security', [
      // OPERATOR TO CONFIRM: the 90-day retention below must be confirmed by whoever
      // runs the Commuttr API, and the server's log rotation set to match, before release.
      'Because there is no account, there is no profile of you on our server to lose. Server logs are used only for '
          'the purposes above, are available only to the people who run Commuttr, and are kept for up to 90 days '
          'and then deleted.',
      // OPERATOR TO CONFIRM: set a job that strips device ids older than 12 months, so
      // the sentence below stays true without anybody having to remember.
      'Searches recorded for counting carry no IP address. The id this app made is kept for up to 12 months and '
          'then removed from those rows, which leaves the counts and takes away the thread between them.',
      'Information on your device is protected by your device\'s own security, such as its screen lock. Backup files '
          'you export are not encrypted, so keep them somewhere safe.',
    ]),
    LegalSection('Your Choices', [
      'You decide whether Commuttr may use your location or show notifications, and you can change this at any time '
          'in your phone\'s settings. You can turn maps off in Preferences.',
      'Information on your device is under your control: delete it with Profile → Offline & data → Erase '
          'everything, or by uninstalling the app or clearing your browser data.',
      'Under POPIA you have the right to ask what personal information we hold about you, to have it corrected or '
          'deleted, and to object to how it is processed. The only information about you we hold is in our server '
          'logs and any emails you send us, and we can act on those. You may also complain to the Information '
          'Regulator of South Africa (inforegulator.org.za).',
    ]),
    LegalSection('Contact Us', [
      // CONFIRM BEFORE RELEASE: the Information Officer's name and address, and that
      // AppConfig.supportEmail is the right contact for POPIA requests.
      'For privacy questions or to exercise your rights, contact our Information Officer at $_email.',
      'If we change what we collect or how we use it, we will update this policy and the date at the top. '
          'Significant changes will also be announced in the app.',
    ]),
  ],
  footer: 'By using Commuttr, you agree to this Privacy Policy.',
);
