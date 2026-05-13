import 'package:floodmonitoring/utils/data_classes.dart';

FloodStatusLevels parseFloodCat(String raw) {
  switch (raw) {
    case "nf":
      return FloodStatusLevels.nf;
    case "patv":
      return FloodStatusLevels.patv;
    case "nplv":
      return FloodStatusLevels.nplv;
    case "npatv":
      return FloodStatusLevels.npatv;
    default:
      return FloodStatusLevels.npatv;
  }
}
