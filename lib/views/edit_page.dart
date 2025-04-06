import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:robotics_app/models/user_model.dart';
import 'package:robotics_app/theme.dart';
import 'package:robotics_app/utils/custom_dropdown.dart';
import 'package:robotics_app/utils/header.dart';
import 'package:robotics_app/utils/my_textfield.dart';
import 'package:robotics_app/viewmodels/bloc/users_bloc.dart';

class EditPage extends StatefulWidget {
  final UserModel user;
  const EditPage({super.key, required this.user});

  @override
  State<EditPage> createState() => _EditPageState();
}

class _EditPageState extends State<EditPage> {
  // Key to validate adn track form state
  final _formKey = GlobalKey<FormState>();

  // Controllers
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  String gender = "male";
  String status = "active";

  @override
  void initState() {
    super.initState();

    _nameController = TextEditingController(text: widget.user.name);
    _emailController = TextEditingController(text: widget.user.email ?? "");
    gender = widget.user.gender ?? "male";
    status = widget.user.status ?? "active";
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  // Update user
  void _updateUser() {
    if (_formKey.currentState!.validate()) {
      final updatedUser = widget.user.copyWith(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        gender: gender,
        status: status,
      );

      context.read<UsersBloc>().add(UpdateUserEvent(user: updatedUser));
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: customAppBar(context),
      body: SingleChildScrollView(
        child: BlocListener<UsersBloc, UsersState>(
          listener: (context, state) {
            if (state is UserUpdateSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('User updated successfully!')),
              );
              Navigator.pop(context, true);
            } else if (state is UserUpdateError) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(state.message)));
            }
          },
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                // Name
                Column(
                  children: [
                    // Custom Header
                    Header(
                      size: size,
                      child: Container(
                        margin: EdgeInsets.symmetric(
                          horizontal: kDefaultPadding,
                        ),
                        height: 70,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withAlpha(77),
                              offset: const Offset(0, 4),
                              blurRadius: 10,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  CircleAvatar(
                                    radius: 24,
                                    child: SvgPicture.asset(
                                      'assets/icons/editicon.svg',
                                      colorFilter: ColorFilter.mode(
                                        kPrimaryColor,
                                        BlendMode.srcIn,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  const Text(
                                    'Edit Details',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // sized box
                    const SizedBox(height: 10),
                    MyTextfield(
                      title: "Name",
                      controller: _nameController,
                      validator:
                          (value) => value!.isEmpty ? 'Name is required' : null,
                    ),
                    // Email
                    MyTextfield(
                      title: "Email",
                      controller: _emailController,
                      validator: (value) {
                        if (value == null || value.isEmpty)
                          return 'Email is required';
                        if (!value.contains('@')) return 'Enter a valid email';
                        return null;
                      },
                    ),

                    // Gender
                    CustomDropdown(
                      label: "Gender",
                      value: gender,
                      items: const [
                        DropdownMenuItem(value: 'male', child: Text('Male')),
                        DropdownMenuItem(
                          value: 'female',
                          child: Text('Female'),
                        ),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => gender = value);
                        }
                      },
                    ),

                    // Status
                    CustomDropdown(
                      label: "Status",
                      value: status,
                      items: const [
                        DropdownMenuItem(
                          value: 'active',
                          child: Text('Active'),
                        ),
                        DropdownMenuItem(
                          value: 'inactive',
                          child: Text('Inactive'),
                        ),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => status = value);
                        }
                      },
                    ),
                  ],
                ),

                Container(height: MediaQuery.of(context).size.height * 0.24),
                BlocBuilder<UsersBloc, UsersState>(
                  builder: (context, state) {
                    return GestureDetector(
                      onTap: state is UsersLoading ? null : () => _updateUser(),
                      child: Container(
                        padding: EdgeInsets.all(20),
                        width: MediaQuery.of(context).size.width * 0.9,
                        decoration: BoxDecoration(
                          color: kPrimaryColor,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child:
                              state is UsersLoading
                                  ? const SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth:
                                          2, // Optional: thinner/thicker ring
                                    ),
                                  )
                                  : const Text(
                                    'Update Details',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                    ),
                                  ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Custom App Bar
  AppBar customAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: kPrimaryColor,
      automaticallyImplyLeading: false, // Remove default back button
      title: const Text(
        'Back',
        style: TextStyle(color: Colors.white, fontSize: 16),
      ),
      leading: Padding(
        padding: const EdgeInsets.only(left: 12),
        child: GestureDetector(
          onTap: () {
            Navigator.pop(context); // Navigate back
          },
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 1),
            ),
            child: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
          ),
        ),
      ),
    );
  }
}
