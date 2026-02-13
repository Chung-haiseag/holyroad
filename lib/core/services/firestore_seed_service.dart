
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:holyroad/features/map/domain/entities/holy_site_entity.dart';

/// Firestore 초기 데이터 시드 서비스.
/// holy_sites 컬렉션이 비어있을 경우 기본 성지 데이터를 삽입합니다.
class FirestoreSeedService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// 한국 개신교(기독교) 주요 성지 목록 (시드 데이터) — 총 112개
  static const List<HolySite> seedSites = [
    // ===== 기존 12개 =====
    HolySite(
      id: 'yanghwajin',
      name: '양화진 외국인 선교사 묘원',
      description:
          '한국 개신교 선교의 성지. 언더우드, 아펜젤러 등 145명의 외국인 선교사들이 잠들어 있는 곳으로, 조선 땅에 복음의 씨앗을 뿌린 이들의 헌신을 기억하는 장소입니다.',
      latitude: 37.5448,
      longitude: 126.9102,
      imageUrl: 'https://upload.wikimedia.org/wikipedia/commons/thumb/e/eb/Yanghwajin.jpg/500px-Yanghwajin.jpg',
    ),
    HolySite(
      id: 'jeongdong',
      name: '정동제일교회',
      description:
          '1885년 아펜젤러 선교사가 세운 한국 최초의 개신교 교회. 서울 정동에 위치하며, 한국 감리교의 발상지로 개신교 역사의 시작점입니다.',
      latitude: 37.5656,
      longitude: 126.9750,
      imageUrl: 'https://upload.wikimedia.org/wikipedia/commons/thumb/b/bb/American_Methodist_Church%2C_Seoul%2C_c.1900.jpg/500px-American_Methodist_Church%2C_Seoul%2C_c.1900.jpg',
    ),
    HolySite(
      id: 'saemoonan',
      name: '새문안교회',
      description:
          '1887년 언더우드 선교사가 설립한 한국 최초의 장로교회. 서울 광화문 근처에 위치하며, 한국 장로교의 뿌리가 된 역사적인 교회입니다.',
      latitude: 37.5720,
      longitude: 126.9752,
      imageUrl: 'https://upload.wikimedia.org/wikipedia/commons/thumb/6/64/Saemoonan_hall.JPG/500px-Saemoonan_hall.JPG',
    ),
    HolySite(
      id: 'sorae',
      name: '소래교회 터',
      description:
          '1884년 한국인 자력으로 세운 최초의 개신교 교회. 황해도 장연에서 서상륜, 서경조 형제가 세웠으며, 한국인 스스로 복음을 전파한 상징적 장소입니다.',
      latitude: 38.2000,
      longitude: 125.1500,
      imageUrl: 'https://images.unsplash.com/photo-1504052434569-70ad5836ab65?w=500&h=250&fit=crop',
    ),
    HolySite(
      id: 'underwood',
      name: '언더우드 기념관 (연세대)',
      description:
          '한국 개신교 선교의 아버지 언더우드 선교사를 기념하는 곳. 연세대학교 내에 위치하며, 그가 설립한 경신학교(연희전문)의 역사가 시작된 곳입니다.',
      latitude: 37.5647,
      longitude: 126.9389,
      imageUrl: 'https://upload.wikimedia.org/wikipedia/commons/thumb/b/bb/Underwood_hall.jpg/500px-Underwood_hall.jpg',
    ),
    HolySite(
      id: 'yeouidofc',
      name: '여의도순복음교회',
      description:
          '1958년 조용기 목사가 설립한 세계 최대 규모의 개신교 교회. 성령 충만한 부흥 운동의 상징이며, 한국 기독교의 성장을 대표하는 교회입니다.',
      latitude: 37.5220,
      longitude: 126.9244,
      imageUrl: 'https://upload.wikimedia.org/wikipedia/commons/thumb/9/90/Yoido_Full_Gospel_Church_Outdoor_Cross.JPG/500px-Yoido_Full_Gospel_Church_Outdoor_Cross.JPG',
    ),
    HolySite(
      id: 'pyeongyang',
      name: '평양 장대현교회 터 (기념비)',
      description:
          '1907년 평양 대부흥 운동이 시작된 교회. 동양의 예루살렘이라 불렸던 평양에서 성령의 역사가 일어나, 한국 전역에 복음이 퍼지는 계기가 되었습니다.',
      latitude: 39.0167,
      longitude: 125.7500,
      imageUrl: 'https://images.unsplash.com/photo-1438232992991-995b7058bbb3?w=500&h=250&fit=crop',
    ),
    HolySite(
      id: 'jemulpo',
      name: '제물포 웨슬리예배당 (인천)',
      description:
          '1885년 아펜젤러 선교사가 인천에 도착하여 첫 예배를 드린 곳. 한국 감리교 선교의 출발점이자 서양 문화와 복음이 처음 전해진 관문입니다.',
      latitude: 37.4738,
      longitude: 126.6217,
      imageUrl: 'https://images.unsplash.com/photo-1504052434569-70ad5836ab65?w=500&h=250&fit=crop',
    ),
    HolySite(
      id: 'daegu_first',
      name: '대구 제일교회',
      description:
          '1893년 설립된 경북 지역 최초의 개신교 교회. 미국 북장로교 선교사들이 복음을 전하며 세운 교회로, 영남 지역 기독교 역사의 시작점입니다.',
      latitude: 35.8714,
      longitude: 128.5966,
      imageUrl: 'https://images.unsplash.com/photo-1510936111840-65e151ad71bb?w=500&h=250&fit=crop',
    ),
    HolySite(
      id: 'gwangju_yangrim',
      name: '광주 양림교회',
      description:
          '1904년 설립된 호남 지역 대표 개신교 교회. 유진 벨, 오웬 선교사 등이 의료 선교와 교육 사업을 통해 복음을 전한 호남 기독교의 요람입니다.',
      latitude: 35.1447,
      longitude: 126.9077,
      imageUrl: 'https://images.unsplash.com/photo-1510936111840-65e151ad71bb?w=500&h=250&fit=crop',
    ),
    HolySite(
      id: 'busan_choryang',
      name: '부산 초량교회',
      description:
          '1892년 설립된 부산 최초의 개신교 교회. 호주 장로교 선교사들이 세운 교회로, 부산 경남 지역 복음 전파의 출발점이 되었습니다.',
      latitude: 35.1175,
      longitude: 129.0403,
      imageUrl: 'https://images.unsplash.com/photo-1510936111840-65e151ad71bb?w=500&h=250&fit=crop',
    ),
    HolySite(
      id: 'samilpo',
      name: '삼일운동 기독교 기념관 (탑골공원)',
      description:
          '1919년 3·1운동에서 기독교인들이 중심 역할을 한 역사적 장소. 민족대표 33인 중 16인이 기독교 지도자였으며, 신앙과 민족 사랑이 하나 된 장소입니다.',
      latitude: 37.5711,
      longitude: 126.9889,
      imageUrl: 'https://upload.wikimedia.org/wikipedia/commons/thumb/1/10/Pagoda_Park.jpg/500px-Pagoda_Park.jpg',
    ),

    // ===== 서울 지역 추가 =====
    HolySite(
      id: 'yongsan_shinhak',
      name: '총신대학교 (사당)',
      description:
          '1901년 평양신학교로 시작된 한국 장로교 최초의 신학교. 한국 개신교 목회자 양성의 산실로, 수많은 목사와 선교사를 배출하였습니다.',
      latitude: 37.4886,
      longitude: 126.9816,
      imageUrl: 'https://images.unsplash.com/photo-1541339907198-e08756dedf3f?w=500&h=250&fit=crop',
    ),
    HolySite(
      id: 'seungdong',
      name: '승동교회',
      description:
          '1893년 무어 선교사가 설립한 서울 종로구의 역사적 교회. 3·1운동 당시 학생 독립만세 운동의 거점이었으며, 민족운동의 중심지 역할을 하였습니다.',
      latitude: 37.5700,
      longitude: 126.9920,
      imageUrl: 'https://upload.wikimedia.org/wikipedia/commons/thumb/5/5d/%EC%8A%B9%EB%8F%99%EA%B5%90%ED%9A%8C%2C_Insadong%2C_Seoul_02.jpg/500px-%EC%8A%B9%EB%8F%99%EA%B5%90%ED%9A%8C%2C_Insadong%2C_Seoul_02.jpg',
    ),
    HolySite(
      id: 'yondong',
      name: '연동교회',
      description:
          '1894년 설립된 서울의 역사적 장로교회. 언더우드 선교사의 전도로 세워졌으며, 한국 초기 개신교 지도자들을 배출한 교회입니다.',
      latitude: 37.5731,
      longitude: 126.9858,
      imageUrl: 'https://images.unsplash.com/photo-1510936111840-65e151ad71bb?w=500&h=250&fit=crop',
    ),
    HolySite(
      id: 'chungdong',
      name: '충동교회 (중구)',
      description:
          '1888년 설립된 서울의 초기 감리교회. 배재학당 학생들의 신앙 공동체에서 출발하여 서울 도심 복음화에 기여한 교회입니다.',
      latitude: 37.5640,
      longitude: 126.9770,
      imageUrl: 'https://upload.wikimedia.org/wikipedia/commons/thumb/b/bb/American_Methodist_Church%2C_Seoul%2C_c.1900.jpg/500px-American_Methodist_Church%2C_Seoul%2C_c.1900.jpg',
    ),
    HolySite(
      id: 'paichai',
      name: '배재학당 역사박물관',
      description:
          '1885년 아펜젤러 선교사가 설립한 한국 최초의 근대식 학교. 서양 교육과 기독교 복음을 동시에 전한 한국 근대 교육의 발상지입니다.',
      latitude: 37.5637,
      longitude: 126.9718,
      imageUrl: 'https://upload.wikimedia.org/wikipedia/commons/thumb/3/38/East_hall_of_Pai_Chai_school.JPG/500px-East_hall_of_Pai_Chai_school.JPG',
    ),
    HolySite(
      id: 'ewha',
      name: '이화학당 기념관 (이화여대)',
      description:
          '1886년 스크랜턴 부인이 설립한 한국 최초의 여성 교육 기관. 기독교 정신으로 여성 교육을 시작하여 한국 여성 인권 향상에 크게 기여하였습니다.',
      latitude: 37.5618,
      longitude: 126.9467,
      imageUrl: 'https://upload.wikimedia.org/wikipedia/commons/thumb/7/76/Ewha_Women%27s_Univ_Main_Buildingl-20070908.JPG/500px-Ewha_Women%27s_Univ_Main_Buildingl-20070908.JPG',
    ),
    HolySite(
      id: 'severance',
      name: '세브란스 기념관 (연세대)',
      description:
          '1885년 알렌 선교사가 시작한 한국 최초의 서양식 병원 광혜원(제중원)의 후신. 의료 선교를 통해 복음을 전파한 한국 근대 의학의 출발점입니다.',
      latitude: 37.5622,
      longitude: 126.9400,
      imageUrl: 'https://upload.wikimedia.org/wikipedia/commons/9/9d/Severance_Hospital_in_1904.jpg',
    ),
    HolySite(
      id: 'namsan_prayer',
      name: '남산 새벽기도 터',
      description:
          '한국 초기 기독교인들이 일제강점기에 몰래 새벽기도를 드리던 장소. 탄압 속에서도 신앙을 지킨 한국 기독교인들의 기도의 흔적이 남아 있습니다.',
      latitude: 37.5512,
      longitude: 126.9882,
      imageUrl: 'https://upload.wikimedia.org/wikipedia/commons/thumb/4/47/Namsan_Park_and_Seoul_Tower_%284615642044%29.jpg/500px-Namsan_Park_and_Seoul_Tower_%284615642044%29.jpg',
    ),
    HolySite(
      id: 'youngnak',
      name: '영락교회',
      description:
          '1945년 해방 후 한경직 목사가 월남한 이북 기독교인들과 함께 세운 교회. 분단의 아픔 속에서 신앙으로 하나 된 한국 교회의 상징입니다.',
      latitude: 37.5630,
      longitude: 126.9780,
      imageUrl: 'https://upload.wikimedia.org/wikipedia/commons/thumb/e/e8/Young_Nak_Church_2007.jpg/500px-Young_Nak_Church_2007.jpg',
    ),
    HolySite(
      id: 'myungsung',
      name: '명성교회',
      description:
          '1980년 김삼환 목사가 설립한 대형교회. 성경적 설교와 교육 목회로 성장하여 한국 교회의 모범이 된 교회입니다.',
      latitude: 37.5050,
      longitude: 127.0580,
      imageUrl: 'https://upload.wikimedia.org/wikipedia/commons/thumb/b/b0/MyungsungChurch.jpg/500px-MyungsungChurch.jpg',
    ),
    HolySite(
      id: 'onnuri',
      name: '온누리교회',
      description:
          '1985년 하용조 목사가 설립한 선교 중심의 교회. CGNTV 기독교 방송과 두날개 양육 시스템으로 한국 교회의 선교 비전을 제시하였습니다.',
      latitude: 37.5289,
      longitude: 126.9215,
      imageUrl: 'https://upload.wikimedia.org/wikipedia/commons/thumb/e/ea/140504_onnuri_seobi%40go.JPG/500px-140504_onnuri_seobi%40go.JPG',
    ),
    HolySite(
      id: 'sarang',
      name: '사랑의교회',
      description:
          '1978년 옥한흠 목사가 세운 제자훈련 중심의 교회. 평신도 제자훈련 운동을 통해 한국 교회 갱신에 큰 영향을 끼쳤습니다.',
      latitude: 37.4978,
      longitude: 127.0382,
      imageUrl: 'https://upload.wikimedia.org/wikipedia/commons/thumb/3/3c/Seocho_SaRang_Community_Church.jpg/500px-Seocho_SaRang_Community_Church.jpg',
    ),
    HolySite(
      id: 'somang',
      name: '소망교회',
      description:
          '1977년 곽선희 목사가 설립한 장로교회. 사회봉사와 선교에 헌신하며 한국 장로교회의 모범적인 목회를 보여준 교회입니다.',
      latitude: 37.5160,
      longitude: 127.0430,
      imageUrl: 'https://images.unsplash.com/photo-1510936111840-65e151ad71bb?w=500&h=250&fit=crop',
    ),
    HolySite(
      id: 'kwanglim',
      name: '광림교회',
      description:
          '1953년 설립된 서울의 대표적 감리교회. 김선도 목사의 사역으로 성장하여 사회 참여와 문화 선교의 모범을 보여준 교회입니다.',
      latitude: 37.5172,
      longitude: 127.0247,
      imageUrl: 'https://images.unsplash.com/photo-1510936111840-65e151ad71bb?w=500&h=250&fit=crop',
    ),
    HolySite(
      id: 'choonghyun',
      name: '충현교회',
      description:
          '1953년 설립된 서울 용산구의 장로교회. 한국전쟁 후 폐허 위에 세워져 신앙의 재건과 성장을 상징하는 교회입니다.',
      latitude: 37.5346,
      longitude: 126.9643,
      imageUrl: 'https://images.unsplash.com/photo-1510936111840-65e151ad71bb?w=500&h=250&fit=crop',
    ),
    HolySite(
      id: 'seoul_theological',
      name: '서울신학대학교',
      description:
          '1911년 설립된 성결교 신학교. 한국 성결교의 목회자를 양성해온 교육기관으로, 부천에 위치하여 복음주의 신학 교육을 이어가고 있습니다.',
      latitude: 37.4917,
      longitude: 126.7965,
      imageUrl: 'https://images.unsplash.com/photo-1541339907198-e08756dedf3f?w=500&h=250&fit=crop',
    ),

    // ===== 경기/인천 지역 =====
    HolySite(
      id: 'ganghwa_church',
      name: '강화 성공회 성당',
      description:
          '1900년 건립된 강화도의 역사적 성공회 교회. 한옥 양식과 서양 건축이 조화를 이룬 독특한 건물로, 초기 한국 기독교 토착화의 상징입니다.',
      latitude: 37.7470,
      longitude: 126.4869,
      imageUrl: 'https://upload.wikimedia.org/wikipedia/commons/thumb/a/a3/Ganghwa_Anglican_Church.jpg/500px-Ganghwa_Anglican_Church.jpg',
    ),
    HolySite(
      id: 'onsurigyohoe',
      name: '온수리교회 (강화)',
      description:
          '1902년 설립된 강화도의 감리교회. 강화도 일대 복음 전파의 거점이 되었으며, 한국 농촌 교회의 역사를 간직하고 있습니다.',
      latitude: 37.7080,
      longitude: 126.4330,
      imageUrl: 'https://images.unsplash.com/photo-1510936111840-65e151ad71bb?w=500&h=250&fit=crop',
    ),
    HolySite(
      id: 'suwon_first',
      name: '수원제일교회',
      description:
          '1900년 설립된 수원 최초의 개신교 교회. 경기 남부 지역 복음 전파의 중심지로, 100년이 넘는 역사를 자랑합니다.',
      latitude: 37.2638,
      longitude: 127.0286,
      imageUrl: 'https://images.unsplash.com/photo-1510936111840-65e151ad71bb?w=500&h=250&fit=crop',
    ),
    HolySite(
      id: 'anyang_first',
      name: '안양제일교회',
      description:
          '1906년 설립된 안양 지역 최초의 교회. 경기 남부 선교의 전초기지 역할을 하며 지역 사회에 복음과 교육의 빛을 전하였습니다.',
      latitude: 37.3943,
      longitude: 126.9568,
      imageUrl: 'https://images.unsplash.com/photo-1510936111840-65e151ad71bb?w=500&h=250&fit=crop',
    ),
    HolySite(
      id: 'incheon_naeri',
      name: '인천 내리교회',
      description:
          '1885년 설립된 인천 최초의 감리교회. 아펜젤러 선교사의 인천 상륙 이후 세워진 교회로, 인천 기독교 역사의 뿌리입니다.',
      latitude: 37.4757,
      longitude: 126.6340,
      imageUrl: 'https://upload.wikimedia.org/wikipedia/commons/thumb/0/0a/Naeri_Methodist_church.JPG/500px-Naeri_Methodist_church.JPG',
    ),
    HolySite(
      id: 'pocheon_prayer',
      name: '포천 기도원 (한국기독교연합회)',
      description:
          '한국전쟁 이후 설립된 기도원으로, 한국 기독교 부흥 기도 운동의 중심지 역할을 하였습니다. 많은 목회자와 성도들의 기도의 터전입니다.',
      latitude: 37.8949,
      longitude: 127.2003,
      imageUrl: 'https://images.unsplash.com/photo-1438232992991-995b7058bbb3?w=500&h=250&fit=crop',
    ),

    // ===== 충청권 =====
    HolySite(
      id: 'daejeon_first',
      name: '대전제일교회',
      description:
          '1902년 설립된 대전 최초의 개신교 교회. 충남 지역 선교의 거점으로, 대전 시민사회와 함께 성장해온 역사적 교회입니다.',
      latitude: 36.3302,
      longitude: 127.4296,
      imageUrl: 'https://images.unsplash.com/photo-1510936111840-65e151ad71bb?w=500&h=250&fit=crop',
    ),
    HolySite(
      id: 'cheonan_first',
      name: '천안제일교회',
      description:
          '1905년 설립된 천안 지역 최초의 장로교회. 충남 내륙 지역 복음 전파의 중심지로, 지역 교육과 사회봉사에 힘써왔습니다.',
      latitude: 36.8151,
      longitude: 127.1139,
      imageUrl: 'https://images.unsplash.com/photo-1510936111840-65e151ad71bb?w=500&h=250&fit=crop',
    ),
    HolySite(
      id: 'cheongju_first',
      name: '청주제일교회',
      description:
          '1904년 설립된 청주 최초의 개신교 교회. 충북 지역 선교의 시작점으로, 지역 사회에 기독교 교육과 의료 봉사를 제공하였습니다.',
      latitude: 36.6372,
      longitude: 127.4895,
      imageUrl: 'https://images.unsplash.com/photo-1510936111840-65e151ad71bb?w=500&h=250&fit=crop',
    ),
    HolySite(
      id: 'gongju_first',
      name: '공주제일교회',
      description:
          '1903년 미국 남장로교 선교사들이 설립한 공주 최초의 교회. 충남 내륙의 복음 전파 거점으로, 공주 영명학교를 함께 설립하였습니다.',
      latitude: 36.4467,
      longitude: 126.9264,
      imageUrl: 'https://images.unsplash.com/photo-1510936111840-65e151ad71bb?w=500&h=250&fit=crop',
    ),
    HolySite(
      id: 'youngmyung',
      name: '영명학교 (공주)',
      description:
          '1906년 미국 남장로교 선교사가 공주에 설립한 기독교 학교. 우리나라 독립운동가 유관순 열사가 이 학교 출신으로, 기독교 교육의 역사적 장소입니다.',
      latitude: 36.4480,
      longitude: 126.9250,
      imageUrl: 'https://images.unsplash.com/photo-1541339907198-e08756dedf3f?w=500&h=250&fit=crop',
    ),
    HolySite(
      id: 'chungju_first',
      name: '충주제일교회',
      description:
          '1901년 설립된 충주 최초의 개신교 교회. 충북 내륙 지역에 복음을 전한 선교사들의 헌신으로 세워진 교회입니다.',
      latitude: 36.9910,
      longitude: 127.9259,
      imageUrl: 'https://images.unsplash.com/photo-1510936111840-65e151ad71bb?w=500&h=250&fit=crop',
    ),
    HolySite(
      id: 'daejeon_hannam',
      name: '한남대학교',
      description:
          '1956년 설립된 기독교 대학. 대전 기독교 고등교육의 중심으로, 기독교 정신에 기반한 인재 양성에 힘써왔습니다.',
      latitude: 36.3547,
      longitude: 127.4216,
      imageUrl: 'https://upload.wikimedia.org/wikipedia/commons/thumb/c/cc/%ED%95%9C%EB%82%A8%EB%8C%80%ED%95%99%EA%B5%90_%EB%B4%84%EC%82%AC%EC%A7%84.jpg/500px-%ED%95%9C%EB%82%A8%EB%8C%80%ED%95%99%EA%B5%90_%EB%B4%84%EC%82%AC%EC%A7%84.jpg',
    ),
    HolySite(
      id: 'asan_memorial',
      name: '아산 순교기념관',
      description:
          '조선시대 기독교 박해 시기 순교한 신자들을 기리는 기념관. 초기 기독교인들의 신앙과 순교의 역사를 전시하고 있습니다.',
      latitude: 36.7898,
      longitude: 127.0018,
      imageUrl: 'https://images.unsplash.com/photo-1566127444979-b3d2b654e3d7?w=500&h=250&fit=crop',
    ),
    HolySite(
      id: 'danyang_church',
      name: '단양교회',
      description:
          '1907년 설립된 충북 단양의 역사적 교회. 소백산 자락의 작은 마을에서 시작되어 농촌 지역 복음화에 기여한 교회입니다.',
      latitude: 36.9847,
      longitude: 128.3655,
      imageUrl: 'https://images.unsplash.com/photo-1510936111840-65e151ad71bb?w=500&h=250&fit=crop',
    ),

    // ===== 경상권 =====
    HolySite(
      id: 'busan_sujeong',
      name: '부산 수정동교회',
      description:
          '1893년 호주 장로교 선교사가 설립한 부산의 초기 교회. 부산 복음화의 선구적 역할을 하며 경남 선교의 교두보가 되었습니다.',
      latitude: 35.1082,
      longitude: 129.0312,
      imageUrl: 'https://images.unsplash.com/photo-1510936111840-65e151ad71bb?w=500&h=250&fit=crop',
    ),
    HolySite(
      id: 'daegu_namsan',
      name: '대구 남산교회',
      description:
          '1895년 설립된 대구의 역사적 장로교회. 미국 북장로교 선교사 베어드가 세운 교회로, 대구 경북 선교 역사의 중심입니다.',
      latitude: 35.8621,
      longitude: 128.5920,
      imageUrl: 'https://images.unsplash.com/photo-1510936111840-65e151ad71bb?w=500&h=250&fit=crop',
    ),
    HolySite(
      id: 'gyeongju_first',
      name: '경주제일교회',
      description:
          '1901년 설립된 경주 최초의 개신교 교회. 천년 고도 경주에 복음을 전한 선교사들의 노력으로 세워진 교회입니다.',
      latitude: 35.8562,
      longitude: 129.2246,
      imageUrl: 'https://images.unsplash.com/photo-1510936111840-65e151ad71bb?w=500&h=250&fit=crop',
    ),
    HolySite(
      id: 'andong_first',
      name: '안동교회',
      description:
          '1909년 설립된 안동 지역의 대표 장로교회. 유교 문화가 강한 안동 지역에서 복음을 전파하며 기독교 공동체를 세운 교회입니다.',
      latitude: 36.5684,
      longitude: 128.7294,
      imageUrl: 'https://images.unsplash.com/photo-1510936111840-65e151ad71bb?w=500&h=250&fit=crop',
    ),
    HolySite(
      id: 'pohang_first',
      name: '포항제일교회',
      description:
          '1900년 설립된 포항 최초의 개신교 교회. 동해안 지역 선교의 거점으로, 포항과 영일만 일대에 복음을 전하였습니다.',
      latitude: 36.0190,
      longitude: 129.3435,
      imageUrl: 'https://images.unsplash.com/photo-1510936111840-65e151ad71bb?w=500&h=250&fit=crop',
    ),
    HolySite(
      id: 'masan_first',
      name: '마산문창교회',
      description:
          '1899년 설립된 경남 마산(현 창원) 최초의 교회. 호주 장로교 선교사들이 세웠으며, 경남 서부 지역 복음의 씨앗이 된 교회입니다.',
      latitude: 35.1821,
      longitude: 128.5736,
      imageUrl: 'https://images.unsplash.com/photo-1510936111840-65e151ad71bb?w=500&h=250&fit=crop',
    ),
    HolySite(
      id: 'jinju_first',
      name: '진주제일교회',
      description:
          '1905년 설립된 진주 최초의 개신교 교회. 경남 서부 내륙 지역 선교의 중심으로, 지역 교육과 의료 사업에도 큰 역할을 하였습니다.',
      latitude: 35.1900,
      longitude: 128.0847,
      imageUrl: 'https://images.unsplash.com/photo-1510936111840-65e151ad71bb?w=500&h=250&fit=crop',
    ),
    HolySite(
      id: 'gimhae_first',
      name: '김해교회',
      description:
          '1905년 설립된 김해 최초의 개신교 교회. 낙동강 유역의 농촌 지역에 복음을 전하며 지역 사회 발전에 기여하였습니다.',
      latitude: 35.2285,
      longitude: 128.8894,
      imageUrl: 'https://images.unsplash.com/photo-1510936111840-65e151ad71bb?w=500&h=250&fit=crop',
    ),
    HolySite(
      id: 'geochang_church',
      name: '거창교회',
      description:
          '1907년 설립된 거창 지역의 역사적 교회. 경남 내륙 산간 지역에서 교육과 의료를 통해 복음을 전파한 교회입니다.',
      latitude: 35.6868,
      longitude: 127.9094,
      imageUrl: 'https://images.unsplash.com/photo-1510936111840-65e151ad71bb?w=500&h=250&fit=crop',
    ),
    HolySite(
      id: 'keimyung',
      name: '계명대학교 (대구)',
      description:
          '1899년 미국 북장로교 선교사들이 설립한 기독교 대학. 대구·경북 지역의 기독교 고등교육을 선도해온 역사적 교육기관입니다.',
      latitude: 35.8569,
      longitude: 128.4886,
      imageUrl: 'https://images.unsplash.com/photo-1541339907198-e08756dedf3f?w=500&h=250&fit=crop',
    ),
    HolySite(
      id: 'tongyeong_church',
      name: '통영제일교회',
      description:
          '1899년 설립된 경남 통영 최초의 교회. 남해안 어촌 지역에 복음을 전한 호주 장로교 선교사들의 사역으로 세워졌습니다.',
      latitude: 34.8544,
      longitude: 128.4331,
      imageUrl: 'https://images.unsplash.com/photo-1510936111840-65e151ad71bb?w=500&h=250&fit=crop',
    ),
    HolySite(
      id: 'ulsan_first',
      name: '울산병영교회',
      description:
          '1900년 설립된 울산 최초의 개신교 교회. 경상도 동남부 해안 지역 복음화에 기여한 역사적 교회입니다.',
      latitude: 35.5569,
      longitude: 129.3132,
      imageUrl: 'https://images.unsplash.com/photo-1510936111840-65e151ad71bb?w=500&h=250&fit=crop',
    ),
    HolySite(
      id: 'dongsan_hospital',
      name: '동산병원 의료선교박물관 (대구)',
      description:
          '1899년 미국 북장로교 선교사 존슨이 설립한 대구 최초의 서양식 병원. 의료 선교를 통해 복음을 전하며 대구 근대 의학의 출발점이 되었습니다.',
      latitude: 35.8700,
      longitude: 128.5960,
      imageUrl: 'https://images.unsplash.com/photo-1566127444979-b3d2b654e3d7?w=500&h=250&fit=crop',
    ),

    // ===== 전라권 =====
    HolySite(
      id: 'jeonju_seomun',
      name: '전주 서문교회',
      description:
          '1893년 설립된 전주 최초의 장로교회. 미국 남장로교 선교사 레이놀즈가 세운 교회로, 호남 장로교의 뿌리가 된 교회입니다.',
      latitude: 35.8190,
      longitude: 127.1390,
      imageUrl: 'https://upload.wikimedia.org/wikipedia/commons/thumb/d/d5/%EC%A0%84%EC%A3%BC_%EC%84%9C%EB%AC%B8%EA%B5%90%ED%9A%8C.jpg/500px-%EC%A0%84%EC%A3%BC_%EC%84%9C%EB%AC%B8%EA%B5%90%ED%9A%8C.jpg',
    ),
    HolySite(
      id: 'gunsan_first',
      name: '군산구암교회',
      description:
          '1898년 미국 남장로교 전킨 선교사가 설립한 군산 최초의 교회. 군산항을 통해 들어온 선교사들의 전북 선교 본부 역할을 하였습니다.',
      latitude: 35.9838,
      longitude: 126.7185,
      imageUrl: 'https://images.unsplash.com/photo-1510936111840-65e151ad71bb?w=500&h=250&fit=crop',
    ),
    HolySite(
      id: 'mokpo_first',
      name: '목포양동교회',
      description:
          '1898년 미국 남장로교 선교사 유진 벨이 설립한 목포 최초의 교회. 전남 서남부 선교의 출발점이 된 교회입니다.',
      latitude: 34.7936,
      longitude: 126.3884,
      imageUrl: 'https://images.unsplash.com/photo-1510936111840-65e151ad71bb?w=500&h=250&fit=crop',
    ),
    HolySite(
      id: 'suncheon_first',
      name: '순천매산교회',
      description:
          '1907년 설립된 순천 지역의 대표 교회. 미국 남장로교 선교사들의 전남 동부 선교 거점으로, 의료와 교육 사업을 함께 펼쳤습니다.',
      latitude: 34.9506,
      longitude: 126.9511,
      imageUrl: 'https://images.unsplash.com/photo-1510936111840-65e151ad71bb?w=500&h=250&fit=crop',
    ),
    HolySite(
      id: 'yeosu_first',
      name: '여수제일교회',
      description:
          '1905년 설립된 여수 최초의 개신교 교회. 남해안 항구도시 여수에 복음을 전하며, 여수·순천 지역 기독교 공동체의 시작이 되었습니다.',
      latitude: 34.7604,
      longitude: 127.6622,
      imageUrl: 'https://images.unsplash.com/photo-1510936111840-65e151ad71bb?w=500&h=250&fit=crop',
    ),
    HolySite(
      id: 'jeongeup_church',
      name: '정읍교회',
      description:
          '1901년 설립된 전북 정읍의 역사적 교회. 동학농민운동의 발상지인 정읍에서 기독교가 새로운 희망을 전한 장소입니다.',
      latitude: 35.5698,
      longitude: 126.8567,
      imageUrl: 'https://images.unsplash.com/photo-1510936111840-65e151ad71bb?w=500&h=250&fit=crop',
    ),
    HolySite(
      id: 'namwon_church',
      name: '남원교회',
      description:
          '1904년 설립된 남원 지역의 역사적 교회. 지리산 자락의 남원에서 복음을 전하며 전북 남부 선교의 중심이 되었습니다.',
      latitude: 35.4164,
      longitude: 127.3900,
      imageUrl: 'https://images.unsplash.com/photo-1510936111840-65e151ad71bb?w=500&h=250&fit=crop',
    ),
    HolySite(
      id: 'gwangju_memorial',
      name: '광주 유진 벨 선교기념관',
      description:
          '한국 남부 선교의 아버지 유진 벨(배유지) 선교사를 기념하는 곳. 광주·전남 지역에 복음, 교육, 의료를 전한 그의 헌신을 기억합니다.',
      latitude: 35.1460,
      longitude: 126.9090,
      imageUrl: 'https://images.unsplash.com/photo-1555861496-0666c8981751?w=500&h=250&fit=crop',
    ),
    HolySite(
      id: 'honam_seminary',
      name: '호남신학대학교 (광주)',
      description:
          '1955년 설립된 호남 지역의 대표 장로교 신학교. 전남·전북 지역 목회자 양성의 중심으로, 호남 기독교 발전에 기여하고 있습니다.',
      latitude: 35.1590,
      longitude: 126.8840,
      imageUrl: 'https://images.unsplash.com/photo-1541339907198-e08756dedf3f?w=500&h=250&fit=crop',
    ),
    HolySite(
      id: 'iksan_church',
      name: '익산 남중교회',
      description:
          '1897년 설립된 전북 익산의 초기 교회. 이리(현 익산) 지역에 복음을 전한 미국 남장로교 선교의 결실입니다.',
      latitude: 35.9483,
      longitude: 126.9578,
      imageUrl: 'https://images.unsplash.com/photo-1510936111840-65e151ad71bb?w=500&h=250&fit=crop',
    ),

    // ===== 강원권 =====
    HolySite(
      id: 'wonju_first',
      name: '원주제일교회',
      description:
          '1903년 설립된 원주 최초의 개신교 교회. 강원도 내륙 지역 선교의 시작점으로, 원주 지역 사회 발전에도 기여한 교회입니다.',
      latitude: 37.3422,
      longitude: 127.9202,
      imageUrl: 'https://upload.wikimedia.org/wikipedia/commons/thumb/2/2a/Church_and_congregation%2C_Wonju%2C_%28s.d.%29_%28Taylor_box21num37%29.jpg/500px-Church_and_congregation%2C_Wonju%2C_%28s.d.%29_%28Taylor_box21num37%29.jpg',
    ),
    HolySite(
      id: 'chuncheon_first',
      name: '춘천제일교회',
      description:
          '1903년 설립된 춘천 최초의 장로교회. 강원도 중부 지역 복음 전파의 거점으로, 강원 선교의 역사를 간직한 교회입니다.',
      latitude: 37.8813,
      longitude: 127.7298,
      imageUrl: 'https://images.unsplash.com/photo-1510936111840-65e151ad71bb?w=500&h=250&fit=crop',
    ),
    HolySite(
      id: 'gangneung_first',
      name: '강릉제일교회',
      description:
          '1904년 설립된 강릉 최초의 개신교 교회. 영동 지역에 복음을 전한 캐나다 장로교 선교사들의 사역으로 세워졌습니다.',
      latitude: 37.7519,
      longitude: 128.8760,
      imageUrl: 'https://images.unsplash.com/photo-1510936111840-65e151ad71bb?w=500&h=250&fit=crop',
    ),
    HolySite(
      id: 'sokcho_church',
      name: '속초중앙교회',
      description:
          '한국전쟁 이후 이북 실향민 기독교인들이 모여 세운 교회. 실향민들의 신앙과 고향에 대한 그리움이 담긴 동해안의 역사적 교회입니다.',
      latitude: 38.2070,
      longitude: 128.5918,
      imageUrl: 'https://images.unsplash.com/photo-1510936111840-65e151ad71bb?w=500&h=250&fit=crop',
    ),
    HolySite(
      id: 'taebaek_church',
      name: '태백교회',
      description:
          '1915년 설립된 강원 태백의 교회. 탄광 지역 노동자들에게 복음과 위로를 전하며 산간 지역 선교의 역할을 감당한 교회입니다.',
      latitude: 37.1640,
      longitude: 128.9856,
      imageUrl: 'https://images.unsplash.com/photo-1510936111840-65e151ad71bb?w=500&h=250&fit=crop',
    ),
    HolySite(
      id: 'donghae_church',
      name: '동해교회',
      description:
          '1908년 설립된 동해(묵호) 지역의 교회. 동해안 어촌 마을에 복음을 전하며, 어민들의 삶에 희망을 준 교회입니다.',
      latitude: 37.5244,
      longitude: 129.1143,
      imageUrl: 'https://images.unsplash.com/photo-1510936111840-65e151ad71bb?w=500&h=250&fit=crop',
    ),
    HolySite(
      id: 'yongpyong_prayer',
      name: '용평 기도원',
      description:
          '대관령 자락에 위치한 기도원. 아름다운 자연 속에서 하나님과의 만남을 추구하는 기도와 수련의 장소입니다.',
      latitude: 37.6440,
      longitude: 128.6820,
      imageUrl: 'https://images.unsplash.com/photo-1438232992991-995b7058bbb3?w=500&h=250&fit=crop',
    ),
    HolySite(
      id: 'inje_church',
      name: '인제교회',
      description:
          '1910년 설립된 강원 인제의 역사적 교회. 설악산 인근 오지 산간 지역에서 복음을 전파한 개척 교회의 역사를 간직하고 있습니다.',
      latitude: 38.0697,
      longitude: 128.1706,
      imageUrl: 'https://images.unsplash.com/photo-1510936111840-65e151ad71bb?w=500&h=250&fit=crop',
    ),

    // ===== 제주 =====
    HolySite(
      id: 'jeju_first',
      name: '제주 성안교회',
      description:
          '1908년 설립된 제주도 최초의 개신교 교회. 이기풍 목사가 제주도에 처음 복음을 전하며 세운 교회로, 섬 선교의 역사적 출발점입니다.',
      latitude: 33.5138,
      longitude: 126.5295,
      imageUrl: 'https://images.unsplash.com/photo-1510936111840-65e151ad71bb?w=500&h=250&fit=crop',
    ),
    HolySite(
      id: 'seogwipo_church',
      name: '서귀포교회',
      description:
          '1912년 설립된 서귀포 최초의 교회. 제주도 남부 지역에 복음을 전하며, 한라산 남쪽 해안 마을 선교의 시작이 된 교회입니다.',
      latitude: 33.2541,
      longitude: 126.5606,
      imageUrl: 'https://images.unsplash.com/photo-1510936111840-65e151ad71bb?w=500&h=250&fit=crop',
    ),
    HolySite(
      id: 'hallim_church',
      name: '한림교회',
      description:
          '1918년 설립된 제주 서부 한림의 교회. 제주 서쪽 해안 지역 복음화에 기여하며, 바다와 바람의 섬에서 신앙의 등대 역할을 하였습니다.',
      latitude: 33.4140,
      longitude: 126.2655,
      imageUrl: 'https://images.unsplash.com/photo-1510936111840-65e151ad71bb?w=500&h=250&fit=crop',
    ),
    HolySite(
      id: 'jeju_museum',
      name: '제주 기독교 역사기념관',
      description:
          '제주도 기독교 100년 역사를 기록한 기념관. 이기풍 목사의 제주 선교부터 현대까지 제주 교회의 발자취를 전시하고 있습니다.',
      latitude: 33.5100,
      longitude: 126.5270,
      imageUrl: 'https://images.unsplash.com/photo-1566127444979-b3d2b654e3d7?w=500&h=250&fit=crop',
    ),

    // ===== 북한 지역 (역사적 장소) =====
    HolySite(
      id: 'pyongyang_sungshil',
      name: '숭실학교 터 (평양)',
      description:
          '1897년 베어드 선교사가 평양에 설립한 한국 최초의 기독교 대학. 현재 숭실대학교의 전신으로, 기독교 고등교육의 출발점입니다.',
      latitude: 39.0194,
      longitude: 125.7386,
      imageUrl: 'https://images.unsplash.com/photo-1541339907198-e08756dedf3f?w=500&h=250&fit=crop',
    ),
    HolySite(
      id: 'pyongyang_revival',
      name: '평양 남산현교회 터',
      description:
          '1907년 평양 대부흥 운동이 일어난 또 다른 교회. 길선주 장로의 회개 운동이 시작되어 전국적 성령 부흥으로 이어진 역사적 장소입니다.',
      latitude: 39.0120,
      longitude: 125.7450,
      imageUrl: 'https://images.unsplash.com/photo-1438232992991-995b7058bbb3?w=500&h=250&fit=crop',
    ),
    HolySite(
      id: 'wonsan_church',
      name: '원산 부흥회 터',
      description:
          '1903년 하디 선교사 주도의 원산 부흥회가 열린 곳. 평양 대부흥의 전초가 된 성령 운동이 시작된 곳으로, 한국 부흥 운동의 기원입니다.',
      latitude: 39.1533,
      longitude: 127.4433,
      imageUrl: 'https://images.unsplash.com/photo-1438232992991-995b7058bbb3?w=500&h=250&fit=crop',
    ),
    HolySite(
      id: 'sinuiju_church',
      name: '신의주교회 터',
      description:
          '1899년 설립된 평안북도 신의주의 역사적 교회. 압록강변 국경도시에서 만주 선교의 전초기지 역할을 하였던 교회입니다.',
      latitude: 40.1006,
      longitude: 124.3981,
      imageUrl: 'https://images.unsplash.com/photo-1510936111840-65e151ad71bb?w=500&h=250&fit=crop',
    ),
    HolySite(
      id: 'hamheung_church',
      name: '함흥 영생교회 터',
      description:
          '1898년 캐나다 장로교 선교사가 설립한 함경도 대표 교회. 함경남도 지역 복음 전파의 중심으로, 동북 지역 선교의 거점이었습니다.',
      latitude: 39.9184,
      longitude: 127.5348,
      imageUrl: 'https://images.unsplash.com/photo-1510936111840-65e151ad71bb?w=500&h=250&fit=crop',
    ),

    // ===== 기념관·박물관 추가 =====
    HolySite(
      id: 'soongsil_univ',
      name: '숭실대학교 한국기독교박물관',
      description:
          '평양 숭실학교의 전통을 이어받은 숭실대학교 내 박물관. 한국 기독교 역사 자료와 유물을 소장·전시하며, 초기 선교 역사를 보존하고 있습니다.',
      latitude: 37.4969,
      longitude: 126.9572,
      imageUrl: 'https://images.unsplash.com/photo-1566127444979-b3d2b654e3d7?w=500&h=250&fit=crop',
    ),
    HolySite(
      id: 'bible_museum',
      name: '대한성서공회 성서박물관',
      description:
          '한국어 성경 번역의 역사와 다양한 판본을 전시하는 박물관. 한글 성경의 탄생부터 현대까지 성서 보급의 역사를 한눈에 볼 수 있습니다.',
      latitude: 37.5693,
      longitude: 126.9830,
      imageUrl: 'https://images.unsplash.com/photo-1566127444979-b3d2b654e3d7?w=500&h=250&fit=crop',
    ),
    HolySite(
      id: 'christian_museum_seoul',
      name: '한국기독교역사박물관 (서울)',
      description:
          '한국 기독교 140여 년의 역사를 총망라한 박물관. 초기 선교사 유물, 한글 성경, 교회 역사 자료 등을 전시하고 있습니다.',
      latitude: 37.5680,
      longitude: 126.9860,
      imageUrl: 'https://images.unsplash.com/photo-1566127444979-b3d2b654e3d7?w=500&h=250&fit=crop',
    ),
    HolySite(
      id: 'appenzeller_memorial',
      name: '아펜젤러 기념관 (배재대)',
      description:
          '한국 개신교 선교의 선구자 아펜젤러 선교사를 기념하는 곳. 배재대학교 내에 위치하며, 그의 선교와 교육 사역을 기리고 있습니다.',
      latitude: 36.3210,
      longitude: 127.4320,
      imageUrl: 'https://upload.wikimedia.org/wikipedia/commons/thumb/0/0a/Pai_Chai_high_school%2C_Seoul%2C_%28s.d.%29_%28Taylor_box21num40%29.jpg/500px-Pai_Chai_high_school%2C_Seoul%2C_%28s.d.%29_%28Taylor_box21num40%29.jpg',
    ),
    HolySite(
      id: 'mokpo_memorial',
      name: '목포 선교역사관',
      description:
          '전남 목포의 기독교 선교 역사를 전시하는 기념관. 유진 벨, 오웬 등 남장로교 선교사들의 의료·교육 선교 역사를 보존하고 있습니다.',
      latitude: 34.7940,
      longitude: 126.3870,
      imageUrl: 'https://images.unsplash.com/photo-1566127444979-b3d2b654e3d7?w=500&h=250&fit=crop',
    ),
    HolySite(
      id: 'gyeongsan_memorial',
      name: '경산 자인 선교기념관',
      description:
          '경북 경산 자인 지역의 초기 기독교 선교 역사를 기념하는 곳. 미국 북장로교 선교사들의 경북 선교 활동을 기록하고 있습니다.',
      latitude: 35.8167,
      longitude: 128.7333,
      imageUrl: 'https://images.unsplash.com/photo-1566127444979-b3d2b654e3d7?w=500&h=250&fit=crop',
    ),

    // ===== 교육기관 추가 =====
    HolySite(
      id: 'yonsei_univ',
      name: '연세대학교 (신촌)',
      description:
          '1885년 언더우드 선교사가 설립한 경신학교에서 출발한 기독교 대학. 한국 기독교 고등교육의 상징으로, 진리와 자유의 정신을 이어가고 있습니다.',
      latitude: 37.5650,
      longitude: 126.9386,
      imageUrl: 'https://upload.wikimedia.org/wikipedia/commons/thumb/7/76/Main_Library_at_Yonsei_University.jpg/500px-Main_Library_at_Yonsei_University.jpg',
    ),
    HolySite(
      id: 'sungkyunkwan_christ',
      name: '숭의학교 (인천)',
      description:
          '1903년 미국 북장로교 선교사가 인천에 설립한 기독교 학교. 인천 지역 기독교 교육의 선구적 역할을 하였습니다.',
      latitude: 37.4680,
      longitude: 126.6510,
      imageUrl: 'https://images.unsplash.com/photo-1541339907198-e08756dedf3f?w=500&h=250&fit=crop',
    ),
    HolySite(
      id: 'keimyung_school',
      name: '계성학교 (대구)',
      description:
          '1906년 미국 북장로교 선교사 아담스가 대구에 설립한 기독교 학교. 대구·경북 기독교 교육의 요람으로, 많은 인재를 배출하였습니다.',
      latitude: 35.8690,
      longitude: 128.5900,
      imageUrl: 'https://images.unsplash.com/photo-1541339907198-e08756dedf3f?w=500&h=250&fit=crop',
    ),
    HolySite(
      id: 'jeonbuk_theological',
      name: '전북신학교 (전주)',
      description:
          '전북 지역 목회자 양성을 위한 신학 교육기관. 호남 서부 지역 교회 지도자를 배출하며 지역 교회 성장에 기여해왔습니다.',
      latitude: 35.8200,
      longitude: 127.1480,
      imageUrl: 'https://images.unsplash.com/photo-1541339907198-e08756dedf3f?w=500&h=250&fit=crop',
    ),

    // ===== 추가 역사적 교회·성지 =====
    HolySite(
      id: 'pyeongtaek_church',
      name: '평택제일교회',
      description:
          '1905년 설립된 경기 남부 평택의 역사적 교회. 미군 기지 인근 도시에서 한미 기독교 교류의 장이 되기도 한 교회입니다.',
      latitude: 36.9921,
      longitude: 127.0857,
      imageUrl: 'https://images.unsplash.com/photo-1510936111840-65e151ad71bb?w=500&h=250&fit=crop',
    ),
    HolySite(
      id: 'jecheon_church',
      name: '제천교회',
      description:
          '1905년 설립된 충북 제천의 역사적 교회. 소백산 기슭의 내륙 도시에서 복음을 전하며, 충북 동부 선교의 거점 역할을 하였습니다.',
      latitude: 37.1325,
      longitude: 128.2129,
      imageUrl: 'https://images.unsplash.com/photo-1510936111840-65e151ad71bb?w=500&h=250&fit=crop',
    ),
    HolySite(
      id: 'yeongju_church',
      name: '영주제일교회',
      description:
          '1906년 설립된 경북 영주의 역사적 교회. 소백산 남쪽 유교 문화권에서 기독교 복음을 전파하며 세워진 교회입니다.',
      latitude: 36.8057,
      longitude: 128.6241,
      imageUrl: 'https://images.unsplash.com/photo-1510936111840-65e151ad71bb?w=500&h=250&fit=crop',
    ),
    HolySite(
      id: 'gimcheon_church',
      name: '김천제일교회',
      description:
          '1901년 설립된 경북 김천의 초기 교회. 추풍령 인근 교통 요지에서 경상도와 충청도를 잇는 선교의 중심지 역할을 하였습니다.',
      latitude: 36.1198,
      longitude: 128.1135,
      imageUrl: 'https://images.unsplash.com/photo-1510936111840-65e151ad71bb?w=500&h=250&fit=crop',
    ),
    HolySite(
      id: 'sacheon_church',
      name: '사천교회',
      description:
          '1903년 설립된 경남 사천의 역사적 교회. 남해안 해안 지역에서 복음을 전하며 어촌과 농촌의 성도들을 품은 교회입니다.',
      latitude: 35.0731,
      longitude: 128.0644,
      imageUrl: 'https://images.unsplash.com/photo-1510936111840-65e151ad71bb?w=500&h=250&fit=crop',
    ),
    HolySite(
      id: 'changnyeong_church',
      name: '창녕교회',
      description:
          '1904년 설립된 경남 창녕의 교회. 낙동강 중류 유역에서 호주 장로교 선교사들의 사역으로 세워진 농촌 교회입니다.',
      latitude: 35.5442,
      longitude: 128.4934,
      imageUrl: 'https://images.unsplash.com/photo-1510936111840-65e151ad71bb?w=500&h=250&fit=crop',
    ),
    HolySite(
      id: 'hampyeong_church',
      name: '함평교회',
      description:
          '1906년 설립된 전남 함평의 교회. 나비 축제로 유명한 함평 지역에서 복음을 전하며 농촌 지역 교회 성장의 모범을 보였습니다.',
      latitude: 35.0660,
      longitude: 126.5166,
      imageUrl: 'https://images.unsplash.com/photo-1510936111840-65e151ad71bb?w=500&h=250&fit=crop',
    ),
    HolySite(
      id: 'hwasun_church',
      name: '화순교회',
      description:
          '1907년 설립된 전남 화순의 역사적 교회. 무등산 남쪽 탄광 지역에서 지역 주민들에게 복음과 위로를 전한 교회입니다.',
      latitude: 35.0634,
      longitude: 126.9869,
      imageUrl: 'https://images.unsplash.com/photo-1510936111840-65e151ad71bb?w=500&h=250&fit=crop',
    ),
    HolySite(
      id: 'naju_church',
      name: '나주교회',
      description:
          '1904년 설립된 전남 나주의 역사적 교회. 영산강 유역의 곡창지대에서 미국 남장로교 선교사들의 사역으로 세워졌습니다.',
      latitude: 34.9843,
      longitude: 126.7119,
      imageUrl: 'https://images.unsplash.com/photo-1510936111840-65e151ad71bb?w=500&h=250&fit=crop',
    ),
    HolySite(
      id: 'boryeong_church',
      name: '보령교회',
      description:
          '1905년 설립된 충남 보령의 교회. 서해안 해안 도시에서 복음을 전하며, 충남 서부 지역 선교에 기여한 교회입니다.',
      latitude: 36.3333,
      longitude: 126.6128,
      imageUrl: 'https://images.unsplash.com/photo-1510936111840-65e151ad71bb?w=500&h=250&fit=crop',
    ),
    HolySite(
      id: 'nonsan_church',
      name: '논산교회',
      description:
          '1904년 설립된 충남 논산의 역사적 교회. 계룡산과 금강 사이의 내륙 도시에서 농촌 선교의 거점 역할을 하였습니다.',
      latitude: 36.1872,
      longitude: 127.0987,
      imageUrl: 'https://images.unsplash.com/photo-1510936111840-65e151ad71bb?w=500&h=250&fit=crop',
    ),
    HolySite(
      id: 'samcheok_church',
      name: '삼척교회',
      description:
          '1911년 설립된 강원 삼척의 교회. 동해안 깊은 산골 지역까지 복음을 전한 개척 선교의 역사를 간직하고 있습니다.',
      latitude: 37.4499,
      longitude: 129.1652,
      imageUrl: 'https://images.unsplash.com/photo-1510936111840-65e151ad71bb?w=500&h=250&fit=crop',
    ),
    HolySite(
      id: 'yeongwol_church',
      name: '영월교회',
      description:
          '1908년 설립된 강원 영월의 교회. 깊은 산간 오지에서 복음을 전하며, 탄광촌 지역 성도들을 돌본 교회입니다.',
      latitude: 37.1838,
      longitude: 128.4617,
      imageUrl: 'https://images.unsplash.com/photo-1510936111840-65e151ad71bb?w=500&h=250&fit=crop',
    ),
    HolySite(
      id: 'cheorwon_church',
      name: '철원교회 터',
      description:
          '한국전쟁 이전 강원 철원에 존재하던 교회. 분단으로 인해 접근할 수 없는 곳이 되었으나, 통일을 꿈꾸는 기독교인들의 기도 장소입니다.',
      latitude: 38.1467,
      longitude: 127.3133,
      imageUrl: 'https://images.unsplash.com/photo-1555861496-0666c8981751?w=500&h=250&fit=crop',
    ),
    HolySite(
      id: 'goseong_church',
      name: '고성교회',
      description:
          '1905년 설립된 강원 고성의 교회. DMZ 인근 최북단 해안 도시에서 통일을 기원하며 신앙을 지켜온 교회입니다.',
      latitude: 38.3806,
      longitude: 128.4678,
      imageUrl: 'https://images.unsplash.com/photo-1510936111840-65e151ad71bb?w=500&h=250&fit=crop',
    ),
    HolySite(
      id: 'oseong_prayer',
      name: '오성 산기도원 (양평)',
      description:
          '경기 양평에 위치한 기도원. 북한강이 내려다보이는 산 위에서 한국 교회의 부흥과 민족의 회복을 위한 기도가 이어지는 곳입니다.',
      latitude: 37.4900,
      longitude: 127.4870,
      imageUrl: 'https://images.unsplash.com/photo-1438232992991-995b7058bbb3?w=500&h=250&fit=crop',
    ),
  ];

  /// holy_sites 컬렉션이 비어있으면 시드 데이터 삽입
  Future<bool> seedIfEmpty() async {
    try {
      final snapshot = await _firestore.collection('holy_sites').limit(1).get();

      if (snapshot.docs.isNotEmpty) {
        // 이미 데이터가 있음
        return false;
      }

      // 배치 쓰기로 모든 성지 한 번에 삽입
      final batch = _firestore.batch();

      for (final site in seedSites) {
        final docRef = _firestore.collection('holy_sites').doc(site.id);
        batch.set(docRef, {
          'name': site.name,
          'description': site.description,
          'latitude': site.latitude,
          'longitude': site.longitude,
          'imageUrl': site.imageUrl,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }

      await batch.commit();
      return true; // 시드 완료
    } catch (e) {
      // 시드 실패해도 앱 동작에 영향 없도록 조용히 무시
      return false;
    }
  }

  /// Firestore에서 모든 성지 목록 가져오기
  Future<List<HolySite>> getAllSites() async {
    try {
      final snapshot = await _firestore.collection('holy_sites').get();
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return HolySite(
          id: doc.id,
          name: data['name'] as String? ?? '',
          description: data['description'] as String? ?? '',
          latitude: (data['latitude'] as num?)?.toDouble() ?? 0.0,
          longitude: (data['longitude'] as num?)?.toDouble() ?? 0.0,
          imageUrl: data['imageUrl'] as String? ?? '',
        );
      }).toList();
    } catch (e) {
      return [];
    }
  }

  /// 성지 목록 스트림 (실시간 업데이트)
  Stream<List<HolySite>> watchAllSites() {
    return _firestore.collection('holy_sites').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return HolySite(
          id: doc.id,
          name: data['name'] as String? ?? '',
          description: data['description'] as String? ?? '',
          latitude: (data['latitude'] as num?)?.toDouble() ?? 0.0,
          longitude: (data['longitude'] as num?)?.toDouble() ?? 0.0,
          imageUrl: data['imageUrl'] as String? ?? '',
        );
      }).toList();
    });
  }
}
