// 검증된 위키미디어 이미지 + 카테고리별 대체 이미지 매핑
// 위키미디어에서 확인된 실제 성지 이미지만 사용
// 나머지는 Unsplash 무료 이미지 (교회/기념관/박물관/학교 카테고리별)

const verifiedImages = {
  // === 위키미디어 검증 완료 ===
  'yanghwajin': 'https://upload.wikimedia.org/wikipedia/commons/thumb/e/eb/Yanghwajin.jpg/500px-Yanghwajin.jpg',
  'jeongdong': 'https://upload.wikimedia.org/wikipedia/commons/thumb/b/bb/American_Methodist_Church%2C_Seoul%2C_c.1900.jpg/500px-American_Methodist_Church%2C_Seoul%2C_c.1900.jpg',
  'saemoonan': 'https://upload.wikimedia.org/wikipedia/commons/thumb/6/64/Saemoonan_hall.JPG/500px-Saemoonan_hall.JPG',
  'underwood': 'https://upload.wikimedia.org/wikipedia/commons/thumb/b/bb/Underwood_hall.jpg/500px-Underwood_hall.jpg',
  'yeouidofc': 'https://upload.wikimedia.org/wikipedia/commons/thumb/9/90/Yoido_Full_Gospel_Church_Outdoor_Cross.JPG/500px-Yoido_Full_Gospel_Church_Outdoor_Cross.JPG',
  'seungdong': 'https://upload.wikimedia.org/wikipedia/commons/thumb/5/5d/%EC%8A%B9%EB%8F%99%EA%B5%90%ED%9A%8C%2C_Insadong%2C_Seoul_02.jpg/500px-%EC%8A%B9%EB%8F%99%EA%B5%90%ED%9A%8C%2C_Insadong%2C_Seoul_02.jpg',
  'paichai': 'https://upload.wikimedia.org/wikipedia/commons/thumb/3/38/East_hall_of_Pai_Chai_school.JPG/500px-East_hall_of_Pai_Chai_school.JPG',
  'ewha': 'https://upload.wikimedia.org/wikipedia/commons/thumb/7/76/Ewha_Women%27s_Univ_Main_Buildingl-20070908.JPG/500px-Ewha_Women%27s_Univ_Main_Buildingl-20070908.JPG',
  'severance': 'https://upload.wikimedia.org/wikipedia/commons/9/9d/Severance_Hospital_in_1904.jpg',
  'youngnak': 'https://upload.wikimedia.org/wikipedia/commons/thumb/e/e8/Young_Nak_Church_2007.jpg/500px-Young_Nak_Church_2007.jpg',
  'myungsung': 'https://upload.wikimedia.org/wikipedia/commons/thumb/b/b0/MyungsungChurch.jpg/500px-MyungsungChurch.jpg',
  'onnuri': 'https://upload.wikimedia.org/wikipedia/commons/thumb/e/ea/140504_onnuri_seobi%40go.JPG/500px-140504_onnuri_seobi%40go.JPG',
  'sarang': 'https://upload.wikimedia.org/wikipedia/commons/thumb/3/3c/Seocho_SaRang_Community_Church.jpg/500px-Seocho_SaRang_Community_Church.jpg',
  'ganghwa_church': 'https://upload.wikimedia.org/wikipedia/commons/thumb/a/a3/Ganghwa_Anglican_Church.jpg/500px-Ganghwa_Anglican_Church.jpg',
  'incheon_naeri': 'https://upload.wikimedia.org/wikipedia/commons/thumb/0/0a/Naeri_Methodist_church.JPG/500px-Naeri_Methodist_church.JPG',
  'jeonju_seomun': 'https://upload.wikimedia.org/wikipedia/commons/thumb/d/d5/%EC%A0%84%EC%A3%BC_%EC%84%9C%EB%AC%B8%EA%B5%90%ED%9A%8C.jpg/500px-%EC%A0%84%EC%A3%BC_%EC%84%9C%EB%AC%B8%EA%B5%90%ED%9A%8C.jpg',
  'yonsei_univ': 'https://upload.wikimedia.org/wikipedia/commons/thumb/7/76/Main_Library_at_Yonsei_University.jpg/500px-Main_Library_at_Yonsei_University.jpg',
  'appenzeller_memorial': 'https://upload.wikimedia.org/wikipedia/commons/thumb/0/0a/Pai_Chai_high_school%2C_Seoul%2C_%28s.d.%29_%28Taylor_box21num40%29.jpg/500px-Pai_Chai_high_school%2C_Seoul%2C_%28s.d.%29_%28Taylor_box21num40%29.jpg',
  'namsan_prayer': 'https://upload.wikimedia.org/wikipedia/commons/thumb/4/47/Namsan_Park_and_Seoul_Tower_%284615642044%29.jpg/500px-Namsan_Park_and_Seoul_Tower_%284615642044%29.jpg',
  'wonju_first': 'https://upload.wikimedia.org/wikipedia/commons/thumb/2/2a/Church_and_congregation%2C_Wonju%2C_%28s.d.%29_%28Taylor_box21num37%29.jpg/500px-Church_and_congregation%2C_Wonju%2C_%28s.d.%29_%28Taylor_box21num37%29.jpg',
  'daejeon_hannam': 'https://upload.wikimedia.org/wikipedia/commons/thumb/c/cc/%ED%95%9C%EB%82%A8%EB%8C%80%ED%95%99%EA%B5%90_%EB%B4%84%EC%82%AC%EC%A7%84.jpg/500px-%ED%95%9C%EB%82%A8%EB%8C%80%ED%95%99%EA%B5%90_%EB%B4%84%EC%82%AC%EC%A7%84.jpg',
  'chungdong': 'https://upload.wikimedia.org/wikipedia/commons/thumb/b/bb/American_Methodist_Church%2C_Seoul%2C_c.1900.jpg/500px-American_Methodist_Church%2C_Seoul%2C_c.1900.jpg',
  'samilpo': 'https://upload.wikimedia.org/wikipedia/commons/thumb/1/10/Pagoda_Park.jpg/500px-Pagoda_Park.jpg',
};

// 카테고리별 Unsplash 대체 이미지 (무료, 저작권 자유)
const categoryDefaults = {
  'church': 'https://images.unsplash.com/photo-1510936111840-65e151ad71bb?w=500&h=250&fit=crop',
  'memorial': 'https://images.unsplash.com/photo-1555861496-0666c8981751?w=500&h=250&fit=crop',
  'museum': 'https://images.unsplash.com/photo-1566127444979-b3d2b654e3d7?w=500&h=250&fit=crop',
  'education': 'https://images.unsplash.com/photo-1541339907198-e08756dedf3f?w=500&h=250&fit=crop',
  'revival': 'https://images.unsplash.com/photo-1438232992991-995b7058bbb3?w=500&h=250&fit=crop',
  'origin': 'https://images.unsplash.com/photo-1504052434569-70ad5836ab65?w=500&h=250&fit=crop',
};

console.log('검증된 이미지 수:', Object.keys(verifiedImages).length);
console.log(JSON.stringify(verifiedImages, null, 2));
