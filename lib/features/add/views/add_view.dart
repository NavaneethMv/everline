import 'dart:developer';

import 'package:everline/features/add/bloc/add_cubit.dart';
import 'package:everline/features/add/bloc/add_state.dart';
import 'package:everline/features/add/views/steps/contact_info_step.dart';
import 'package:everline/features/add/views/steps/personal_info_step.dart';
import 'package:everline/features/add/views/steps/relationships_step.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class AddView extends StatefulWidget {
  const AddView({super.key});

  @override
  State<AddView> createState() => _AddViewState();
}

class _AddViewState extends State<AddView> {
  AddCubit? _addCubit;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _addCubit ??= context.read<AddCubit>();
  }

  @override
  void dispose() {
    // Reset the form when leaving the add view
    _addCubit?.resetForm();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AddCubit, AddMemberState>(
      listenWhen: (previous, current) => previous.status != current.status,
      listener: (context, state) {
        if (state.status == AddMemberStatus.success) {
          ShadToaster.of(context).show(
            ShadToast(
              title: const Text("Success"),
              description: Text(
                state.isEditMode
                    ? 'Member updated successfully!'
                    : 'Member added successfully!',
              ),
              alignment: Alignment.topCenter,
            ),
          );
          context.goNamed('tree');
        } else if (state.status == AddMemberStatus.failure) {
          log(state.errorMessage ?? 'Failed to add member');
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
        child: Column(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 16, 12, 0),
                child: Container(
                  decoration: BoxDecoration(
                    color: ShadTheme.of(context).colorScheme.background,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: -1.05),
                        blurRadius: 9,
                        offset: const Offset(-1, 2),
                      ),
                    ],
                  ),

                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        BlocBuilder<AddCubit, AddMemberState>(
                          builder: (context, state) {
                            return Container(
                              padding: const EdgeInsets.symmetric(
                                vertical: 16,
                                horizontal: 24,
                              ),
                              child: Column(
                                spacing: 16,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        _getStepTitle(
                                          state.currentStep,
                                          state.isEditMode,
                                        ),
                                        style: ShadTheme.of(context)
                                            .textTheme
                                            .large
                                            .copyWith(
                                              fontWeight: FontWeight.w500,
                                            ),
                                      ),
                                      Row(
                                        spacing: 4.0,
                                        children: [
                                          Text(
                                            'Step',
                                            style: ShadTheme.of(
                                              context,
                                            ).textTheme.muted,
                                          ),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 4,
                                            ),
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(100),
                                              color: ShadTheme.of(context)
                                                  .colorScheme
                                                  .primary
                                                  .withValues(alpha: 0.2),
                                            ),
                                            child: Text(
                                              '${state.currentStep + 1}/${state.isEditMode ? 2 : 3}',
                                              style: ShadTheme.of(context)
                                                  .textTheme
                                                  .small
                                                  .copyWith(
                                                    color: ShadTheme.of(
                                                      context,
                                                    ).colorScheme.primary,
                                                  ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  Text(
                                    state.isEditMode
                                        ? switch (state.currentStep) {
                                            0 =>
                                              'Enter the basic personal information including name, gender, and birth details to identify this person.',
                                            _ =>
                                              'Provide contact information such as email and phone number to keep your family records complete.',
                                          }
                                        : switch (state.currentStep) {
                                            0 =>
                                              'Enter the basic personal information including name, gender, and birth details to identify this person.',
                                            1 =>
                                              'Provide contact information such as email and phone number to keep your family records complete.',
                                            _ =>
                                              'Define how this person is related to others in your family tree to build your lineage.',
                                          },
                                    style: ShadTheme.of(
                                      context,
                                    ).textTheme.muted,
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                        Padding(
                          padding: const EdgeInsets.all(24),
                          child: BlocBuilder<AddCubit, AddMemberState>(
                            buildWhen: (previous, current) =>
                                previous.currentStep != current.currentStep,
                            builder: (context, state) {
                              return IndexedStack(
                                index: state.currentStep,
                                children: state.isEditMode
                                    ? const [
                                        PersonalInfoStep(),
                                        ContactInfoStep(),
                                      ]
                                    : const [
                                        PersonalInfoStep(),
                                        ContactInfoStep(),
                                        RelationshipsStep(),
                                      ],
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Navigation Buttons
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: BlocBuilder<AddCubit, AddMemberState>(
                builder: (context, state) {
                  return Row(
                    children: [
                      if (state.currentStep > 0) ...[
                        Expanded(
                          child: ShadButton.outline(
                            height: 50,
                            onPressed: () {
                              context.read<AddCubit>().stepChanged(
                                state.currentStep - 1,
                              );
                            },
                            child: const Text('Back'),
                          ),
                        ),
                        const SizedBox(width: 16),
                      ],
                      Expanded(
                        child: state.currentStep < (state.isEditMode ? 1 : 2)
                            ? ShadButton(
                                decoration: ShadDecoration(
                                  border: ShadBorder(
                                    radius: BorderRadius.circular(12),
                                  ),
                                ),
                                height: 50,
                                onPressed: () {
                                  if (_isStepValid(state)) {
                                    context.read<AddCubit>().stepChanged(
                                      state.currentStep + 1,
                                    );
                                  } else {
                                    context.read<AddCubit>().validateForm();
                                  }
                                },
                                child: const Text('Next'),
                              )
                            : ShadButton(
                                height: 50,
                                enabled:
                                    state.status != AddMemberStatus.loading,
                                onPressed: () {
                                  context.read<AddCubit>().submit();
                                },
                                child: state.status == AddMemberStatus.loading
                                    ? const SizedBox(
                                        height: 16,
                                        width: 16,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                Colors.white,
                                              ),
                                        ),
                                      )
                                    : Text(
                                        state.isEditMode ? 'Update' : 'Submit',
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
      ),
    );
  }

  String _getStepTitle(int step, bool isEditMode) {
    final prefix = isEditMode ? 'Editing: ' : '';
    switch (step) {
      case 0:
        return '${prefix}Personal Information';
      case 1:
        return '${prefix}Contact Information';
      case 2:
        return '${prefix}Relationships';
      default:
        return '';
    }
  }

  bool _isStepValid(AddMemberState state) {
    if (state.currentStep == 0) {
      return state.firstName.isValid &&
          state.lastName.isValid &&
          state.dateOfBirth.isValid &&
          state.gender.isValid;
    } else if (state.currentStep == 1) {
      return state.phoneNumber.isValid &&
          state.address.isValid &&
          state.city.isValid &&
          state.state.isValid;
    }
    return true;
  }
}
