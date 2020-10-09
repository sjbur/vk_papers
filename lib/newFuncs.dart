// Image.network(
//               "https://vk.com/doc555235065_570173751?hash=41e71e0ee554c170ea&dl=GMZTGMJSGEYTEOA:1602230658:54b1fd10abe72fde4a&api=1&no_preview=1&module=feed",
//               fit: BoxFit.cover,
//               loadingBuilder: (BuildContext context, Widget child,
//                   ImageChunkEvent loadingProgress) {
//                 if (loadingProgress == null) return child;
//                 return Center(
//                   child: CircularProgressIndicator(
//                     value: loadingProgress.expectedTotalBytes != null
//                         ? loadingProgress.cumulativeBytesLoaded /
//                             loadingProgress.expectedTotalBytes
//                         : null,
//                   ),
//                 );
//               },
//             ),

//GIFKI