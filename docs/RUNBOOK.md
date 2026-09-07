# Pro Grocery - Incident Response Runbook

## Overview

This runbook provides step-by-step procedures for responding to incidents in the Pro Grocery production environment.

## Severity Levels

### P0 - Critical
- Complete system outage
- Data breach or security incident
- Payment processing failure
- Data loss or corruption

### P1 - High
- Partial system outage
- Performance degradation affecting users
- Authentication issues
- Critical feature unavailable

### P2 - Medium
- Non-critical feature unavailable
- Minor performance issues
- UI/UX bugs
- Documentation gaps

### P3 - Low
- Cosmetic issues
- Minor bugs
- Enhancement requests

## Incident Response流程

### 1. Detection & Alerting

**Monitoring Tools:**
- Sentry: Error tracking and performance monitoring
- Google Cloud Monitoring: Uptime checks and alerts
- Firebase Console: Database and authentication metrics
- Vercel Analytics: Admin dashboard performance

**Alert Channels:**
- Slack: #incidents channel
- Email: ops@progrocery.com
- PagerDuty: On-call rotation

### 2. Initial Assessment

**Questions to Answer:**
1. What is the impact? (Users affected, revenue impact)
2. When did it start? (Timeline of events)
3. What changed? (Recent deployments, configuration changes)
4. Is it ongoing? (Current status)

**Immediate Actions:**
- [ ] Acknowledge alert in monitoring system
- [ ] Join #incidents Slack channel
- [ ] Start incident timeline document
- [ ] Notify stakeholders if P0/P1

### 3. Investigation

**Debugging Steps:**

#### For Flutter App Issues:
```bash
# Check Sentry for errors
# Review recent deployments
# Check Firebase Console for auth/database issues
# Review app logs
flutter logs
```

#### For Admin Dashboard Issues:
```bash
# Check Vercel deployment status
# Review server logs
# Check database connectivity
# Verify environment variables
```

#### For API/Backend Issues:
```bash
# Check Cloud Functions logs
firebase functions:log
# Review Firestore rules
firebase deploy --only firestore:rules --dry-run
# Check rate limiting
gcloud logging read "resource.type=cloud_function" --limit=100
```

### 4. Containment

**Immediate Containment:**
- [ ] Disable affected feature via feature flag
- [ ] Scale up resources if performance issue
- [ ] Block malicious IPs if security issue
- [ ] Revert to previous version if deployment issue

**Rollback Procedures:**

#### Mobile App Rollback:
```bash
# Android (Google Play Console)
1. Go to Release → Production
2. Click "Rollback"
3. Select previous version
4. Confirm rollback

# iOS (App Store Connect)
1. Go to Version History
2. Click "Rollback"
3. Submit for expedited review
```

#### Web App Rollback:
```bash
# Firebase Hosting
firebase hosting:channel:rollback

# Or deploy previous version
git checkout v0.9.0
firebase deploy --only hosting
```

#### Admin Dashboard Rollback:
```bash
# Vercel
vercel rollback

# Or deploy previous version
git checkout v0.9.0
cd admin && npm run build
vercel --prod
```

#### Database Rollback:
```bash
# Revert Firestore rules
git checkout HEAD~1 -- firestore.rules
firebase deploy --only firestore:rules

# Restore from backup (if needed)
gcloud firestore import gs://backup-bucket/20260722
```

### 5. Resolution

**Fix Implementation:**
- [ ] Create hotfix branch
- [ ] Implement fix
- [ ] Test fix in staging
- [ ] Deploy to production
- [ ] Verify fix is working

**Verification Steps:**
- [ ] Monitor error rates
- [ ] Check user feedback
- [ ] Verify business metrics
- [ ] Confirm no regression

### 6. Post-Incident

**Post-Mortem Process:**
1. **Timeline Review**
   - When did incident start?
   - When was it detected?
   - When was it resolved?
   - What was the total downtime?

2. **Root Cause Analysis**
   - What caused the incident?
   - Why wasn't it caught earlier?
   - What processes failed?

3. **Impact Assessment**
   - How many users affected?
   - What was the revenue impact?
   - Were there any data losses?

4. **Action Items**
   - What needs to be fixed?
   - What processes need improvement?
   - What monitoring is missing?

5. **Documentation**
   - Update this runbook
   - Create incident report
   - Share learnings with team

## Common Incident Procedures

### 1. Payment Processing Failure

**Symptoms:**
- Users unable to complete checkout
- M-Pesa callbacks failing
- Payment status not updating

**Immediate Actions:**
1. Check M-Pesa API status
2. Verify webhook endpoints
3. Check Firebase Functions logs
4. Review payment transaction logs

**Resolution:**
1. If M-Pesa API is down:
   - Display maintenance message
   - Enable offline mode for cart
   - Notify users of delay

2. If webhook is failing:
   - Check endpoint URL
   - Verify SSL certificate
   - Review firewall rules

3. If database issue:
   - Check Firestore connectivity
   - Review security rules
   - Verify write permissions

### 2. Authentication Issues

**Symptoms:**
- Users unable to login
- Login errors in Sentry
- Firebase Auth quota exceeded

**Immediate Actions:**
1. Check Firebase Auth status
2. Review auth-related errors
3. Verify API keys
4. Check rate limiting

**Resolution:**
1. If Firebase Auth is down:
   - Enable maintenance mode
   - Display login issues message
   - Notify users of delay

2. If rate limiting is triggered:
   - Review rate limit configuration
   - Adjust limits if needed
   - Check for abuse

3. If API key issue:
   - Verify environment variables
   - Check key rotation status
   - Update keys if compromised

### 3. Performance Degradation

**Symptoms:**
- Slow response times
- High error rates
- User complaints about slowness

**Immediate Actions:**
1. Check server metrics
2. Review database performance
3. Check CDN status
4. Verify resource allocation

**Resolution:**
1. If database is slow:
   - Check query performance
   - Add indexes if needed
   - Scale up resources

2. If server is slow:
   - Scale up instances
   - Check for memory leaks
   - Review code efficiency

3. If CDN is slow:
   - Check CDN provider status
   - Review cache settings
   - Optimize assets

### 4. Security Incident

**Symptoms:**
- Unauthorized access attempts
- Data breach indicators
- Suspicious activity logs

**Immediate Actions:**
1. Isolate affected systems
2. Preserve evidence
3. Notify security team
4. Begin investigation

**Resolution:**
1. If unauthorized access:
   - Revoke compromised credentials
   - Review access logs
   - Implement additional controls

2. If data breach:
   - Contain the breach
   - Assess scope
   - Notify affected users
   - Report to authorities if required

3. If suspicious activity:
   - Block malicious IPs
   - Review security rules
   - Update firewall rules

## Communication Templates

### Initial Alert
```
🚨 INCIDENT ALERT - P[0/1/2]

Summary: [Brief description]
Impact: [Users affected]
Status: Investigating
Timeline: [Start time]

Join #incidents for updates.
```

### Status Update
```
📊 INCIDENT UPDATE

Summary: [Brief description]
Status: [Investigating/Identified/Monitoring/Resolved]
Next update: [Time]

[Additional details]
```

### Resolution
```
✅ INCIDENT RESOLVED

Summary: [Brief description]
Duration: [Total time]
Impact: [Users affected]
Root cause: [Brief explanation]

Post-mortem scheduled for [date/time].
```

## Escalation Matrix

| Severity | Response Time | Escalation Path |
|----------|---------------|-----------------|
| P0 | 15 minutes | On-call → Team Lead → CTO |
| P1 | 30 minutes | On-call → Team Lead |
| P2 | 2 hours | On-call → Team Lead |
| P3 | 24 hours | On-call |

## On-Call Rotation

**Current On-Call:**
- Primary: [Name] ([Contact])
- Secondary: [Name] ([Contact])

**Schedule:**
- Week 1: [Name]
- Week 2: [Name]
- Week 3: [Name]
- Week 4: [Name]

## Tools & Resources

### Monitoring
- Sentry: https://sentry.io
- Google Cloud Console: https://console.cloud.google.com
- Firebase Console: https://console.firebase.google.com
- Vercel Dashboard: https://vercel.com

### Communication
- Slack: #incidents
- Email: ops@progrocery.com
- Phone: [Emergency contact]

### Documentation
- This runbook: docs/RUNBOOK.md
- Architecture docs: docs/
- API documentation: docs/api/

## Checklist

### Pre-Incident
- [ ] Monitoring configured
- [ ] Alerts configured
- [ ] On-call rotation set
- [ ] Runbook reviewed
- [ ] Team trained

### During Incident
- [ ] Alert acknowledged
- [ ] Timeline started
- [ ] Stakeholders notified
- [ ] Investigation begun
- [ ] Containment implemented

### Post-Incident
- [ ] Fix deployed
- [ ] Verification complete
- [ ] Post-mortem scheduled
- [ ] Documentation updated
- [ ] Lessons learned shared

---

**Last Updated:** 2026-07-22
**Version:** 1.0.0
**Owner:** DevOps Team
