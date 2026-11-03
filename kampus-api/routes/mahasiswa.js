import express from "express";
import db from "../db.js";

const router = express.Router();

router.get("/", (req, res) => {
  db.query("SELECT * FROM mahasiswa", (err, results) => {
    if (err) return res.status(500).json({ error: err.message });
    res.json(results);
  });
});

// Latihan 2: GET /api/mahasiswa/search?q=kata
// Cari berdasarkan nama ATAU nim yang mengandung "kata".
// Nilai dikirim lewat tanda "?" (parameterized query), BUKAN digabung ke
// string SQL, sehingga aman dari SQL injection.
// Collation default MySQL (utf8mb4_general_ci) membuat LIKE tidak peka
// huruf besar/kecil.
router.get("/search", (req, res) => {
  const q = (req.query.q ?? "").toString().trim();
  if (q === "") {
    return db.query("SELECT * FROM mahasiswa", (err, results) => {
      if (err) return res.status(500).json({ error: err.message });
      res.json(results);
    });
  }

  // Karakter % dan _ adalah wildcard di LIKE; di-escape agar dicari apa adanya.
  const aman = q.replace(/[\\%_]/g, (c) => "\\" + c);
  const pola = `%${aman}%`;
  const sql = "SELECT * FROM mahasiswa WHERE nama LIKE ? OR nim LIKE ?";
  db.query(sql, [pola, pola], (err, results) => {
    if (err) return res.status(500).json({ error: err.message });
    res.json(results);
  });
});

router.post("/", (req, res) => {
  const { nim, nama, email, prodi, ipk } = req.body;
  const sql =
    "INSERT INTO mahasiswa (nim, nama, email, prodi, ipk) VALUES (?, ?, ?, ?, ?)";
  db.query(sql, [nim, nama, email, prodi, ipk], (err) => {
    if (err) {
      if (err.code === "ER_DUP_ENTRY") {
        return res
          .status(409)
          .json({ error: `NIM '${nim}' sudah terdaftar di database!` });
      }
      return res.status(500).json({ error: err.message });
    }
    res.json({ message: "Mahasiswa added successfully" });
  });
});

router.put("/:nim", (req, res) => {
  const { nim } = req.params;
  const { nama, email, prodi, ipk } = req.body;
  const sql = "UPDATE mahasiswa SET nama=?, email=?, prodi=?, ipk=? WHERE nim=?";
  db.query(sql, [nama, email, prodi, ipk, nim], (err, result) => {
    if (err) return res.status(500).json({ error: err.message });
    if (result.affectedRows === 0)
      return res.status(404).json({ message: "Mahasiswa not found" });
    res.json({ message: "Mahasiswa updated successfully" });
  });
});

router.delete("/:nim", (req, res) => {
  const { nim } = req.params;
  db.query("DELETE FROM mahasiswa WHERE nim = ?", [nim], (err, result) => {
    if (err) return res.status(500).json({ error: err.message });
    if (result.affectedRows === 0)
      return res.status(404).json({ message: "Mahasiswa not found" });
    res.json({ message: "Mahasiswa deleted successfully" });
  });
});

export default router;
