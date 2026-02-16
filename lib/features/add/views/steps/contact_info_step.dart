import 'package:everline/features/add/bloc/add_cubit.dart';
import 'package:everline/features/add/bloc/add_state.dart';
import 'package:everline/shared/widgets/text_field_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class ContactInfoStep extends StatelessWidget {
  const ContactInfoStep({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: 12,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        TextFieldWidget(
          padding: EdgeInsets.all(16),
          label: 'Email',
          placeholder: 'Enter your email',
          keyboardType: TextInputType.emailAddress,
          onChanged: (value) {
            context.read<AddCubit>().emailChanged(value);
          },
        ),

        BlocBuilder<AddCubit, AddMemberState>(
          buildWhen: (previous, current) =>
              previous.phoneNumber != current.phoneNumber ||
              previous.showErrors != current.showErrors,
          builder: (context, state) {
            return TextFieldWidget(
              padding: EdgeInsets.all(16),
              requiredMark: true,
              label: 'Phone Number',
              placeholder: 'Enter your phone number',
              keyboardType: TextInputType.phone,
              onChanged: (value) {
                context.read<AddCubit>().phoneNumberChanged(value);
              },
              error: state.showErrors && state.phoneNumber.displayError != null
                  ? 'Phone number is required'
                  : null,
            );
          },
        ),

        BlocBuilder<AddCubit, AddMemberState>(
          buildWhen: (previous, current) =>
              previous.address != current.address ||
              previous.showErrors != current.showErrors,
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
                  decoration: ShadDecoration(
                    color: Colors.grey[50],
                    border: ShadBorder.all(
                      width: 1,
                      radius: const BorderRadius.all(Radius.circular(12)),
                    ),
                  ),
                  padding: EdgeInsets.all(16),
                  id: 'address',
                  placeholder: const Text('Enter your address'),
                  description: const Text('Please provide your address.'),
                  onChanged: (value) {
                    context.read<AddCubit>().addressChanged(value);
                  },
                ),
                if (state.showErrors && state.address.displayError != null)
                  Padding(
                    padding: const EdgeInsets.only(left: 4),
                    child: Text(
                      'Address is required',
                      style: ShadTheme.of(context).textTheme.small.copyWith(
                        color: ShadTheme.of(context).colorScheme.destructive,
                      ),
                    ),
                  ),
              ],
            );
          },
        ),

        BlocBuilder<AddCubit, AddMemberState>(
          buildWhen: (previous, current) =>
              previous.city != current.city ||
              previous.showErrors != current.showErrors,
          builder: (context, state) {
            return TextFieldWidget(
              padding: EdgeInsets.all(16),
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
              previous.state != current.state ||
              previous.showErrors != current.showErrors,
          builder: (context, state) {
            return TextFieldWidget(
              padding: EdgeInsets.all(16),
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
          padding: EdgeInsets.all(16),
          label: 'Occupation',
          placeholder: 'Enter your occupation',
          onChanged: (value) {
            context.read<AddCubit>().occupationChanged(value);
          },
        ),
      ],
    );
  }
}
