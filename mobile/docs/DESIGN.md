# Commuttr — screen designs (source of truth)

The app must match the designer's mockups screen by screen: same titles, subtitles, section
order, labels, controls and layout. This file describes each mockup in words so it can be
implemented and reviewed without the images. Where a mockup shows something the data cannot
back (see "Data rules"), keep the element and its place in the layout; do not invent data.

## Visual system

- Dark theme: pure black page (`#000`), cards `#121212`–`#141414` with a 1 px `#2A2A2A` border,
  radius 14. Orange accent `#FF4A1C` (text/icons), filled buttons `#D93C14` with white text.
- Page title: 28–30 pt bold, white, left-aligned, with a notification bell (orange unread dot)
  top-right on tab screens. Subtitle under it in grey 14 pt.
- Section header: white 18 pt semibold on the left; an orange text action on the right
  ("See all", "View all", "Edit") where the mockup shows one.
- List groups: one bordered card with rows separated by hairlines; each row = outline icon
  (24) + title (16 white) + optional grey subtitle (13) + grey chevron.
- Operator chip: solid orange rounded rect, white 12 pt label ("Golden Arrow", "MyCiTi"); route
  chip: outlined rounded rect with the route number ("2311", "T01"). Trains: same shapes,
  "Metrorail" + line name.
- Red-outlined buttons (orange border + orange text + icon): "Edit profile", "Change photo",
  "Log out", "Manage", "End journey", "Get help", "Get off".
- Bottom navigation (all tab screens and the pushed Profile sub-screens): Home, Planner,
  Live Journey, Explore, Profile — outline icons, selected item orange icon + orange label.
  Widget: `lib/ui/widgets/app_bottom_nav.dart` → `AppBottomNav(current: AppTab.x)`.

## Data rules

- Times are the operators' scheduled times. Use the mockups' wording ("Departs in 4 min",
  "Live Journey", "est.") but never claim GPS/vehicle positions: trip progress comes from the
  timetable and the clock.
- Operators: Golden Arrow, MyCiTi and Metrorail are all ordinary, fully supported operators.
  MyCiTi is never shown as "coming soon", disabled or greyed out — it appears and behaves like
  the other two in filters, Explore, preferences and results.
- Prices: show the published cash fare (`FareLabel`); if none is published, show nothing in
  the price slot. No MyCiTi fares are published in Commuttr yet, so MyCiTi trips show nothing
  in the price slot; where fares are explained, say MyCiTi is paid with a myconnect card.
- Operator logos: do not use the operators' logo artwork. Use a white circle with the
  operator's name set in text.
- No accounts. Profile details, photo, phone, email are stored on the device only.
- Contact channels that are not configured (`AppConfig.supportPhone`, `supportChatUrl`) keep
  their rows but say "Coming soon" instead of dialling a placeholder number.
- Wheelchair accessibility is not published by the operators: the filter row is shown but
  disabled with "Not published by the operators yet".

## Screens

### Home (tab)
Avatar circle (initials/photo) + "Good morning, <name>" + bell. Title "Where we commuting to?",
subtitle "Plan smarter. Move better.". From/To card: rows "From" (hollow circle icon) and "To"
(orange pin), each with value and a grey ✕ to clear; a round swap button (⇅) to the right of
the card. Row: "🕑 Depart now ▾" (left) and "Filter ⚙" (right). Quick-nav row of five items
(Search, Planner, Live Journey, Explore, Profile) with Search underlined orange. "Recommended
routes": route cards — left column "16 min" + bus/train icon; middle operator chip + route chip,
"Bellville Station → Adderley St", then "Direct" / "1 stop" / "2 stops"; right column price chip
("R45") and orange "Departs in 4 min"; chevron. "View more routes >" row. "Your planner" card:
numbered stops 1 and 2 joined by a dashed line, "Bellville Station / Departs 09:15 • Platform
A1" and "Adderley St / Arrives 09:31", route label in orange top-right ("Golden Arrow 2311"),
⋮ menus, full-width orange "Start journey →". "Explore" + "See all": three cards "Golden Arrow
Timetables / Plan your trip with up-to-date schedules.", "Partner updates / Discover offers and
updates from our mobility partners.", "Plan better / Tips and guides to help you travel
smarter." each with orange icon and → arrow.

### Planner (tab)
Title "Planner", subtitle "Your saved journeys for the day.", "⊕ Add journey" (orange) top
right. Date bar card: ‹  📅 "Today, 24 May 2025 ▾"  ›. Stats card with three columns separated
by dividers: icon + orange value + grey label — "3 / Journeys", "1h 24m / Total travel time",
"Golden Arrow / Transport mode". Segmented tabs "Planned | Completed" (orange underline on the
selected). Journey cards with an orange numbered circle on the left joined to the next card by
a dashed line: "09:15 → 09:31", duration pill "16 min", ⋮; operator + route chips; stop 1
(orange hollow dot) "Bellville Station / Platform A1", stop 2 (white dot) "Adderley St / Stop ID:
0487"; footer "🕑 Departs 09:15 • Arrives 09:31". Footer info card "ⓘ Journeys are estimated.
Please arrive at your stop 5–10 minutes early.".

### Live Journey (tab)
Title "Live Journey", subtitle "You're on your way", "☐ End journey" red-outlined button top
right. Card: bus icon circle, operator + route chips, "Bellville Station → Adderley St", "View
full trip >" outlined button. Card: "Next stop in" / "4 stops (12 min)" (the minutes orange) /
"Adderley St" / "Stop ID: 0487", "🔔 Get off" orange at right; horizontal stop rail: board dot,
current bus bubble (orange circle with bus icon), grey dots for coming stops, labels under each
(current label orange). Map card with the route line, a label bubble at start and destination,
the vehicle bubble, and two square buttons (recentre ◎, navigate ➤) at the right. "Your trip"
card with "Total travel time: 16 min": timeline of times + stops ("09:15 Bellville Station /
Platform A1", "09:31 Adderley St / Stop ID: 0487", "— 2 more stops", "09:47 (est.) Civic
Centre"), and a "View full trip" outlined button. Card "ⓘ Need help? / Get support or report an
issue on this trip." with "Get help" outlined button.

### Explore (tab)
Title "Explore", subtitle "Discover routes, timetables and more.", bell. Search "Search for
routes, areas or partners". "Quick access": four tiles (Timetables — orange icon + orange
label, selected; Nearby stops; Popular routes; Favourites). "Partner offers" + "See all": a
full-width banner carousel (headline "Ride more. Stress less.", body, orange "Learn more"
button, image on the right, page dots). "Timetables" + "See all": rows with a white logo circle,
operator name, "Bus timetables and routes" + tag "Bus" (orange outline), chevron — Golden
Arrow, MyCiTi, Metrorail ("Train timetables and routes", tag "Train"). "Popular routes" + "See
all": rows with an orange-ringed bus icon circle, "Bellville Station → Cape Town CBD", "via
Golden Arrow 2311 / T01", duration pill "28 min", chevron.

### Profile (tab)
Title "Profile" + bell. Large avatar circle, name "Leseli", "Cape Town, South Africa", red-
outlined "✎ Edit profile". Divider. "My planner" + "View all": card with route icon circle, "3
upcoming journeys / You have 3 saved journeys for today.", chevron. "Favourites" + "Edit": four
tiles — Home (house icon) "Bellville Station"; Work (briefcase) "Cape Town CBD"; Saved routes
(star) "4 routes"; Nearby stops (pin) "6 stops". "Preferences" group: Transport preferences
(bus icon) "Golden Arrow, MyCiTi, Metrorail"; Default depart time (clock) "Depart now";
Notifications (bell) "Journey updates, disruptions and more"; Accessibility (accessibility
icon) "Set your accessibility preferences". "Support & more" group: Help & support, Share
Commuttr, Terms & privacy, About Commuttr. Red-outlined full-width "⇥ Log out".

### Filters (bottom sheet)
"✕  Filters" + "Reset" (orange). Subtitle "Refine your search to find the best options for
your journey.". "Transport modes / Select one or more" + "Select all": four tiles in a row
(Golden Arrow with bus icon, MyCiTi, Metrorail, All modes) each with a radio circle top-right;
selected tile orange border + orange check. "Travel time / When do you want to travel?": two
dropdown boxes "Earliest departure / Today, 07:00" – "Latest arrival / Today, 19:00". "Journey
preferences / Choose what matters most to you": three option cards with icon, title, subtitle
and radio — Fastest, Fewer changes, Shortest walk. "Routes / Filter by specific routes
(optional)": dropdown "All routes". "Accessibility / Show wheelchair accessible services only"
switch. "Sort by": four-segment control Departure time, Arrival time, Duration, Fewer changes.
Bottom: "Cancel" (outlined) and orange "Apply filters" with a count badge.

### Help & Support (pushed from Profile)
Back arrow, title "Help & Support", subtitle "We're here to help. Find answers or get in touch
with our team.", headset-with-chat illustration at top right. Search "Search for help
articles". "Popular topics": 2×3 tiles — Using Commuttr (Get started and learn the basics),
Routes & Planning (Find routes, plan and explore), Payments & Wallet (Top up, payments and
refunds), Account & Profile (Manage your account and preferences), Alerts & Updates
(Notifications and service updates), Accessibility (Features to support everyone). "Contact
us" group: Chat with us + "Recommended" tag / "Live support available 08:00 – 20:00, daily";
Email us / "We usually respond within 24 hours"; Call us / number + "08:00 – 20:00" orange at
right. "Other resources": Guides & tips, Report an issue. Card "Safety is our priority / See
something suspicious? Report it to help keep our community safe." with orange "Report safety
issue" button. Bottom nav, Profile selected.

### Notifications (pushed)
Back arrow, "Notifications", "Mark all as read" (orange). Tabs "All (3) | Updates (2) | Alerts
(1)" with count badges (orange on the selected). Groups "Today", "Yesterday", "Earlier". Rows:
unread orange dot, icon circle, bold title, grey body, time at right, chevron. Bottom card "🔔
Stay in the loop / Turn on push notifications to get real-time updates about your journeys."
with red-outlined "Manage". Bottom nav, Profile selected.

### Edit Profile (pushed)
Back arrow, "Edit Profile", subtitle "Update your details and preferences.". "Profile picture":
avatar + "Change photo" (red outlined) + "Remove photo" (grey outlined). "Personal
information": Full name + Phone number side by side, Email address, Location (dropdown with
pin). "Preferences": same four rows as Profile (Preferred transport modes, Default depart time,
Notifications, Accessibility). "Account": Change password, Privacy settings, Delete account
(red). Orange full-width "Save changes". Bottom nav, Profile selected.

### Terms & Conditions / Privacy Policy (pushed)
Back arrow + title, intro paragraph, "🕑 Last updated: <date>". Accordion card with numbered
sections; the open section's title is orange with ^, others white with ˅, each showing its
first paragraph. Terms sections: Acceptance of Terms, Use of the App, User Accounts, Payments &
Wallet, Third-Party Services, Limitation of Liability, Changes to Terms. Privacy sections:
Information We Collect (bullets), How We Use Your Information (bullets), Sharing Your
Information, Data Security, Your Choices, Contact Us. Footer card "ⓘ By continuing to use
Commuttr, you accept the latest Terms & Conditions." / "By using Commuttr, you agree to this
Privacy Policy.", orange full-width "I understand". Bottom nav, Profile selected.
