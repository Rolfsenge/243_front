class API {
  static const hostConnect = "http://app.dvdgtm243.com";
  // static const hostConnect = "http://192.168.1.11/gtm";
  // static const hostConnect = "http://10.138.59.242/gtm";

  static const hostConnectUser = "$hostConnect/android";
  static const hostGetters = "$hostConnect/android/getters";
  static const apps = "$hostConnect/android/apps";

  static const android = "$hostConnect/android/apps/update.apk";
  static const ios = "$hostConnect/ios/apps/update.ipa";

  static const apk_version = "$hostGetters/version.json";

  // Flex PAY
  static const flexpay = "$hostGetters/flexpay.php";
  static const flexcheck = "$hostGetters/flexcheck.php";

  static const validateEmail = "$hostGetters/validate_email.php";
  static const signUp = "$hostGetters/signup.php";
  static const login = "$hostGetters/signin.php";
  static const getOTP = "$hostGetters/getOTP.php";
  static const reset = "$hostGetters/reset.php";
  static const resetdefault = "$hostGetters/resetdefault.php";
  static const getLocation = "$hostGetters/getLocation.php";
  static const getLocationLeaf = "$hostGetters/getLocationLeaf.php";
  static const getSitesBySecteur = "$hostGetters/getSitesBySecteur.php";
  static const getPdvBySecteur = "$hostGetters/getPdvBySecteur.php";
  static const getSitesByZone = "$hostGetters/getSitesByZone.php";
  static const getPdvByZone = "$hostGetters/getPdvByZone.php";
  static const getSitesByRegion = "$hostGetters/getSitesByRegion.php";
  static const getPdvByRegion = "$hostGetters/getPdvByRegion.php";

  static const getCountBySecteur = "$hostGetters/getCountBySecteur.php";
  static const getPdvRuptureSecteur = "$hostGetters/getPdvRuptureSecteur.php";
  static const getGraphSiteBySecteur = "$hostGetters/getGraphSiteBySecteur.php";
  static const getPdvRuptureSite = "$hostGetters/getPdvRuptureSite.php";
  static const submitActivity = "$hostGetters/submitActivity.php";
  static const getCountByZone = "$hostGetters/getCountByZone.php";
  static const getRevenuSiteBySecteur =
      "$hostGetters/getRevenuSiteBySecteur.php";
  static const getAcquisitionNational =
      "$hostGetters/getAcquisitionNational.php";

  static const getKpiNational = "$hostGetters/getKpiNational.php";
  static const getKpiRegion = "$hostGetters/getKpiRegion.php";
  static const getKpiZone = "$hostGetters/getKpiZone.php";
  static const getKpiSecteur = "$hostGetters/getKpiSecteur.php";
  static const getKpiSite = "$hostGetters/getKpiSite.php";
  static const getKpiTl = "$hostGetters/getKpiTl.php";
  static const getRevenuSiteAll = "$hostGetters/getRevenuSiteAll.php";
  static const getRevenuSiteRegion = "$hostGetters/getRevenuSiteRegion.php";
  static const getRevenuSiteZone = "$hostGetters/getRevenuSiteZone.php";
  static const getRevenuSiteSecteur = "$hostGetters/getRevenuSiteSecteur.php";
  static const getPerformanceSiteRegion =
      "$hostGetters/getPerformanceSiteRegion.php";

  static const getPdvSiteAll = "$hostGetters/getPdvSiteAll.php";
  static const getPdvBySite = "$hostGetters/getPdvBySite.php";

  static const getPerformanceSiteZone =
      "$hostGetters/getPerformanceSiteZone.php";

  static const getPerformanceSiteSecteur =
      "$hostGetters/getPerformanceSiteSecteur.php";

  static const getAcquisitionRegion = "$hostGetters/getAcquisitionRegion.php";
  static const getAcquisitionZone = "$hostGetters/getAcquisitionZone.php";
  static const getAcquisitionSecteur = "$hostGetters/getAcquisitionSecteur.php";
  static const getAcquisitionSite = "$hostGetters/getAcquisitionSite.php";
  static const addPDV = "$hostGetters/addPDV.php";
  static const checkPdv4add = "$hostGetters/checkPdv4add.php";
  static const getPdvBySite1 = "$hostGetters/getPdvBySite1.php";
  static const getKpiByTl = "$hostGetters/getKpiByTl.php";
  static const getKpiByTlHome = "$hostGetters/getKpiByTlHome.php";
  static const getAcquisitionSiteHome =
      "$hostGetters/getAcquisitionSiteHome.php";
  static const saveCicoAvecPhoto = "$hostGetters/saveCicoAvecPhoto.php";
  static const saveCicoSansPhoto = "$hostGetters/saveCicoSansPhoto.php";
  static const saveResetKaabu = "$hostGetters/saveResetKaabu.php";
  static const saveResetZebra = "$hostGetters/saveResetZebra.php";
  static const getCount = "$hostGetters/getCount.php";
  static const saveRlms = "$hostGetters/saveRlms.php";
  static const saveZebra = "$hostGetters/saveZebra.php";
  static const saveCreation = "$hostGetters/saveCreation.php";
  static const getAcquisitionSiteHomeTL =
      "$hostGetters/getAcquisitionSiteHomeTL.php";
  static const getPdvBySitex = "$hostGetters/getPdvBySitex.php";
  static const getPdvBySiteTl = "$hostGetters/getPdvBySiteTl.php";

  static const getActivite = "$hostGetters/getActivite.php";

  static const saveCreationMarchand = "$hostGetters/saveCreationMarchand.php";

  static const getFdv = "$hostGetters/getFdv.php";
  static const getMarchandUser = "$hostGetters/getMarchandUser.php";

  static const getSecteur = "$hostGetters/getSecteur.php";
  static const getDcmPerformance = "$hostGetters/getDcmPerformance.php";
  static const getCanalTlRegion = "$hostGetters/getCanalTlRegion.php";
  static const getCanalTlZone = "$hostGetters/getCanalTlZone.php";
  static const getCanalTlSecteur = "$hostGetters/getCanalTlSecteur.php";
  static const getCanalTlBySecteur = "$hostGetters/getCanalTlBySecteur.php";
  static const getContenuCanalTl = "$hostGetters/getContenuCanalTl.php";

  static const getHomeKaabu = "$hostGetters/getHomeKaabu.php";
  static const getKaabuStatut = "$hostGetters/getKaabuStatut.php";

  static const getHomeZebra = "$hostGetters/getHomeZebra.php";
  static const getZebraStatut = "$hostGetters/getZebraStatut.php";

  static const getHomeRlms = "$hostGetters/getHomeRlms.php";
  static const getRlmsStatut = "$hostGetters/getRlmsStatut.php";

  static const getHomeCico = "$hostGetters/getHomeCico.php";
  static const getCicoStatut = "$hostGetters/getCicoStatut.php";
}
