import 'package:flutter/material.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:swarn_abhushan/models/user.dart';
import 'package:swarn_abhushan/utils/constant.dart';

typedef UserSavedCallback = void Function(User user);
typedef FormCreatedCallback = void Function(FormGroup form, Stream<ControlStatus> statusStream);

class UserReactiveForm extends StatefulWidget {
  final User? user;
  final FormCreatedCallback? onFormCreated;
  final UserSavedCallback? onSaved;
  final void Function(bool)? onFormStatusChange;

  const UserReactiveForm({
    super.key,
    this.user,
    this.onFormCreated,
    this.onSaved,
    this.onFormStatusChange,
  });

  @override
  State<UserReactiveForm> createState() => _UserReactiveFormState();
}

class _UserReactiveFormState extends State<UserReactiveForm> {
  late final FormGroup form;
  /// ---------- Build Reactive FormGroup ----------
  FormGroup buildForm() {
    return fb.group(<String, Object>{
      'name': FormControl<String>(
        value: widget.user?.name ?? '',
        validators: [Validators.required,
          Validators.minLength(2),
          Validators.maxLength(25),
        ],
      ),
      'mobile': FormControl<String>(
        value: widget.user?.mobile ?? '',
        validators: [
          Validators.required,
          Validators.number(allowNegatives: false, allowNull: false, allowedDecimals: 0),
          Validators.minLength(10),
          Validators.maxLength(10),
        ],
      ),
      'email': FormControl<String>(
        value: widget.user?.email ?? '',
        validators: [Validators.email],
      ),
      'address': FormControl<String>(
        value: widget.user?.address ?? '',
        validators: [ Validators.maxLength(50) ],
      ),
    });
  }

  /// ---------- Submit ----------
  // Future<User?> _submit(FormGroup form) async {
  //   if (form.invalid) {
  //     form.markAllAsTouched();
  //     return null;
  //   }

  //   final newUser = User(
  //     uuid: widget.user?.uuid,
  //     name: (form.value['name'] ?? "").toString(),
  //     mobile: (form.value['mobile'] ?? "").toString(),
  //     email: (form.value['email'] ?? "").toString(),
  //     address: (form.value['address'] ?? "").toString(),
  //   );

  //   widget.onSaved?.call(newUser);
  //   return newUser;
  // }

  @override
  void initState() {
    super.initState();
    form = buildForm();
    // if (widget.onFormCreated != null) {
    //   widget.onFormCreated!(form);
    // }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.onFormCreated?.call(form, form.statusChanged);
      form.statusChanged.listen((_) {
        // Can be used to monitor form status changes if needed
        widget.onFormStatusChange?.call(form.valid);
      });
    });
  }
  
  @override
  void dispose() {
    form.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // final isEditing = widget.user != null;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: ReactiveForm(
        formGroup: form,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            spacing: 16.0,
            children: [
              Center(
                child: ClipOval(
                  child: Container(
                    width: 80,
                    height: 80,
                    color: Color.fromARGB(255, 45, 45, 45),
                    alignment: Alignment.center,
                    child: widget.user != null ? Text( widget.user!.name[0].toUpperCase(),
                      style: const TextStyle(fontSize: 32, color: Colors.white),
                    ) : Icon(Icons.account_circle, size: 40.0,),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              ReactiveTextField<String>(
                formControlName: 'name',
                decoration: InputDecoration(label: CommonUtils.buildLabel("Name", "name", form)),
                validationMessages: {
                  ValidationMessage.required: (_) => "Name is required",
                },
              ),

              ReactiveTextField<String>(
                formControlName: 'mobile',
                decoration: InputDecoration(label: CommonUtils.buildLabel("Mobile", "mobile", form)),
                keyboardType: TextInputType.phone,
                validationMessages: {
                  ValidationMessage.required: (_) => "Mobile is required",
                  ValidationMessage.number: (_) => "Enter valid number",
                  ValidationMessage.minLength: (_) => "Enter 10 digits",
                  ValidationMessage.maxLength: (_) => "Enter 10 digits",
                },
              ),

              ReactiveTextField<String>(
                formControlName: 'email',
                decoration: InputDecoration(label: CommonUtils.buildLabel("Email", "email", form)),
                validationMessages: {
                  ValidationMessage.email: (_) => "Invalid email format",
                },
              ),

              ReactiveTextField<String>(
                formControlName: 'address',
                decoration: InputDecoration(label: CommonUtils.buildLabel("Address", "address", form)),
                maxLines: 2,
              ),

              // ElevatedButton(
              //   onPressed: () => _submit(form),
              //   child: Text(isEditing ? "Update" : "Create"),
              // )
            ],
          ),
        ),
      ),
    );
  }
}
