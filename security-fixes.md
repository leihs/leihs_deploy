# Security Fixes — 2026-02-19

## 1. cryptography — Subgroup Attack on SECT Curves

| Field | Details |
|---|---|
| **Severity** | High (CVSS 8.2) |
| **CVE** | [CVE-2026-26007](https://nvd.nist.gov/vuln/detail/CVE-2026-26007) |
| **GHSA** | [GHSA-r6ph-v2qm-q3c2](https://github.com/advisories/GHSA-r6ph-v2qm-q3c2) |
| **Package** | cryptography (pip) |
| **File** | `ansible-requirements.txt` |
| **Vulnerable version** | 46.0.3 |
| **Fixed version** | 46.0.5 |

**Description:** The `cryptography` package lacked subgroup validation for SECT (binary elliptic) curves. An attacker could supply a malicious public key point from a small-order subgroup, enabling:

- **ECDH attacks** — leaking information about the victim's private key modulo the small subgroup order.
- **ECDSA attacks** — easy signature forgery on the small subgroup.

Affected functions: `public_key_from_numbers()`, `EllipticCurvePublicNumbers.public_key()`, `load_der_public_key()`, `load_pem_public_key()`.

SECT binary elliptic curve support has been deprecated and will be removed in the next release.

---

## 2. rack — Directory Traversal via Rack::Directory

| Field | Details |
|---|---|
| **Severity** | High (CVSS 7.5) |
| **CVE** | [CVE-2026-22860](https://nvd.nist.gov/vuln/detail/CVE-2026-22860) |
| **GHSA** | [GHSA-mxw3-3hh2-x2mh](https://github.com/rack/rack/security/advisories/GHSA-mxw3-3hh2-x2mh) |
| **Package** | rack (RubyGems) |
| **File** | `container-test/Gemfile.lock` |
| **Vulnerable version** | 3.2.4 |
| **Fixed version** | 3.2.5 |

**Description:** `Rack::Directory`'s path check used a string prefix match on the expanded path. A request like `/../root_example/` could escape the configured root if the target path starts with the root string (e.g. `/var/www/root` vs `/var/www/root_backup`), allowing directory listing and information disclosure outside the intended root.

**CWE:** CWE-22 (Path Traversal), CWE-548 (Directory Listing Exposure)

---

## 3. rack — Stored XSS in Rack::Directory via javascript: Filenames

| Field | Details |
|---|---|
| **Severity** | Moderate (CVSS 5.4) |
| **CVE** | [CVE-2026-25500](https://nvd.nist.gov/vuln/detail/CVE-2026-25500) |
| **GHSA** | [GHSA-whrj-4476-wvmp](https://github.com/rack/rack/security/advisories/GHSA-whrj-4476-wvmp) |
| **Package** | rack (RubyGems) |
| **File** | `container-test/Gemfile.lock` |
| **Vulnerable version** | 3.2.4 |
| **Fixed version** | 3.2.5 |

**Description:** `Rack::Directory` generates an HTML directory index where each file entry is rendered as a clickable `<a href>` link. If a file exists on disk whose basename begins with the `javascript:` scheme (e.g. `javascript:alert(1)`), the generated index includes an anchor whose `href` attribute is the raw filename. Clicking this entry executes arbitrary JavaScript in the context of the hosting application.

The fix prefixes generated anchors with a relative path indicator (`./filename`) to prevent `javascript:` URIs from being interpreted by browsers.

**CWE:** CWE-79 (Cross-site Scripting)

---

## Summary of Changes

| File | Change |
|---|---|
| `ansible-requirements.txt` | `cryptography` 46.0.3 → 46.0.5 |
| `container-test/Gemfile.lock` | `rack` 3.2.4 → 3.2.5 |
