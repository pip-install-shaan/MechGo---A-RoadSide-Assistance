import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mech_go/Admin/Admin_Authentication/admin_bloc.dart';
import 'package:mech_go/Admin/Admin_Authentication/admin_event.dart';
import 'package:mech_go/Admin/Admin_Authentication/admin_state.dart';

class MechanicOnAdmin extends StatefulWidget {
  const MechanicOnAdmin({super.key});

  @override
  State<MechanicOnAdmin> createState() => _MechanicOnAdminState();
}

class _MechanicOnAdminState extends State<MechanicOnAdmin> {

  @override
  void initState() {
    super.initState();

    context.read<AdminBloc>().add(
      const WatchAdminMechanics(),
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
          'Register Mechanics',
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

          final mechanics = state.mechanics;

          if (mechanics.isEmpty) {
            return const Center(
              child: Text(
                'No registered mechanics found',
              ),
            );
          }

          return ListView.builder(
            itemCount: mechanics.length,
            itemBuilder: (context, index) {

              final mechanic = mechanics[index];

              return ListTile(
                leading: CircleAvatar(
                  child: Text(
                    (mechanic['name'] ?? 'M')
                        .toString()
                        .substring(0, 1)
                        .toUpperCase(),
                  ),
                ),

                title: Text(
                  mechanic['name'] ?? 'Unknown Mechanic',
                ),

                subtitle: Text(
                  mechanic['email'] ??
                      mechanic['phone'] ??
                      '',
                ),

                trailing: IconButton(
                  icon: const Icon(
                    Icons.delete,
                  ),

                  onPressed: () {

                    context.read<AdminBloc>().add(
                      DeleteAdminMechanic(
                        mechanic['uid'].toString(),
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