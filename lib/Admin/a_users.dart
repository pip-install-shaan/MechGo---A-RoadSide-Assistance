import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mech_go/Admin/Admin_Authentication/admin_bloc.dart';
import 'package:mech_go/Admin/Admin_Authentication/admin_event.dart';
import 'package:mech_go/Admin/Admin_Authentication/admin_state.dart';

class UserOnAdmin extends StatefulWidget {
  const UserOnAdmin({super.key});

  @override
  State<UserOnAdmin> createState() => _UserOnAdminState();
}

class _UserOnAdminState extends State<UserOnAdmin> {

  @override
  void initState() {
    super.initState();

    context.read<AdminBloc>().add(
      const WatchAdminUsers(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),

        title: const Text(
          'Registered Users',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontFamily: 'Times New Roman',
          ),
        ),

        backgroundColor:
            const Color.fromARGB(
          255,
          197,
          17,
          4,
        ),

        centerTitle: true,
      ),

      body: BlocBuilder<AdminBloc, AdminState>(
        builder: (context, state) {

          if (state.status == AdminStatus.loading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (state.status == AdminStatus.failure) {
            return Center(
              child: Text(
                state.errorMessage ?? 'Something went wrong',
              ),
            );
          }

          final users = state.users;

          if (users.isEmpty) {
            return const Center(
              child: Text(
                'No registered users found',
              ),
            );
          }

          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {

              final user = users[index];

              return ListTile(
                leading: CircleAvatar(
                  child: Text(
                    (user['name'] ?? 'U')
                        .toString()
                        .substring(0, 1)
                        .toUpperCase(),
                  ),
                ),

                title: Text(
                  user['name'] ?? 'Unknown User',
                ),

                subtitle: Text(
                  user['email'] ?? user['phone'] ?? '',
                ),

                trailing: IconButton(
                  icon: const Icon(
                    Icons.delete,
                  ),

                  onPressed: () {

                    context.read<AdminBloc>().add(
                      DeleteAdminUser(
                        user['uid'].toString(),
                      ),
                    );

                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}