# Candidate Source Provenance Note

Date: 2026-10-25

The archived baseline and candidate physical-design evidence passed all
checks in evidence_archive_20261025/SHA256SUMS.txt.

The current candidate top-level source hash differs from the hash recorded
in fullchip_candidate/source_sha256.txt.

Recorded hash:
ec2ba73cafeb9604f9435f1511b7c9ae961a714fc9996fca7c827db5c556fd4c

Current hash:
c18c196139aa3bc5a51796554fcc7ab1ca44bdde5c05e2c251dd495984189d10

The original source version has not been recovered. Therefore, the archived
physical-design reports are preserved as historical evidence, but their
exact source provenance relative to the current candidate source is not
confirmed. The recorded hash has intentionally not been overwritten.

The standalone CSA isolation test was rerun and passed:
- Disabled product-bus bit transitions: baseline 1098, isolated 0.
- Enabled product-bus bit transitions: baseline 766, isolated 766.

Production RTL hashes remain unchanged from the previously verified values.
This note does not claim validated whole-chip power savings.
