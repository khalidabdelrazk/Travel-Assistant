import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:travel/core/di/di.dart';
import 'package:travel/presentation/home/domain/Entity/trips_response_entity.dart';
import 'package:travel/presentation/wishlist/ui/cubit/wishlist_states.dart';
import 'package:travel/presentation/wishlist/ui/cubit/wishlist_view_model.dart';
import 'package:travel/presentation/wishlist/ui/widgets/wish_trips_card.dart';

import '../../../core/common/network_error_widget.dart';
import '../../../core/routes/route_names.dart';
import '../domain/Entity/wishlist_response_entity.dart';

class Wishlist extends StatefulWidget {
  const Wishlist({super.key});

  @override
  State<Wishlist> createState() => _WishlistState();
}

class _WishlistState extends State<Wishlist> {
  final WishlistViewModel wishlistViewModel = getIt<WishlistViewModel>();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WishlistViewModel, WishListStates>(
      bloc: wishlistViewModel..getWishlist(),
      builder: (context, state) {
        if (state is ErrorState) {
          return NetworkErrorWidget(
            errorMsg: state.errorMessage,
            large: true,
            onTap: wishlistViewModel.getWishlist,
          );
        } else if (state is LoadingState &&
            wishlistViewModel.wishlist.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        } else if (wishlistViewModel.wishlist.isEmpty) {
          return const Center(
            child: Text("No Favourite Trips", style: TextStyle(fontSize: 18)),
          );
        }

        return Padding(
          padding: const EdgeInsets.all(16),
          child: LayoutBuilder(
            builder: (context, constraints) {
              int crossAxisCount = 2;
              if (constraints.maxWidth > 600) crossAxisCount = 3;
              if (constraints.maxWidth > 900) crossAxisCount = 4;

              return GridView.builder(
                padding: EdgeInsets.only(bottom: 70),
                itemCount: wishlistViewModel.wishlist.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  childAspectRatio: 0.67,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemBuilder: (context, index) {
                  final trip = wishlistViewModel.wishlist[index];
                  return Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Theme.of(context).primaryColor,
                        width: 1,
                      ),
                    ),
                    child: WishTripsCard(
                      trip: trip,
                      onPress: () => onTap(trip),
                      onFavTap: () async {
                        await wishlistViewModel.removeFromWishList(trip.id!);
                      },
                    ),
                  );
                },
              );
            },
          ),
        );
      },
    );
  }

  Future<void> onTap(WishlistResponseEntity data)async{
      final result = await Navigator.pushNamed(
        context,
        RouteNames.exploreDetails,
        arguments: data,
      );

      if (result == true) {
        wishlistViewModel.getWishlist();
      }
    }
}
