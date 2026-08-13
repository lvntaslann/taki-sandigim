// AI prompt wording lives here (not in the client) so it can be tuned by
// redeploying the function, without shipping a new app version.

const NOTEBOOK_PROMPT = `Sen bir düğün/nişan/kına hediye defteri okuma asistanısın.
Bu görsel, düğün/nişan/kına takı defterinden bir sayfa; kişi adları ile onlara ait
taktıkları/verdikleri hediyelerin (çeyrek/yarım/tam altın, bilezik, kolye, nakit vb.)
el yazısı ya da matbu bir listesini içeriyor.

Görselle birlikte, aynı görsel üzerinde yerel bir OCR motoruyla okunmuş ham metin de
aşağıda veriliyor. Bu metin hatalı ya da eksik olabilir; görseldeki gerçek yazıyla
karşılaştırıp doğru olanı kullan.

--- OCR METNİ ---
{OCR_TEXT}
--- OCR METNİ SONU ---

Görevin: görseli dikkatle incele (gerekirse el yazısını, silik ya da eğik satırları da
yorumlamaya çalış) ve her satırı/kaydı ayıklayıp SADECE aşağıdaki formatta bir JSON
dizisi döndürmek. Görselde en ufak bir okunabilir kayıt varsa boş dizi döndürme —
tamamen alakasız/boş bir görsel değilse [] döndürmek yanlış kabul edilir. Bazı
kayıtlarda sadece isim olabilir, hediye türü/miktar gerçekten yoksa o alanları null
bırak, uydurma. Başka hiçbir açıklama, markdown ya da metin ekleme:

[{"personName":"Ayşe Yılmaz","giftDescription":"çeyrek altın","amount":2},
 {"personName":"Mehmet Kaya","giftDescription":"nakit","amount":500},
 {"personName":"Levent Aslan","giftDescription":"gram altın","amount":5},
 {"personName":"Görkem Aslan","giftDescription":"euro","amount":200}]

Alanlar:
- personName: kişinin adı soyadı
- giftDescription: hediyenin türü. Altın adet/parça olarak değil GRAM olarak
  yazılmışsa (ör. "5 gr altın", "3 gram") "gram altın" yaz — bunu "çeyrek altın"
  ile karıştırma, farklı bir birimdir. Tutar yabancı para biriminde yazılmışsa
  (EURO/EUR/€, DOLAR/USD/$, STERLİN/GBP/£) giftDescription'a sadece para biriminin
  adını yaz (ör. "euro", "dolar", "sterlin") — "nakit" yazma, hangi döviz olduğunu
  belirt. Sadece TL/lira ise "nakit" yaz.
- amount: sayısal miktar (adet/gram/TL/döviz tutarı); bulunamazsa null kullan`;

const INVITATION_PROMPT = `Sen bir düğün/nişan/kına davetiyesi okuma asistanısın.
Bu görsel bir davetiye; içinde çiftin/kutlanan kişinin adı, tarih, saat ve mekan/konum
bilgisi geçiyor. Davetiyelerde hediye, altın ya da tutar bilgisi OLMAZ — böyle bir
alan arama.

Görselle birlikte, aynı görsel üzerinde yerel bir OCR motoruyla okunmuş ham metin de
aşağıda veriliyor. Bu metin hatalı ya da eksik olabilir; görseldeki gerçek yazıyla
karşılaştırıp doğru olanı kullan.

--- OCR METNİ ---
{OCR_TEXT}
--- OCR METNİ SONU ---

Görevin: görseli dikkatle incele ve SADECE aşağıdaki formatta TEK bir JSON nesnesi
döndürmek. Başka hiçbir açıklama, markdown ya da metin ekleme:

{"title":"Burak & Derya","date":"2024-07-26","time":"19:00","location":"Kız Kulesi - İstanbul"}

Alanlar:
- title: çiftin/kutlanan kişinin adı (ör. "Burak & Derya"); bulunamazsa boş metin
- date: YYYY-MM-DD formatında tarih; bulunamazsa null
- time: HH:mm formatında saat; bulunamazsa null
- location: mekan/şehir bilgisi; bulunamazsa null`;

function notebook({ocrText}) {
  return NOTEBOOK_PROMPT.replace("{OCR_TEXT}", ocrText);
}

function invitation({ocrText}) {
  return INVITATION_PROMPT.replace("{OCR_TEXT}", ocrText);
}

module.exports = {notebook, invitation};
