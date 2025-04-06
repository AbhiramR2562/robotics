import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:robotics_app/models/user_model.dart';
import 'package:robotics_app/theme.dart';
import 'package:robotics_app/utils/custom_details.dart';
import 'package:robotics_app/utils/header.dart';
import 'package:robotics_app/viewmodels/bloc/users_bloc.dart';
import 'package:robotics_app/views/edit_page.dart';

class ProfilePage extends StatelessWidget {
  final String userId;
  const ProfilePage({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    // Trigger fetch event
    context.read<UsersBloc>().add(FetchUserDetailsEvent(userId));

    return Scaffold(
      appBar: customAppBar(context),
      body: BlocBuilder<UsersBloc, UsersState>(
        builder: (context, state) {
          if (state is UsersLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is UserDetailsLoaded) {
            UserModel user = state.user;
            return Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  children: [
                    Header(
                      size: size,
                      cutHeight: 30,
                      child: Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 4.0),
                        ),
                        child: CircleAvatar(
                          radius: 50,
                          child: ClipOval(
                            child: Image.asset(
                              UserModel.defaultProfileImage,
                              width: 100,
                              height: 100,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 10, bottom: 20),
                      child: Text(
                        user.name ?? '',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width * 0.9,
                      padding: EdgeInsets.only(left: 20, right: 20, bottom: 20),
                      decoration: BoxDecoration(
                        // color: Colors.amber,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: kPrimaryColor.withAlpha((0.2 * 255).toInt()),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        children: [
                          CustomDetails(
                            icon: Icons.email_outlined,
                            title: "Email",
                            subText: "${user.email}",
                          ),
                          CustomDetails(
                            svgPath: 'assets/icons/Gendericon.svg',
                            title: "Gender",
                            subText: "${user.gender}",
                          ),
                          CustomDetails(
                            svgPath: 'assets/icons/ExclamationMarkicon.svg',
                            title: "Status",
                            subText: "${user.status}",
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (_) => BlocProvider.value(
                                value:
                                    context
                                        .read<
                                          UsersBloc
                                        >(), // Use the same instance
                                child: EditPage(
                                  user: user,
                                ), // Pass the user model
                              ),
                        ),
                      ).then((updated) {
                        // If the details were updated, fetch user details again
                        if (updated == true) {
                          context.read<UsersBloc>().add(
                            FetchUserDetailsEvent(userId),
                          );
                        }
                      });
                    },
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
                                  'Edit Details',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                  ),
                                ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          } else if (state is UsersError) {
            return Center(child: Text(state.message));
          } else {
            return const Center(child: Text("No user details available."));
          }
        },
      ),
    );
  }
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
