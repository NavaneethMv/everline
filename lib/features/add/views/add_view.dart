import 'package:everline/features/add/bloc/add_cubit.dart';
import 'package:everline/features/add/bloc/add_state.dart';
import 'package:everline/features/add/widgets/image_picker_widget.dart';
import 'package:everline/features/add/widgets/select_gender_widget.dart';
import 'package:everline/shared/widgets/text_field_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class AddView extends StatelessWidget {
  const AddView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<AddCubit, AddMemberState>(
      listenWhen: (previous, current) => previous.status != current.status,
      listener: (context, state) {
        if (state.status == AddMemberStatus.success) {
          ShadToaster.of(context).show(
            const ShadToast(
              title: Text("Success"),
              description: Text('Member added successfully!'),
              alignment: Alignment.topCenter,
            ),
          );
          context.goNamed('tree');
        } else if (state.status == AddMemberStatus.failure) {
          ShadToaster.of(context).show(
            ShadToast.destructive(
              title: Text("Failure"),
              description: Text(state.errorMessage ?? 'Failed to add member'),
              alignment: Alignment.topCenter,
            ),
          );
        }
      },
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(
            top: 80,
            left: 24,
            right: 24,
            bottom: 80,
          ),
          child: Column(
            spacing: 12,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ImagePickerWidget(
                onImageSelected: (path) {
                  context.read<AddCubit>().profileImageChanged(path);
                },
              ),

              BlocBuilder<AddCubit, AddMemberState>(
                buildWhen: (previous, current) =>
                    previous.firstName != current.firstName,
                builder: (context, state) {
                  return TextFieldWidget(
                    requiredMark: true,
                    label: 'First Name',
                    placeholder: 'Enter your first name',
                    onChanged: (value) {
                      context.read<AddCubit>().firstNameChanged(value);
                    },
                    error:
                        state.showErrors && state.firstName.displayError != null
                        ? 'First name is required'
                        : null,
                  );
                },
              ),

              BlocBuilder<AddCubit, AddMemberState>(
                buildWhen: (previous, current) =>
                    previous.lastName != current.lastName,
                builder: (context, state) {
                  return TextFieldWidget(
                    requiredMark: true,
                    label: 'Last Name',
                    placeholder: 'Enter your last name',
                    onChanged: (value) {
                      context.read<AddCubit>().lastNameChanged(value);
                    },
                    error:
                        state.showErrors && state.lastName.displayError != null
                        ? 'Last name is required'
                        : null,
                  );
                },
              ),

              TextFieldWidget(
                label: 'Nick Name',
                placeholder: 'Enter your nick name',
                onChanged: (value) {
                  context.read<AddCubit>().nickNameChanged(value);
                },
              ),

              const ShadSeparator.horizontal(
                thickness: 4,
                radius: BorderRadius.all(Radius.circular(4)),
              ),

              Row(
                children: [
                  Expanded(
                    child: BlocBuilder<AddCubit, AddMemberState>(
                      buildWhen: (previous, current) =>
                          previous.dateOfBirth != current.dateOfBirth,
                      builder: (context, state) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          spacing: 4.0,
                          children: [
                            Row(
                              children: [
                                Text(
                                  'Date of Birth',
                                  style: ShadTheme.of(context).textTheme.small,
                                ),
                                const SizedBox(width: 4),
                                const Text(
                                  '*',
                                  style: TextStyle(
                                    color: Colors.red,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 600),
                              child: ShadDatePicker(
                                captionLayout:
                                    ShadCalendarCaptionLayout.dropdown,
                                placeholder: const Text('Born on'),
                                onChanged: (date) {
                                  context.read<AddCubit>().dateOfBirthChanged(
                                    date,
                                  );
                                },
                              ),
                            ),
                            if (state.showErrors &&
                                state.dateOfBirth.displayError != null)
                              Padding(
                                padding: const EdgeInsets.only(left: 4),
                                child: Text(
                                  'Date of birth is required',
                                  style: ShadTheme.of(context).textTheme.small
                                      .copyWith(
                                        color: ShadTheme.of(
                                          context,
                                        ).colorScheme.destructive,
                                      ),
                                ),
                              ),
                          ],
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 8),

                  Expanded(
                    child: BlocBuilder<AddCubit, AddMemberState>(
                      buildWhen: (previous, current) =>
                          previous.gender != current.gender,
                      builder: (context, state) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          spacing: 4.0,
                          children: [
                            Row(
                              children: [
                                Text(
                                  'Gender',
                                  style: ShadTheme.of(context).textTheme.small,
                                ),
                                const SizedBox(width: 4),
                                const Text(
                                  '*',
                                  style: TextStyle(
                                    color: Colors.red,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            SelectGenderWidget(
                              onChanged: (gender) {
                                if (gender != null) {
                                  context.read<AddCubit>().genderChanged(
                                    gender,
                                  );
                                }
                              },
                            ),
                            if (state.showErrors &&
                                state.gender.displayError != null)
                              Padding(
                                padding: const EdgeInsets.only(left: 4),
                                child: Text(
                                  'Gender is required',
                                  style: ShadTheme.of(context).textTheme.small
                                      .copyWith(
                                        color: ShadTheme.of(
                                          context,
                                        ).colorScheme.destructive,
                                      ),
                                ),
                              ),
                          ],
                        );
                      },
                    ),
                  ),
                ],
              ),

              TextFieldWidget(
                label: 'Email',
                placeholder: 'Enter your email',
                keyboardType: TextInputType.emailAddress,
                onChanged: (value) {
                  context.read<AddCubit>().emailChanged(value);
                },
              ),

              BlocBuilder<AddCubit, AddMemberState>(
                buildWhen: (previous, current) =>
                    previous.phoneNumber != current.phoneNumber,
                builder: (context, state) {
                  return TextFieldWidget(
                    requiredMark: true,
                    label: 'Phone Number',
                    placeholder: 'Enter your phone number',
                    keyboardType: TextInputType.phone,
                    onChanged: (value) {
                      context.read<AddCubit>().phoneNumberChanged(value);
                    },
                    error:
                        state.showErrors &&
                            state.phoneNumber.displayError != null
                        ? 'Phone number is required'
                        : null,
                  );
                },
              ),

              const ShadSeparator.horizontal(
                thickness: 4,
                radius: BorderRadius.all(Radius.circular(4)),
              ),

              BlocBuilder<AddCubit, AddMemberState>(
                buildWhen: (previous, current) =>
                    previous.address != current.address,
                builder: (context, state) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 4.0,
                    children: [
                      Row(
                        children: [
                          const Text('Address'),
                          const SizedBox(width: 4),
                          const Text(
                            '*',
                            style: TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      ShadTextareaFormField(
                        id: 'address',
                        placeholder: const Text('Enter your address'),
                        description: const Text('Please provide your address.'),
                        onChanged: (value) {
                          context.read<AddCubit>().addressChanged(value);
                        },
                      ),
                      if (state.showErrors &&
                          state.address.displayError != null)
                        Padding(
                          padding: const EdgeInsets.only(left: 4),
                          child: Text(
                            'Address is required',
                            style: ShadTheme.of(context).textTheme.small
                                .copyWith(
                                  color: ShadTheme.of(
                                    context,
                                  ).colorScheme.destructive,
                                ),
                          ),
                        ),
                    ],
                  );
                },
              ),

              BlocBuilder<AddCubit, AddMemberState>(
                buildWhen: (previous, current) => previous.city != current.city,
                builder: (context, state) {
                  return TextFieldWidget(
                    requiredMark: true,
                    label: 'City',
                    placeholder: 'Enter your city',
                    onChanged: (value) {
                      context.read<AddCubit>().cityChanged(value);
                    },
                    error: state.showErrors && state.city.displayError != null
                        ? 'City is required'
                        : null,
                  );
                },
              ),

              BlocBuilder<AddCubit, AddMemberState>(
                buildWhen: (previous, current) =>
                    previous.state != current.state,
                builder: (context, state) {
                  return TextFieldWidget(
                    requiredMark: true,
                    label: 'State',
                    placeholder: 'Enter your state',
                    onChanged: (value) {
                      context.read<AddCubit>().stateChanged(value);
                    },
                    error: state.showErrors && state.state.displayError != null
                        ? 'State is required'
                        : null,
                  );
                },
              ),

              TextFieldWidget(
                label: 'Occupation',
                placeholder: 'Enter your occupation',
                onChanged: (value) {
                  context.read<AddCubit>().occupationChanged(value);
                },
              ),

              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                height: 48,
                child: BlocBuilder<AddCubit, AddMemberState>(
                  buildWhen: (previous, current) =>
                      previous.isValid != current.isValid ||
                      previous.status != current.status,
                  builder: (context, state) {
                    return ShadButton(
                      enabled:
                          state.isValid &&
                          state.status != AddMemberStatus.loading,
                      onPressed: () {
                        context.read<AddCubit>().submit();
                      },
                      child: state.status == AddMemberStatus.loading
                          ? SizedBox.square(
                              dimension: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: ShadTheme.of(
                                  context,
                                ).colorScheme.primaryForeground,
                              ),
                            )
                          : const Text('Submit'),
                    );
                  },
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
