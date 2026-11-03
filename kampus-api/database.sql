CREATE DATABASE IF NOT EXISTS pmo2024api;
USE pmo2024api;

CREATE TABLE IF NOT EXISTS mahasiswa (
  nim VARCHAR(20) NOT NULL PRIMARY KEY,
  nama VARCHAR(100) NOT NULL,
  email VARCHAR(100) NOT NULL,
  prodi VARCHAR(100) NOT NULL,
  ipk DECIMAL(3, 2) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

INSERT INTO mahasiswa (nim, nama, email, prodi, ipk) VALUES
('220101', 'Ahmad Dahlan (Server API)', 'ahmad@kampus.ac.id', 'Informatika', 3.85),
('220102', 'Siti Nurhaliza (Server API)', 'siti@kampus.ac.id', 'Sistem Informasi', 3.90)
ON DUPLICATE KEY UPDATE nama=VALUES(nama);
