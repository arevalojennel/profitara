import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:profitara/blocs/batch/batch_bloc.dart';
import 'package:profitara/blocs/batch/batch_state.dart';
import 'package:profitara/pages/batch_details_page.dart';
import 'package:profitara/utils/snackbar_utils.dart';

import '../blocs/inventory/inventory_bloc.dart';
import '../blocs/inventory/inventory_state.dart';

class BatchPage extends StatelessWidget {
  const BatchPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Batches')),
      body: BlocBuilder<BatchBloc, BatchState>(
        builder: (context, state) {
          if (state is BatchLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is BatchesLoaded) {
            return ListView.builder(
              itemCount: state.batches.length,
              itemBuilder: (ctx, i) {
                final batch = state.batches[i];
                return Card(
                  child: ListTile(
                    title: Text(batch.name),
                    subtitle: Text(
                        'Yield: ${batch.piecesYield} | Margin: ${batch.profitMargin}%'),
                    trailing: Text('Produced: ${batch.producedCount}'),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => BatchDetailsPage(batch: batch),
                        ),
                      );
                    },
                  ),
                );
              },
            );
          } else if (state is BatchError) {
            return Center(child: Text('Error: ${state.message}'));
          }
          return Container();
        },
      ),
      floatingActionButton:
          BlocBuilder<InventoryBloc, InventoryState>(builder: (context, state) {
        if (state is! InventoryLoaded) {
          return const Center(child: CircularProgressIndicator());
        }
        final stocks = state.stocks;
        print('Stocks: $stocks');
        return FloatingActionButton(
          child: Icon(
            Icons.add,
            color: Theme.of(context).colorScheme.onPrimary,
          ),
          onPressed: () {
            if (stocks.isEmpty || stocks == []) {
              SnackbarUtil.showErrorMessage(
                context: context,
                message: "Please Add Stocks before Adding Batches",
                snackPosition: SnackPosition.TOP,
              );
            }
          },
          // onPressed: () => Navigator.push(
          //   context,
          //   MaterialPageRoute(builder: (_) => const AddBatchPage()),
          // ),
        );
      }),
    );
  }
}
