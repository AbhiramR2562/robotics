import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:robotics_app/models/user_model.dart';
import 'package:robotics_app/services/api_service.dart';
import 'package:robotics_app/theme.dart';
import 'package:robotics_app/utils/custom_button.dart';
import 'package:robotics_app/utils/header.dart';
import 'package:robotics_app/viewmodels/bloc/users_bloc.dart';
import 'package:robotics_app/views/edit_page.dart';
import 'package:robotics_app/views/profile_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  // Rotation Animation
  late AnimationController _rotationcontroller;
  late Animation<double> _rotationAnimation;

  // Initialize Bloc
  late UsersBloc _usersBloc;

  // Store current page
  int _currentPage = 1;
  final ScrollController _scrollController = ScrollController();
  bool _isFetchingMore = false;

  @override
  void initState() {
    super.initState();
    _usersBloc = UsersBloc(ApiService());
    _usersBloc.add(FetchUserEvent(page: _currentPage));

    // Rotation animation
    _rotationcontroller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _rotationAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _rotationcontroller, curve: Curves.easeInOut),
    );

    // Listener for when the user scrolls to the bottom
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent &&
          !_isFetchingMore) {
        _isFetchingMore = true;
        _currentPage++;
        _usersBloc.add(FetchUserEvent(page: _currentPage));
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _usersBloc.close();
    _rotationcontroller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return BlocProvider(
      create: (_) => _usersBloc,
      child: Scaffold(
        appBar: AppBar(backgroundColor: kPrimaryColor),
        body: BlocListener<UsersBloc, UsersState>(
          listener: (context, state) {
            if (state is UserDeleteSuccess) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(state.message)));
            } else if (state is UserDeleteError) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(state.message)));
            }
          },
          child: BlocBuilder<UsersBloc, UsersState>(
            builder: (context, state) {
              if (state is UsersLoading) {
                return const Center(child: CircularProgressIndicator());
              } else if (state is UsersLoaded) {
                return Column(
                  children: [
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
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  CircleAvatar(
                                    radius: 24,

                                    child: SvgPicture.asset(
                                      'assets/icons/Users.svg',
                                      colorFilter: ColorFilter.mode(
                                        kPrimaryColor,
                                        BlendMode.srcIn,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  const Text(
                                    'Users List',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),

                              Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: () {
                                    // Start rotation animation
                                    _rotationcontroller
                                        .forward(from: 0)
                                        .whenComplete(() {
                                          // After completing one rotation, fetch new user data
                                          setState(() {
                                            _currentPage++;
                                            _isFetchingMore = true;
                                          });
                                          _usersBloc.add(
                                            FetchUserEvent(page: _currentPage),
                                          );
                                        });
                                  },
                                  child: Row(
                                    children: [
                                      RotationTransition(
                                        turns: _rotationAnimation,
                                        child: SvgPicture.asset(
                                          'assets/icons/reloadicon.svg',
                                          colorFilter: ColorFilter.mode(
                                            kPrimaryColor,
                                            BlendMode.srcIn,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 5),
                                      Text(
                                        'Load User Data',
                                        style: TextStyle(
                                          color: kPrimaryColor,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 20, top: 20),
                        child: Text(
                          "No of Users",
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        controller: _scrollController,
                        // extra for loader
                        itemCount: state.users.length + 1,
                        itemBuilder: (context, index) {
                          if (index == state.users.length) {
                            // Done loading more
                            _isFetchingMore = false;
                            return const Padding(
                              padding: EdgeInsets.symmetric(vertical: 16),
                              child: Center(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    CircularProgressIndicator(
                                      color: kPrimaryColor,
                                    ),
                                    SizedBox(width: 10),
                                    Text(
                                      "Load More",
                                      style: TextStyle(color: kPrimaryColor),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }

                          final user = state.users[index];
                          return Padding(
                            padding: const EdgeInsets.only(top: 16),

                            child: Container(
                              margin: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 8,
                              ),
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        width: 50,
                                        height: 50,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: const Color.fromARGB(
                                            255,
                                            164,
                                            206,
                                            240,
                                          ),
                                        ),
                                        child: Image.asset(
                                          UserModel.defaultProfileImage,
                                          width: 50,
                                          height: 50,
                                          fit: BoxFit.cover,
                                        ),
                                      ),

                                      const SizedBox(width: 12),
                                      Text(
                                        user.name ?? "No name",
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(left: 50),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: [
                                        CustomButton(
                                          onPressed: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder:
                                                    (_) => BlocProvider.value(
                                                      value: _usersBloc,
                                                      child: EditPage(
                                                        user: user,
                                                      ),
                                                    ),
                                              ),
                                            ).then((updated) {
                                              if (updated == true) {
                                                _usersBloc.add(
                                                  FetchUserEvent(),
                                                );
                                              }
                                            });
                                          },
                                          icon: Icons.edit,
                                          iconColor: kPrimaryColor,
                                          label: "Edit",
                                        ),
                                        CustomButton(
                                          onPressed: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder:
                                                    (_) => BlocProvider.value(
                                                      value: _usersBloc,
                                                      child: ProfilePage(
                                                        userId:
                                                            user.id.toString(),
                                                      ),
                                                    ),
                                              ),
                                            ).then((_) {
                                              // This runs when coming back from UserDetailsPage
                                              _usersBloc.add(FetchUserEvent());
                                            });
                                          },
                                          icon: Icons.remove_red_eye_outlined,
                                          iconColor: kPrimaryColor,
                                          label: "view",
                                        ),
                                        CustomButton(
                                          onPressed: () {
                                            _usersBloc.add(
                                              DeleteUserEvent(
                                                userId: user.id.toString(),
                                                page: 1,
                                              ),
                                            );
                                          },
                                          icon: Icons.delete,
                                          iconColor: Colors.red,
                                          label: "Delete",
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Container(height: 1, color: Colors.grey[400]),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                );
              } else if (state is UsersError) {
                return Center(child: Text(state.message));
              } else {
                return const Center(child: Text("No data available"));
              }
            },
          ),
        ),
      ),
    );
  }
}
