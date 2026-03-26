# Hatalar

## Göz Ardı Edilenler
+ Admin olmayan kullanıcılar kulanıcı ekleyip silebiliyor başkasının parolasını değiştirebiliyor? 
(hatta admin olmayanlar kulanıcılar side menüsünü görmemeli mi?)
+ Kullanıcılar kendi kendilerinin girişini kitleyebilir (neden?)
+ Platform (platformlar sayfası) name unique değil (olmalı mı?)
+ Admin kulanıcıları havuzun altındaki isterleri silebiliyor olmalı mı?
+ Excel import hatalı

## Askıdakiler
+ log time hatalı global saat hatası -3 saat gözüküyot gmt+3 türkiye saati kullan

## Yapılanlar
+ Toplu upload route eklendi.
+ TA SGÖ ilişki kuralı eklendi.
+ Konfigürasayon silince ve eklenince değişiklik logu basmalı mı?
+ Platform silince ve eklenince değişiklik logu basmalı mı?
+ Havuz isterlerde maddeler (bullet) güncellenince değişiklik log basılmıyor.
+ tablo güncelede modal adı tablo ekle
+ Havuz isterlerde Tablolar güncellenemiyor silinemiyor.
+ Yeni column eklendi. 
```` 
ALTER TABLE Log
ADD Tur VARCHAR(10); 
```` 
+ Log sayfasında türe göre friltreleme eklendi.
+ Log sayfasında tür listelendi.
+ tabloda satır sütünlar güncellenince de log basılmalı mı?
+ tablo silme güncelleme platform isterde de gerekli mi?