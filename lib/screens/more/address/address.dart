import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:trentify/model/address.dart';

class AddressFormPage extends StatefulWidget {
  const AddressFormPage({super.key, this.initial});
  final Address? initial;

  @override
  State<AddressFormPage> createState() => _AddressFormPageState();
}

class _AddressFormPageState extends State<AddressFormPage> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _labelCtl;
  late final TextEditingController _noteCtl;
  late final TextEditingController _nameCtl;
  late final TextEditingController _phoneCtl;
  late final TextEditingController _line1Ctl;
  bool _isPrimary = false;

  @override
  void initState() {
    super.initState();
    final a = widget.initial;
    _labelCtl = TextEditingController(text: a?.label ?? '');
    _noteCtl =
        TextEditingController(); // optional note (not in Address model, but kept for UI)
    _nameCtl = TextEditingController(text: a?.fullName ?? '');
    _phoneCtl = TextEditingController(text: a?.phone ?? '');
    _line1Ctl = TextEditingController(text: a?.line1 ?? '');
    _isPrimary = a?.isMain ?? false;
  }

  @override
  void dispose() {
    _labelCtl.dispose();
    _noteCtl.dispose();
    _nameCtl.dispose();
    _phoneCtl.dispose();
    _line1Ctl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    final bottomSafe = MediaQuery.of(context).padding.bottom;
    final bottomKB = MediaQuery.of(context).viewInsets.bottom;
    final bottomPad = 16.0 + bottomSafe + bottomKB;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Address Details'),
        centerTitle: true,
      ),
      body: SafeArea(
        top: false,
        bottom: false,
        child: ListView(
          padding: EdgeInsets.fromLTRB(16, 12, 16, bottomPad + 64),
          children: [
            Row(
              children: [
                const Icon(Icons.location_on, color: Color(0xFF528F65)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _line1Ctl.text.isEmpty
                        ? 'Pin a location or enter address'
                        : _line1Ctl.text,
                    style: text.titleMedium,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            _label('Address Labels'),
            _Field(controller: _labelCtl, hint: 'Home / Work / Apartment'),

            _label('Note to Courier (optional)'),
            _Field(controller: _noteCtl, hint: 'Note'),

            _label("Recipient's Name"),
            _Field(controller: _nameCtl, hint: 'Full name', validator: _req),

            _label("Recipient's Phone Number"),
            _Field(
              controller: _phoneCtl,
              hint: '+1 111 467 378 399',
              keyboardType: TextInputType.phone,
              validator: _req,
            ),

            _label('Address'),
            _Field(
              controller: _line1Ctl,
              hint: 'Street, City, State ZIP',
              validator: _req,
            ),

            const SizedBox(height: 12),
            Row(
              children: [
                Checkbox(
                  value: _isPrimary,
                  onChanged: (v) => setState(() => _isPrimary = v ?? false),
                  activeColor: const Color(0xFF528F65),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(width: 6),
                Text('Set As Primary Address', style: text.titleMedium),
              ],
            ),
          ],
        ),
      ),

      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: SizedBox(
            height: 52,
            child: FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF528F65),
                shape: const StadiumBorder(),
              ),
              onPressed: _onSave,
              child: const Text(
                'Save',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ),
      ),
    );
  }

  String? _req(String? v) =>
      (v == null || v.trim().isEmpty) ? 'Required' : null;

  void _onSave() {
    if (!_validate()) return;

    final id =
        widget.initial?.id ?? DateTime.now().millisecondsSinceEpoch.toString();
    final addr = Address(
      id: id,
      label: _labelCtl.text.trim().isEmpty ? 'Home' : _labelCtl.text.trim(),
      fullName: _nameCtl.text.trim(),
      phone: _phoneCtl.text.trim(),
      line1: _line1Ctl.text.trim(),
      isMain: _isPrimary,
    );

    Navigator.pop(context, addr);
  }

  bool _validate() {
    final form = _formKey.currentState;
    if (form == null) {
      // simple manual checks since we didn't wrap fields in a Form widget
      if (_nameCtl.text.trim().isEmpty) return _shake('Name is required');
      if (_phoneCtl.text.trim().isEmpty) return _shake('Phone is required');
      if (_line1Ctl.text.trim().isEmpty) return _shake('Address is required');
      return true;
    }
    return form.validate();
  }

  bool _shake(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    return false;
  }
}

// ------- Small UI helpers -------

Widget _label(String t) => Padding(
  padding: const EdgeInsets.only(top: 14, bottom: 8),
  child: Text(t, style: const TextStyle(fontWeight: FontWeight.w600)),
);

class _Field extends StatelessWidget {
  const _Field({
    required this.controller,
    required this.hint,
    this.keyboardType,
    this.validator,
  });

  final TextEditingController controller;
  final String hint;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(14),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(hintText: hint, border: InputBorder.none),
        validator: validator,
      ),
    );
  }
}
