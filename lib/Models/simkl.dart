class Simkl {
  static String simklShowToAL(String simklStatus) {
    switch (simklStatus) {
      case 'watching':
        return 'CURRENT';
      case 'completed':
        return 'COMPLETED';
      case 'hold':
        return 'PAUSED';
      case 'dropped':
        return 'DROPPED';
      case 'plantowatch':
        return 'PLANNING';
      default:
        return 'ALL';
    }
  }

  static String simklMovieToAL(String simklStatus) {
    switch (simklStatus) {
      case 'watching':
        return 'CURRENT';
      case 'completed':
        return 'COMPLETED';
      case 'hold':
        return 'PAUSED';
      case 'dropped':
        return 'DROPPED';
      case 'plantowatch':
        return 'PLANNING';
      default:
        return 'ALL';
    }
  }

  static String alToSimklShow(String anilistStatus) {
    switch (anilistStatus) {
      case 'CURRENT':
        return 'watching';
      case 'COMPLETED':
        return 'completed';
      case 'PAUSED':
        return 'hold';
      case 'DROPPED':
        return 'dropped';
      case 'PLANNING':
        return 'plantowatch';
      default:
        return 'all';
    }
  }

  static String alToSimklMovie(String anilistStatus) {
    switch (anilistStatus) {
      case 'CURRENT':
        return 'watching';
      case 'COMPLETED':
        return 'completed';
      case 'PAUSED':
        return 'hold';
      case 'DROPPED':
        return 'dropped';
      case 'PLANNING':
        return 'plantowatch';
      default:
        return 'all';
    }
  }
}
