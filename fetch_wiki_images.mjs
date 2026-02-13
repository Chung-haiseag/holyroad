// 위키미디어 커먼즈 API로 성지 이미지 검색 스크립트
const sites = [
  { id: 'yanghwajin', search: 'Yanghwajin Foreign Missionary Cemetery' },
  { id: 'jeongdong', search: 'Chungdong First Methodist Church Seoul' },
  { id: 'saemoonan', search: 'Saemoonan Church Seoul' },
  { id: 'underwood', search: 'Underwood Hall Yonsei University' },
  { id: 'yeouidofc', search: 'Yoido Full Gospel Church' },
  { id: 'seungdong', search: 'Seungdong Church Seoul' },
  { id: 'yondong', search: 'Yondong Presbyterian Church Seoul' },
  { id: 'paichai', search: 'Pai Chai Hakdang Seoul' },
  { id: 'ewha', search: 'Ewha Womans University Main Hall' },
  { id: 'severance', search: 'Severance Hospital Yonsei' },
  { id: 'youngnak', search: 'Youngnak Presbyterian Church Seoul' },
  { id: 'myungsung', search: 'Myungsung Church Seoul' },
  { id: 'onnuri', search: 'Onnuri Church Seoul' },
  { id: 'sarang', search: 'Sarang Church Seoul' },
  { id: 'somang', search: 'Somang Church Seoul' },
  { id: 'kwanglim', search: 'Kwanglim Methodist Church Seoul' },
  { id: 'ganghwa_church', search: 'Ganghwa Anglican Church Korea' },
  { id: 'incheon_naeri', search: 'Naeri Methodist Church Incheon' },
  { id: 'daegu_first', search: 'Daegu First Presbyterian Church' },
  { id: 'gwangju_yangrim', search: 'Yangrim Church Gwangju' },
  { id: 'busan_choryang', search: 'Choryang Church Busan' },
  { id: 'samilpo', search: 'Tapgol Park Seoul March 1st' },
  { id: 'jeonju_seomun', search: 'Jeonju Seomun Church' },
  { id: 'dongsan_hospital', search: 'Dongsan Hospital Daegu missionary' },
  { id: 'keimyung', search: 'Keimyung University Daegu' },
  { id: 'soongsil_univ', search: 'Soongsil University Seoul' },
  { id: 'yonsei_univ', search: 'Yonsei University Sinchon campus' },
  { id: 'bible_museum', search: 'Korean Bible Society Seoul' },
  { id: 'appenzeller_memorial', search: 'Appenzeller missionary Korea Pai Chai' },
  { id: 'jeju_first', search: 'Jeju Seongan Church' },
  { id: 'choonghyun', search: 'Choonghyun Church Seoul' },
  { id: 'seoul_theological', search: 'Seoul Theological University Bucheon' },
  { id: 'yongsan_shinhak', search: 'Chongshin University Seoul' },
  { id: 'chungdong', search: 'Chungdong Methodist Church Seoul' },
  { id: 'namsan_prayer', search: 'Namsan Seoul tower' },
  { id: 'daejeon_first', search: 'Daejeon First Church' },
  { id: 'cheongju_first', search: 'Cheongju First Church' },
  { id: 'wonju_first', search: 'Wonju First Church' },
  { id: 'chuncheon_first', search: 'Chuncheon First Church' },
  { id: 'gangneung_first', search: 'Gangneung First Church' },
  { id: 'mokpo_first', search: 'Mokpo Yangdong Church' },
  { id: 'gunsan_first', search: 'Gunsan Guam Church' },
  { id: 'suncheon_first', search: 'Suncheon Maesan Church' },
  { id: 'andong_first', search: 'Andong Church Presbyterian' },
  { id: 'gyeongju_first', search: 'Gyeongju Church Presbyterian' },
  { id: 'daejeon_hannam', search: 'Hannam University Daejeon' },
  { id: 'youngmyung', search: 'Youngmyung School Gongju' },
  { id: 'honam_seminary', search: 'Honam Theological University Gwangju' },
  { id: 'keimyung_school', search: 'Keiseong School Daegu Adams' },
  { id: 'gwangju_memorial', search: 'Eugene Bell missionary Gwangju' },
  { id: 'mokpo_memorial', search: 'Mokpo missionary museum' },
];

async function searchWikimedia(query) {
  const url = `https://commons.wikimedia.org/w/api.php?action=query&list=search&srsearch=${encodeURIComponent(query)}&srnamespace=6&srlimit=3&format=json&origin=*`;
  try {
    const res = await fetch(url);
    const data = await res.json();
    const results = data.query?.search || [];
    if (results.length === 0) return null;

    // 첫 번째 결과의 파일명 추출
    const title = results[0].title; // "File:Something.jpg"
    return title;
  } catch (e) {
    return null;
  }
}

async function getImageUrl(fileTitle) {
  const url = `https://commons.wikimedia.org/w/api.php?action=query&titles=${encodeURIComponent(fileTitle)}&prop=imageinfo&iiprop=url&iiurlwidth=400&format=json&origin=*`;
  try {
    const res = await fetch(url);
    const data = await res.json();
    const pages = data.query?.pages || {};
    const page = Object.values(pages)[0];
    if (page?.imageinfo?.[0]) {
      return page.imageinfo[0].thumburl || page.imageinfo[0].url;
    }
    return null;
  } catch (e) {
    return null;
  }
}

async function main() {
  const results = {};

  for (const site of sites) {
    process.stdout.write(`검색 중: ${site.id} (${site.search})... `);
    const fileTitle = await searchWikimedia(site.search);

    if (fileTitle) {
      const imageUrl = await getImageUrl(fileTitle);
      if (imageUrl) {
        results[site.id] = imageUrl;
        console.log(`✅ ${imageUrl.substring(0, 80)}...`);
      } else {
        console.log(`❌ URL 변환 실패`);
      }
    } else {
      console.log(`❌ 이미지 없음`);
    }

    // API rate limit 방지
    await new Promise(r => setTimeout(r, 200));
  }

  console.log('\n\n=== 결과 JSON ===');
  console.log(JSON.stringify(results, null, 2));
  console.log(`\n총 ${Object.keys(results).length}/${sites.length}개 이미지 발견`);
}

main();
