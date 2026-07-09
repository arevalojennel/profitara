import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:profitara/blocs/batch/batch_bloc.dart';
import 'package:profitara/blocs/batch/batch_event.dart';
import 'package:profitara/blocs/batch/batch_state.dart';
import 'package:profitara/pages/production_details_page.dart';
import 'package:intl/intl.dart';
import 'package:profitara/utils/ui_utils/custom_loader_animation.dart';

class ProductionListPage extends StatelessWidget {
  const ProductionListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Production Runs'),
      ),
      body: BlocBuilder<BatchBloc, BatchState>(
        builder: (context, state) {
          if (state is BatchLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is ProductionRunsLoaded) {
            final runs = state.runs;
            if (runs.isEmpty) {
              // return const Center(child: Text('No production runs yet.'));
              return const Center(child: CustomLoaderAnimation());
            }
            return ListView.builder(
              itemCount: runs.length,
              itemBuilder: (ctx, i) {
                final run = runs[i];
                return Card(
                  child: ListTile(
                    title: Text(run.batchName),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                            'Date: ${DateFormat.yMMMd().add_jm().format(run.date)}'),
                        Text('Multiplier: ${run.multiplier}'),
                        Text('Sold: ${run.actualSold} pieces'),
                      ],
                    ),
                    trailing: const Icon(Icons.edit),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ProductionDetailsPage(run: run),
                        ),
                      );
                    },
                  ),
                );
              },
            );
          } else if (state is BatchError) {
            print(state.message);
            return Center(child: Text('Error: ${state.message}'));
          }
          // Trigger load if not already loaded
          if (state is! ProductionRunsLoaded && state is! BatchLoading) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              context.read<BatchBloc>().add(LoadProductionRuns());
            });
          }
          return const SizedBox();
        },
      ),
    );
  }
}
