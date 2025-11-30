import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:reactive_forms/reactive_forms.dart';
import '../models/item.dart';

class ItemFormDialog extends StatefulWidget {
  final Item? prefill;
  final String title;
  final String confirmText;
  final bool keepPrefillId;
  final void Function(Item) onSubmit;

  const ItemFormDialog({
    super.key,
    this.prefill,
    this.title = 'Add Item',
    this.confirmText = 'Save',
    this.keepPrefillId = true,
    required this.onSubmit
  });

  @override
  State<ItemFormDialog> createState() => _ItemFormDialogState();
}

class _ItemFormDialogState extends State<ItemFormDialog> {
  late final FormGroup itemForm;

  @override
  void initState() {
    super.initState();
    _initForm();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _initForm() {
    itemForm = FormGroup({
      'name': FormControl<String>(
        value: '',
        validators: [Validators.required, Validators.maxLength(50), Validators.minLength(2)]
      ),
      'type': FormControl<String>(
        value: widget.prefill?.type,
        validators: [Validators.required]
      ),
      'weight': FormControl<double>(
        value: null,
        validators: [Validators.required, Validators.max(5000), Validators.min(0.01)]
      ),
      'pricePerGram': FormControl<double>(
        value: null,
        validators: [Validators.required, Validators.max(9999999), Validators.min(1)]
      ),
      'makingCharge': FormControl<double>(
        value: 0,
        validators: [Validators.max(100), Validators.min(0)]
      ),
    });
    itemForm.statusChanged.listen((status) {
      _isFormValid.value = itemForm.valid;
    });
    if(widget.prefill != null) {
      itemForm.patchValue(widget.prefill!.toMap());
      // itemForm.markAllAsTouched();
      // itemForm.updateValueAndValidity();
      _isFormValid.value = itemForm.valid;
    }
  }

  final _isFormValid = ValueNotifier(false);

  void _handleSubmit() {

    final newItem = Item(
      name: itemForm.control('name').value,
      type: itemForm.control('type').value,
      weight: itemForm.control('weight').value,
      pricePerGram: itemForm.control('pricePerGram').value,
      makingCharge: itemForm.control('makingCharge').value ?? 0,
    );
    widget.onSubmit(newItem);
  }

  @override
  Widget build(BuildContext context) {
    final offWhite = Theme.of(context).colorScheme.onSurface;
    final cardColor = Theme.of(context).cardColor;
    return AlertDialog(
      backgroundColor: cardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadiusGeometry.circular(12)),
      title: Text(widget.title, style: TextStyle(color: offWhite),),
      titlePadding: EdgeInsets.only(top: 20, bottom: 10.0, right: 20, left: 20),
      content: _buildReactiveForm(),
      actionsOverflowAlignment: OverflowBarAlignment.start,
      actionsAlignment: MainAxisAlignment.spaceBetween,
      actionsOverflowButtonSpacing: 10.0,
      actions: [
        Row(
          mainAxisSize: MainAxisSize.min,
          spacing: 10,
          children: [
            Expanded(child: 
              OutlinedButton(
                onPressed: () => Navigator.pop(context, null),
                // style: TextButton.styleFrom(foregroundColor: offWhite.withValues(alpha: 0.8) ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: offWhite.withValues(alpha: 0.8),
                  // shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  side: BorderSide(color: offWhite.withValues(alpha: 0.3)),
                ),
                child: Text('Cancel'),
              ),
            ),
            Expanded(child: 
              ValueListenableBuilder<bool>(
                valueListenable: _isFormValid,
                builder: (context, isValid, child) {
                  return ElevatedButton(
                    onPressed: isValid ? _handleSubmit : null,
                    child: Text(widget.confirmText),
                  );
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildReactiveForm() {
    final offWhite = Theme.of(context).colorScheme.onSurface;
    final List<DropdownMenuItem<String>> items = [
      DropdownMenuItem(value: 'Gold', child: Text('Gold', style: TextStyle(color: offWhite)),),
      DropdownMenuItem(value: 'Silver', child: Text('Silver', style: TextStyle(color: offWhite)),),
      DropdownMenuItem(value: 'Dimond', child: Text('Dimond', style: TextStyle(color: offWhite)),)
    ];
    return ReactiveForm(
      formGroup: itemForm,
      child: SingleChildScrollView(
        child: Column(
          spacing: 12.0,
          children: [
            ReactiveTextField<String>(
              formControlName: 'name',
              decoration: const InputDecoration(labelText: 'Name / Design'),
              validationMessages: {
                ValidationMessage.required: (_) => 'Please enter name',
                ValidationMessage.maxLength: (_) => 'Name cannot exceed 50 characters',
              },
            ),
            ReactiveDropdownField<String>(
              formControlName: 'type',
              items: items,
              decoration: const InputDecoration(labelText: 'Type'),
              validationMessages: {
                ValidationMessage.required: (_) => 'Please select a type',
              },
            ),
            ReactiveTextField<double>(
              formControlName: 'weight',
              decoration: const InputDecoration(labelText: 'Weight (g)'),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
              ],
              validationMessages: {
                ValidationMessage.required: (_) => 'Please enter weight',
                ValidationMessage.number: (_) => 'Enter a valid number',
                ValidationMessage.min: (_) => 'Weight must be > 0',
                ValidationMessage.max: (_) => 'Weight too large',
              },
            ),
            ReactiveTextField<double>(
              formControlName: 'pricePerGram',
              decoration: const InputDecoration(labelText: 'Rate / g'),
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
              ],
              validationMessages: {
                ValidationMessage.required: (_) => 'Please enter rate',
                ValidationMessage.number: (_) => 'Enter a valid number',
                ValidationMessage.min: (_) => 'Rate must be ≥ 1',
                ValidationMessage.max: (_) => 'Rate too high',
              },
            ),
            ReactiveTextField<double>(
              formControlName: 'makingCharge',
              decoration: const InputDecoration(labelText: 'Making charge (%)'),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [ FilteringTextInputFormatter.allow(RegExp(r'^\d{0,3}(\.\d{0,2})?')),],
              validationMessages: {
                ValidationMessage.required: (_) => 'Please enter making charge',
                ValidationMessage.number: (_) => 'Enter a valid number',
                ValidationMessage.min: (_) => 'Making charge cannot be negative',
                ValidationMessage.max: (_) => 'Making charge cannot exceed 100%',
              },
            ),
          ]
        ),
      ),
    );
  }
}
