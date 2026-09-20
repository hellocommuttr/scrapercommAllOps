import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import '../../widgets/common.dart';
import 'explore_viewmodel.dart';

/// Drawn artwork for an offer: Commuttr's own gradient and a large vehicle icon. No photos, logos or liveries.
class OfferArtwork extends StatelessWidget {
  const OfferArtwork({super.key, required this.icon, this.size = 96});

  final String? icon;
  final double size;

  IconData get _glyph => switch (icon) {
    'train' => Icons.train_rounded,
    'tips' => Icons.lightbulb_outline_rounded,
    _ => Icons.directions_bus_rounded,
  };

  @override
  Widget build(BuildContext context) => ExcludeSemantics(
    child: Container(
      width: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Brand.orange, Brand.orangeDeep, Color(0xFF3A1206)],
        ),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            right: -size * 0.2,
            top: -size * 0.2,
            child: Container(
              width: size * 0.7,
              height: size * 0.7,
              decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withValues(alpha: 0.12)),
            ),
          ),
          Icon(_glyph, size: size * 0.6, color: Colors.white),
        ],
      ),
    ),
  );
}

/// One partner offer: bold two-line headline, body, orange "Learn more", artwork on the right.
class OfferBanner extends StatelessWidget {
  const OfferBanner({super.key, required this.offer, required this.onOpen});

  final PartnerOffer offer;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return AppCard(
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  offer.headline,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: context.text.titleLarge?.copyWith(fontWeight: FontWeight.w800, height: 1.15),
                ),
                const SizedBox(height: 6),
                Flexible(
                  child: Text(
                    offer.body,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: context.text.bodySmall?.copyWith(color: c.muted, fontSize: 13),
                  ),
                ),
                const Spacer(),
                FilledButton(
                  onPressed: onOpen,
                  style: FilledButton.styleFrom(
                    minimumSize: const Size(0, 40),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                  child: Text(offer.cta, semanticsLabel: '${offer.cta}: ${offer.headline.replaceAll('\n', ' ')}'),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          OfferArtwork(icon: offer.icon, size: 96),
        ],
      ),
    );
  }
}

/// Full-width offer carousel with page dots.
class OfferCarousel extends StatefulWidget {
  const OfferCarousel({super.key, required this.offers, required this.onOpen});

  final List<PartnerOffer> offers;
  final ValueChanged<PartnerOffer> onOpen;

  @override
  State<OfferCarousel> createState() => _OfferCarouselState();
}

class _OfferCarouselState extends State<OfferCarousel> {
  final _controller = PageController();
  int _page = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final offers = widget.offers;
    // Grows with the text size so the headline, body and button always fit.
    final height = 76 + MediaQuery.textScalerOf(context).scale(124);
    return Column(
      children: [
        SizedBox(
          height: height,
          child: PageView.builder(
            controller: _controller,
            itemCount: offers.length,
            onPageChanged: (i) => setState(() => _page = i),
            itemBuilder: (context, i) => Semantics(
              label: 'Offer ${i + 1} of ${offers.length}',
              child: Padding(
                padding: pagePadding,
                child: OfferBanner(offer: offers[i], onOpen: () => widget.onOpen(offers[i])),
              ),
            ),
          ),
        ),
        if (offers.length > 1) ...[
          const SizedBox(height: 10),
          ExcludeSemantics(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (var i = 0; i < offers.length; i++)
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    width: i == _page ? 18 : 7,
                    height: 7,
                    decoration: BoxDecoration(
                      color: i == _page ? Theme.of(context).colorScheme.primary : context.colors.cardBorder,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

/// "See all" for partner offers: every banner, stacked.
class OfferListPage extends StatelessWidget {
  const OfferListPage({super.key, required this.offers, required this.onOpen});

  final List<PartnerOffer> offers;
  final ValueChanged<PartnerOffer> onOpen;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Partner offers')),
    body: Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 720),
        child: offers.isEmpty
            ? const EmptyState(
                icon: Icons.local_offer_outlined,
                title: 'No offers right now',
                message: 'Offers and updates will appear here.',
              )
            : ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                itemCount: offers.length,
                separatorBuilder: (_, _) => const SizedBox(height: 12),
                itemBuilder: (context, i) => SizedBox(
                  height: 76 + MediaQuery.textScalerOf(context).scale(124),
                  child: OfferBanner(offer: offers[i], onOpen: () => onOpen(offers[i])),
                ),
              ),
      ),
    ),
  );
}

/// White circle with the operator's name set in neutral dark text (no logo artwork).
class OperatorLogo extends StatelessWidget {
  const OperatorLogo(this.label, {super.key, this.size = 44});

  final String label;
  final double size;

  @override
  Widget build(BuildContext context) => ExcludeSemantics(
    child: Container(
      width: size,
      height: size,
      padding: const EdgeInsets.all(5),
      decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
      alignment: Alignment.center,
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(
          label,
          textAlign: TextAlign.center,
          textScaler: TextScaler.noScaling,
          style: const TextStyle(color: Color(0xFF1A1A1A), fontSize: 10, fontWeight: FontWeight.w800, height: 1.05),
        ),
      ),
    ),
  );
}

/// A row in "Timetables": logo circle, name, what it offers, Bus/Train tag, chevron.
class OperatorTimetableRow extends StatelessWidget {
  const OperatorTimetableRow({
    super.key,
    required this.logo,
    required this.name,
    required this.train,
    required this.onTap,
  });

  final String logo;
  final String name;
  final bool train;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final subtitle = train ? 'Train timetables and routes' : 'Bus timetables and routes';
    final tag = train ? 'Train' : 'Bus';
    return Semantics(
      button: true,
      label: '$name, $subtitle',
      excludeSemantics: true,
      child: InkWell(
        onTap: onTap,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 68),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
            child: Row(
              children: [
                OperatorLogo(logo),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 2),
                      Text(subtitle, style: TextStyle(fontSize: 13, color: c.muted)),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                TagChip(tag, color: c.accentText),
                const SizedBox(width: 4),
                Icon(Icons.chevron_right, color: c.muted),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// A row in "Popular routes": orange-ringed vehicle icon, "A → B", "via …", duration pill when known, chevron.
class PopularRouteRow extends StatelessWidget {
  const PopularRouteRow({super.key, required this.route, required this.onTap});

  final PopularRoute route;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final accent = c.accentText;
    final duration = route.duration;
    return Semantics(
      button: true,
      label: [route.title, if (route.via.isNotEmpty) route.via, ?duration].join(', '),
      hint: 'Searches this trip on Home',
      excludeSemantics: true,
      child: InkWell(
        onTap: onTap,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 68),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: accent, width: 1.5),
                  ),
                  child: Icon(
                    route.isTrain ? Icons.train_outlined : Icons.directions_bus_outlined,
                    color: accent,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(route.title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                      if (route.via.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(route.via, style: TextStyle(fontSize: 13, color: c.muted)),
                      ],
                    ],
                  ),
                ),
                if (duration != null) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(color: c.infoSurface, borderRadius: BorderRadius.circular(20)),
                    child: Text(duration, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                  ),
                ],
                const SizedBox(width: 4),
                Icon(Icons.chevron_right, color: c.muted),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// "See all" for popular routes.
class PopularRouteListPage extends StatelessWidget {
  const PopularRouteListPage({super.key, required this.routes, required this.onOpen});

  final List<PopularRoute> routes;
  final ValueChanged<PopularRoute> onOpen;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Popular routes')),
    body: Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 720),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(0, 8, 0, 24),
          children: [
            Padding(
              padding: pagePadding,
              child: AppCard(
                padding: EdgeInsets.zero,
                child: Column(
                  children: [
                    for (var i = 0; i < routes.length; i++) ...[
                      if (i > 0) const Divider(indent: 72),
                      PopularRouteRow(
                        route: routes[i],
                        onTap: () {
                          Navigator.of(context).pop();
                          onOpen(routes[i]);
                        },
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
