String? companyLogoAsset(String companyName) {
  final normalized = companyName
      .toLowerCase()
      .replaceAll(RegExp(r'\s+'), '')
      .replaceAll(RegExp(r'[()㈜주식회사]'), '');

  if (normalized.isEmpty) return null;

  final entries = <String, String>{
    'samsung': 'samsung.png',
    '삼성': 'samsung.png',
    'naver': 'naver.png',
    '네이버': 'naver.png',
    'kakao': 'kakao.png',
    '카카오': 'kakao.png',
    'line': 'line.png',
    '라인': 'line.png',
    'coupang': 'coupang.png',
    '쿠팡': 'coupang.png',
    'toss': 'toss.png',
    '토스': 'toss.png',
    '비바리퍼블리카': 'toss.png',
    'baemin': 'baemin.png',
    '배민': 'baemin.png',
    '배달의민족': 'baemin.png',
    '우아한형제들': 'baemin.png',
    'skhynix': 'sk_hynix.png',
    '하이닉스': 'sk_hynix.png',
    'lgcns': 'lg_cns.png',
    '엘지씨엔에스': 'lg_cns.png',
    'lgelectronics': 'lg_electronics.png',
    'lg전자': 'lg_electronics.png',
    '엘지전자': 'lg_electronics.png',
    'hyundai': 'hyundai.png',
    '현대': 'hyundai.png',
    'cj': 'cj.png',
    '씨제이': 'cj.png',
    'doosan': 'doosan.png',
    '두산': 'doosan.png',
    'posco': 'posco.png',
    '포스코': 'posco.png',
    'celltrion': 'celltrion.png',
    '셀트리온': 'celltrion.png',
    'nexon': 'nexon.png',
    '넥슨': 'nexon.png',
    'daangn': 'daangn.png',
    '당근': 'daangn.png',
  };

  for (final entry in entries.entries) {
    if (normalized.contains(entry.key)) {
      return 'assets/images/${entry.value}';
    }
  }

  return null;
}
