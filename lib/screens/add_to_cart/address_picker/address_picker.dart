import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:trentify/model/address.dart';
import 'package:trentify/router/app_routes.dart';

class AddressPickerPage extends StatefulWidget {
  const AddressPickerPage({
    super.key,
    required this.addresses,
    this.initialSelectedId,
  });

  final List<Address> addresses;
  final String? initialSelectedId;

  @override
  State<AddressPickerPage> createState() => _AddressPickerPageState();
}

class _AddressPickerPageState extends State<AddressPickerPage> {
  late List<Address> _list;
  String? _selectedId;

  @override
  void initState() {
    super.initState();
    _list = List<Address>.from(widget.addresses);
    _selectedId =
        widget.initialSelectedId ?? (_list.isNotEmpty ? _list.first.id : null);
  }

  @override
  Widget build(BuildContext context) {
    // ...
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Choose Delivery Address'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Add New Address',
            onPressed: () async {
              // CREATE
              final created = await context.push<Address>(
                AppRoutes.addressForm,
              );
              if (created != null) {
                setState(() {
                  _list = [..._list, created];
                  _selectedId = created.id;
                });
              }
            },
          ),
        ],
      ),
      body: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 120),
        itemCount: _list.length,
        separatorBuilder: (_, __) => const SizedBox(height: 14),
        itemBuilder: (_, i) {
          final a = _list[i];
          final selected = a.id == _selectedId;
          return _AddressCard(
            address: a,
            selected: selected,
            onTap: () => setState(() => _selectedId = a.id),
          );
        },
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          child: SizedBox(
            height: 52,
            child: FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF528F65),
                shape: const StadiumBorder(),
              ),
              onPressed: _selectedId == null
                  ? null
                  : () {
                      final addr = _list.firstWhere((e) => e.id == _selectedId);
                      Navigator.pop(context, addr); // return chosen
                    },
              child: const Text(
                'OK',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AddressCard extends StatelessWidget {
  const _AddressCard({
    required this.address,
    required this.selected,
    required this.onTap,
  });

  final Address address;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    final borderColor = selected ? const Color(0xFF528F65) : Colors.transparent;
    final surface = cs.surfaceContainerHighest;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: selected ? borderColor : Colors.transparent,
              width: 1.4,
            ),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // top row: label + chip + share icon
              // inside _AddressCard top row actions
              IconButton(
                tooltip: 'Edit',
                icon: const Icon(Icons.edit_outlined, size: 20),
                onPressed: () async {
                  final updated = await context.push<Address>(
                    AppRoutes.addressForm,
                    extra: address,
                  );
                  if (updated != null) {
                    // bubble a callback up or handle via state mgmt
                  }
                },
              ),
              Row(
                children: [
                  Text(
                    address.label,
                    style: text.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (address.isMain)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0x1A528F65),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFF528F65)),
                      ),
                      child: const Text(
                        'Main Address',
                        style: TextStyle(
                          color: Color(0xFF528F65),
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  const Spacer(),
                  IconButton(
                    tooltip: 'Share',
                    onPressed: () {}, // TODO: share address
                    icon: const Icon(Icons.share_outlined, size: 20),
                  ),
                ],
              ),
              Divider(color: cs.outlineVariant.withOpacity(.35)),
              const SizedBox(height: 6),

              // name + phone
              RichText(
                text: TextSpan(
                  style: text.titleMedium?.copyWith(color: cs.onSurface),
                  children: [
                    TextSpan(
                      text: address.fullName,
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                    const TextSpan(text: '  '),
                    TextSpan(
                      text: '(${address.phone})',
                      style: const TextStyle(fontWeight: FontWeight.w400),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),

              // line1
              Text(address.line1, style: text.bodyLarge),
              const SizedBox(height: 12),

              // pinpoint + check
              Row(
                children: [
                  const Icon(
                    Icons.location_on_outlined,
                    size: 18,
                    color: Colors.black54,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Pinpoint already',
                    style: text.bodyMedium?.copyWith(
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                  const Spacer(),
                  if (selected)
                    const Icon(Icons.check, color: Color(0xFF528F65)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
