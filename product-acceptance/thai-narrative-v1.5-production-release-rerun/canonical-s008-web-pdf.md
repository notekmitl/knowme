# Canonical, S008 and Web/PDF result

The fresh run completed 21 passing tests before ending with four exact-text failures. Fixed-point S008 unit assertions executed without a reported S008 failure, and the generated 300-profile audit reports canonical mismatch 0, Unknown fail-closed mismatch 0 and Web/PDF mismatch 0.

However, four mandatory exact accepted-text assertions failed on CRLF versus LF at offset 23. Therefore this release does not claim fresh frozen canonical 5/5, live canonical 5/5, full VM/real-Chrome parity, or Preview/Production Web/PDF parity. Real Chrome was not run after the blocking failure.

The accepted pre-release evidence remains unchanged: raw S008 differs by one ULP while canonical mismatch is 0. That accepted evidence is provenance only and is not presented as a fresh release pass.
