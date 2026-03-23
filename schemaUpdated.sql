-- Veritabanýný oluþtur ve seç
CREATE DATABASE IF NOT EXISTS sql8820996 CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE sql8820996;

-- Kullanýcý tablosu
CREATE TABLE IF NOT EXISTS kullanici (
    KullaniciID INT AUTO_INCREMENT PRIMARY KEY,
    KullaniciAdi VARCHAR(100) NOT NULL UNIQUE,
    Sifre VARCHAR(255) NOT NULL,
    AdSoyad VARCHAR(200),
    AktifMi TINYINT(1) DEFAULT 1
);

-- Konfigürasyon listesi
CREATE TABLE IF NOT EXISTS konfig_list (
    KonfigID INT AUTO_INCREMENT PRIMARY KEY,
    KonfigAdi VARCHAR(200) NOT NULL
);

-- Platform listesi
CREATE TABLE IF NOT EXISTS platform_list (
    PlatformID INT AUTO_INCREMENT PRIMARY KEY,
    PlatformAdi VARCHAR(200) NOT NULL,
    HavuzMu TINYINT(1) DEFAULT 0
);

-- Platform-Konfig iliþkisi
CREATE TABLE IF NOT EXISTS platform_konfig (
    PlatformKonfigID INT AUTO_INCREMENT PRIMARY KEY,
    PlatformID INT NOT NULL,
    KonfigID INT NOT NULL,
    UNIQUE KEY (PlatformID, KonfigID),
    FOREIGN KEY (PlatformID) REFERENCES platform_list(PlatformID) ON DELETE CASCADE,
    FOREIGN KEY (KonfigID) REFERENCES konfig_list(KonfigID) ON DELETE CASCADE
);

-- Seviye tanýmlarý
CREATE TABLE IF NOT EXISTS seviye_tanim (
    SeviyeID INT AUTO_INCREMENT PRIMARY KEY,
    PlatformID INT NOT NULL,
    SeviyeNo INT NOT NULL,
    SeviyeAdi VARCHAR(100) NOT NULL,
    UNIQUE KEY (PlatformID, SeviyeNo),
    FOREIGN KEY (PlatformID) REFERENCES platform_list(PlatformID) ON DELETE CASCADE
);

-- Test aþamalarý
CREATE TABLE IF NOT EXISTS test_asama (
    TestAsamaID INT AUTO_INCREMENT PRIMARY KEY,
    PlatformID INT NOT NULL,
    AsamaNo INT NOT NULL,
    AsamaAdi VARCHAR(100) NOT NULL,
    UNIQUE KEY (PlatformID, AsamaNo),
    FOREIGN KEY (PlatformID) REFERENCES platform_list(PlatformID) ON DELETE CASCADE
);

-- Test yöntemi
CREATE TABLE IF NOT EXISTS test_yontemi (
    TestYontemiID INT AUTO_INCREMENT PRIMARY KEY,
    YontemAdi VARCHAR(100) NOT NULL
);

-- Ana ister node tablosu
CREATE TABLE IF NOT EXISTS ister_node (
    NodeID INT AUTO_INCREMENT PRIMARY KEY,
    PlatformID INT NOT NULL,
    SeviyeID INT NOT NULL,
    ParentID INT NULL,
    HavuzNodeID INT NULL,
    KonfigID INT NULL,
    NodeNumarasi VARCHAR(100) NULL,
    GignBaslik TINYINT(1) DEFAULT 0,
    UstBaslikID INT NULL,
    IsterTipi ENUM('B','G') DEFAULT 'G' COMMENT 'B=Baþlýk, G=Gereksinim',
    HavuzKodu VARCHAR(20) NULL COMMENT 'b1,b2,g1,g2 gibi havuz bazlý kod',
    Icerik LONGTEXT,
    TestYontemiID INT NULL,
    DegistirildiMi TINYINT(1) DEFAULT 0,
    OlusturanID INT,
    OlusturmaTarihi TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    SiraNo INT DEFAULT 0,
    IlgiliAsamaID INT NULL,
    FOREIGN KEY (PlatformID) REFERENCES platform_list(PlatformID) ON DELETE CASCADE,
    FOREIGN KEY (SeviyeID) REFERENCES seviye_tanim(SeviyeID),
    FOREIGN KEY (ParentID) REFERENCES ister_node(NodeID) ON DELETE CASCADE,
    FOREIGN KEY (KonfigID) REFERENCES konfig_list(KonfigID),
    FOREIGN KEY (TestYontemiID) REFERENCES test_yontemi(TestYontemiID),
    FOREIGN KEY (OlusturanID) REFERENCES kullanici(KullaniciID)
);

-- Ýsterler arasý baðlantýlar
CREATE TABLE IF NOT EXISTS ister_baglanti (
    BaglantiID INT AUTO_INCREMENT PRIMARY KEY,
    KaynakNodeID INT NOT NULL,
    HedefNodeID INT NOT NULL,
    UNIQUE KEY (KaynakNodeID, HedefNodeID),
    FOREIGN KEY (KaynakNodeID) REFERENCES ister_node(NodeID) ON DELETE CASCADE,
    FOREIGN KEY (HedefNodeID) REFERENCES ister_node(NodeID) ON DELETE CASCADE
);

-- Test sonuçlarý
CREATE TABLE IF NOT EXISTS test_sonuc (
    TestSonucID INT AUTO_INCREMENT PRIMARY KEY,
    NodeID INT NOT NULL,
    TestAsamaID INT NOT NULL,
    Sonuc ENUM('Basarili','Hatali') NOT NULL,
    Aciklama LONGTEXT,
    KullaniciID INT,
    Tarih TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY (NodeID, TestAsamaID),
    FOREIGN KEY (NodeID) REFERENCES ister_node(NodeID) ON DELETE CASCADE,
    FOREIGN KEY (TestAsamaID) REFERENCES test_asama(TestAsamaID) ON DELETE CASCADE,
    FOREIGN KEY (KullaniciID) REFERENCES kullanici(KullaniciID)
);

-- TA dokümanlarý ve verileri
CREATE TABLE IF NOT EXISTS ta_dokuman (
    TaID INT AUTO_INCREMENT PRIMARY KEY,
    PlatformID INT NOT NULL,
    SiraNo INT NOT NULL,
    HavuzTaID INT NULL,
    SolSistemAdi VARCHAR(200),
    SagSistemAdi VARCHAR(200),
    FOREIGN KEY (PlatformID) REFERENCES platform_list(PlatformID) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS ta_veri (
    TaVeriID INT AUTO_INCREMENT PRIMARY KEY,
    TaID INT NOT NULL,
    Sistem ENUM('sol','sag') NOT NULL,
    Yon ENUM('aldigi','verdigi') NOT NULL,
    Icerik VARCHAR(500),
    Sira INT DEFAULT 0,
    FOREIGN KEY (TaID) REFERENCES ta_dokuman(TaID) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS ta_sgo_baglanti (
    BaglantiID INT AUTO_INCREMENT PRIMARY KEY,
    TaID INT NOT NULL,
    NodeID INT NOT NULL,
    UNIQUE KEY (TaID, NodeID),
    FOREIGN KEY (TaID) REFERENCES ta_dokuman(TaID) ON DELETE CASCADE,
    FOREIGN KEY (NodeID) REFERENCES ister_node(NodeID) ON DELETE CASCADE
);

-- Deðiþiklik logu
CREATE TABLE IF NOT EXISTS degisiklik_log (
    LogID INT AUTO_INCREMENT PRIMARY KEY,
    TabloAdi VARCHAR(100),
    KayitID INT,
    AlanAdi VARCHAR(100),
    EskiDeger LONGTEXT,
    YeniDeger LONGTEXT,
    KullaniciID INT,
    KullaniciAdi VARCHAR(100),
    DegisimTarihi TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Baþlangýç verileri
INSERT IGNORE INTO kullanici (KullaniciAdi, Sifre, AdSoyad, AktifMi) 
VALUES ('admin', 'admin123', 'Sistem Yöneticisi', 1);

INSERT IGNORE INTO platform_list (PlatformAdi, HavuzMu) VALUES ('HAVUZ', 1);

INSERT IGNORE INTO test_yontemi (YontemAdi) VALUES 
('Fonksiyonel Test'), ('Belge Sunumu'), ('Performans Testi'), ('Güvenlik Testi'), ('Entegrasyon Testi');

-- Ýster tablo
CREATE TABLE IF NOT EXISTS ister_tablo (
    TabloID INT AUTO_INCREMENT PRIMARY KEY,
    NodeID INT NOT NULL,
    TabloAdi VARCHAR(200),
    SutunBasliklari LONGTEXT,
    Satirlar LONGTEXT,
    OlusturanID INT,
    OlusturmaTarihi TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (NodeID) REFERENCES ister_node(NodeID) ON DELETE CASCADE
);

-- Firma görüþleri
CREATE TABLE IF NOT EXISTS firma_gorusu (
    GorusID INT AUTO_INCREMENT PRIMARY KEY,
    NodeID INT NOT NULL,
    PlatformID INT NOT NULL,
    FirmaAdi VARCHAR(200) NOT NULL,
    GorusIcerik LONGTEXT,
    GorusOzet VARCHAR(500),
    GorusKategori VARCHAR(200),
    OlusturanID INT,
    OlusturmaTarihi TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (NodeID) REFERENCES ister_node(NodeID) ON DELETE CASCADE,
    FOREIGN KEY (PlatformID) REFERENCES platform_list(PlatformID) ON DELETE CASCADE
);

-- Firma görüþü yanýtlarý
CREATE TABLE IF NOT EXISTS firma_gorusu_yanit (
    YanitID INT AUTO_INCREMENT PRIMARY KEY,
    GorusID INT NOT NULL,
    YanitIcerik LONGTEXT,
    YazanID INT,
    OlusturmaTarihi TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (GorusID) REFERENCES firma_gorusu(GorusID) ON DELETE CASCADE
);

-- Ýster onay
CREATE TABLE IF NOT EXISTS ister_onay (
    OnayID INT AUTO_INCREMENT PRIMARY KEY,
    NodeID INT NOT NULL,
    PlatformID INT NOT NULL,
    OnayDurumu TINYINT(1) DEFAULT 0,
    OnaylayanID INT,
    OnayTarihi TIMESTAMP NULL,
    UNIQUE KEY uq_node_plat (NodeID, PlatformID),
    FOREIGN KEY (NodeID) REFERENCES ister_node(NodeID) ON DELETE CASCADE,
    FOREIGN KEY (PlatformID) REFERENCES platform_list(PlatformID) ON DELETE CASCADE
);

-- Ýster bullet tablosu
CREATE TABLE IF NOT EXISTS ister_bullet (
    BulletID INT AUTO_INCREMENT PRIMARY KEY,
    NodeID INT NOT NULL,
    SiraNo INT DEFAULT 0,
    Icerik LONGTEXT NOT NULL,
    OlusturanID INT,
    OlusturmaTarihi TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (NodeID) REFERENCES ister_node(NodeID) ON DELETE CASCADE
);

-- Ýster node tablosuna yeni alanlar (sýra ve ilgili aþama)
ALTER TABLE ister_node ADD COLUMN SiraNo INT DEFAULT 0;
ALTER TABLE ister_node ADD COLUMN IlgiliAsamaID INT NULL;

-- Duplicate test yöntemi kayýtlarýný temizle
DELETE t1 FROM test_yontemi t1
INNER JOIN test_yontemi t2
WHERE t1.TestYontemiID > t2.TestYontemiID AND t1.YontemAdi = t2.YontemAdi;

-- Kullanýlmayan duplicate test yöntemlerini sil
DELETE FROM test_yontemi 
WHERE TestYontemiID NOT IN (
    SELECT DISTINCT TestYontemiID FROM ister_node WHERE TestYontemiID IS NOT NULL
)
AND YontemAdi IN (
    SELECT YontemAdi FROM (
        SELECT YontemAdi FROM test_yontemi
        GROUP BY YontemAdi HAVING COUNT(*) > 1
    ) AS duplar
);

-- Veritabaný kurulumu tamamlandý