# Incident Response Process for **nvm**

## Reporting a Vulnerability

We take the security of **nvm** very seriously. If you believe you’ve found a security vulnerability, please inform us responsibly through coordinated disclosure.

### How to Report

> **Do not** report security vulnerabilities through public GitHub issues, discussions, or social media.

Instead, please use one of these secure channels:

1. **GitHub Security Advisories**
    Use the **Report a vulnerability** button in the Security tab of the [nvm-sh/nvm repository](https://github.com/nvm-sh/nvm).

2. **Email**
    Follow the posted [Security Policy](https://github.com/nvm-sh/nvm/security/policy).

### What to Include

**Required Information:**
- Brief description of the vulnerability type
- Affected version(s) and components
- Steps to reproduce the issue
- Impact assessment (what an attacker could achieve)

**Helpful Additional Details:**
- Full paths of affected scripts or files
- Specific commit or branch where the issue exists
- Required configuration to reproduce
- Proof-of-concept code (if available)
- Suggested mitigation or fix

## Our Response Process

**Timeline Commitments:**
- **Initial acknowledgment**: Within 24 hours
- **Detailed response**: Within 3 business days
- **Status updates**: Every 7 days until resolved
- **Resolution target**: 90 days for most issues

**What We’ll Do:**
1. Acknowledge your report and assign a tracking ID
2. Assess the vulnerability and determine severity
3. Develop and test a fix
4. Coordinate disclosure timeline with you
5. Release a security update and publish an advisory and CVE
6. Credit you in our security advisory (if desired)

## Disclosure Policy

- **Coordinated disclosure**: We’ll work with you on timing
- **Typical timeline**: 90 days from report to public disclosure
- **Early disclosure**: If actively exploited
- **Delayed disclosure**: For complex issues

## Scope

**In Scope:**
- **nvm** project (all supported versions)
- Installation and update scripts (`install.sh`, `nvm.sh`)
- Official documentation and CI/CD integrations
- Dependencies with direct security implications

**Out of Scope:**
- Third-party forks or mirrors
- Platform-specific installs outside core scripts
- Social engineering or physical attacks
- Theoretical vulnerabilities without practical exploitation

## Security Measures

**Our Commitments:**
- Regular vulnerability scanning via GitHub Actions
- Automated security checks in CI/CD pipelines
- Secure scripting practices and mandatory code review
- Prompt patch releases for critical issues

**User Responsibilities:**
- Keep **nvm** updated
- Verify script downloads via PGP signatures
- Follow secure configuration guidelines for shell environments

## Legal Safe Harbor

**We will NOT:**
- Initiate legal action
- Contact law enforcement
- Suspend or terminate your access

**You must:**
- Only test against your own installations
- Not access, modify, or delete user data
- Not degrade service availability
- Not publicly disclose before coordinated disclosure
- Act in good faith

## Recognition

- **Advisory Credits**: Credit in GitHub Security Advisories (unless anonymous)

## Security Updates

**Stay Informed:**
- Subscribe to GitHub releases for **nvm**
- Enable GitHub Security Advisory notifications

**Update Process:**
- Patch releases (e.g., v0.40.3 → v0.40.4)
- Out-of-band releases for critical issues
- Advisories via GitHub Security Advisories

## Contact Information

- **Security reports**: Security tab of [nvm-sh/nvm](https://github.com/nvm-sh/nvm/security)
- **General inquiries**: GitHub Discussions or Issues

