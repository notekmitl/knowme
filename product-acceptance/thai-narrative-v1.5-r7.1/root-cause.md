# Root cause

R7 finalizer ถูกเรียกด้วย Windows PowerShell 5 จากสคริปต์ UTF-8 without BOM ที่มี literal ภาษาไทย ตัว runtime จึงอ่าน source ผ่าน default Windows code page และทำให้ข้อความไทยถูก encode/decode ซ้ำเป็น mojibake

ใน identity block เดิม path ถูกครอบด้วย Markdown backtick ภายใน expandable here-string ทำให้ `` `t `` ต้นคำ `tool/` ถูกตีความเป็น tab อีกชั้นหนึ่ง ตัวตรวจเดิมตรวจ C0 ไม่ครบ ไม่ตรวจ C1 U+0080–U+009F และบันทึกผลก่อน final generated block ถูกตรวจจริง จึงเกิด false PASS

R7.1 ใช้ finalizer แบบ ASCII-safe ถอด canonical UTF-8 จาก base64 ด้วย strict decoder เขียนทุก text file ด้วย UTF-8 without BOM หลัง insert block แล้วจึง validate staging และ validate ซ้ำหลังแตก ZIP
