enum Flavor { dev, staging, prod }

class F {
  static late final Flavor appFlavor;

  static String get name => appFlavor.name;

  static String get title {
    switch (appFlavor) {
      case Flavor.dev:
        return 'Neon Dev';
      case Flavor.staging:
        return 'Neon Stg';
      case Flavor.prod:
        return 'Neon Voyager';
    }
  }
}
