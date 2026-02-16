import 'package:everline/features/add/bloc/add_cubit.dart';
import 'package:everline/features/add/bloc/add_state.dart';
import 'package:everline/features/add/widgets/image_picker_widget.dart';
import 'package:everline/features/add/widgets/select_gender_widget.dart';
import 'package:everline/shared/widgets/text_field_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class PersonalInfoStep extends StatelessWidget {
  const PersonalInfoStep({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
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
              previous.firstName != current.firstName ||
              previous.showErrors != current.showErrors,
          builder: (context, state) {
            return TextFieldWidget(
              padding: EdgeInsets.all(16),
              requiredMark: true,
              label: 'First Name',
              placeholder: 'Enter your first name',
              onChanged: (value) {
                context.read<AddCubit>().firstNameChanged(value);
              },
              error: state.showErrors && state.firstName.displayError != null
                  ? 'First name is required'
                  : null,
            );
          },
        ),

        BlocBuilder<AddCubit, AddMemberState>(
          buildWhen: (previous, current) =>
              previous.lastName != current.lastName ||
              previous.showErrors != current.showErrors,
          builder: (context, state) {
            return TextFieldWidget(
              padding: EdgeInsets.all(16),
              requiredMark: true,
              label: 'Last Name',
              placeholder: 'Enter your last name',
              onChanged: (value) {
                context.read<AddCubit>().lastNameChanged(value);
              },
              error: state.showErrors && state.lastName.displayError != null
                  ? 'Last name is required'
                  : null,
            );
          },
        ),

        TextFieldWidget(
          padding: EdgeInsets.all(16),
          label: 'Nick Name',
          placeholder: 'Enter your nick name',
          onChanged: (value) {
            context.read<AddCubit>().nickNameChanged(value);
          },
        ),

        Row(
          children: [
            Expanded(
              child: BlocBuilder<AddCubit, AddMemberState>(
                buildWhen: (previous, current) =>
                    previous.dateOfBirth != current.dateOfBirth ||
                    previous.showErrors != current.showErrors,
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
                          buttonDecoration: ShadDecoration(
                            color: Colors.grey[50],
                            border: ShadBorder.all(
                              width: 1,
                              radius: const BorderRadius.all(
                                Radius.circular(8),
                              ),
                            ),
                          ),
                          height: 52,
                          buttonPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                          ),
                          captionLayout: ShadCalendarCaptionLayout.dropdown,
                          placeholder: const Text('Born on'),
                          onChanged: (date) {
                            context.read<AddCubit>().dateOfBirthChanged(date);
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
                    previous.gender != current.gender ||
                    previous.showErrors != current.showErrors,
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
                            context.read<AddCubit>().genderChanged(gender);
                          }
                        },
                      ),
                      if (state.showErrors && state.gender.displayError != null)
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
      ],
    );
  }
}
