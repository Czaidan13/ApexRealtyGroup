# Apex Realty Group

A full Salesforce CRM implementation built for a fictional real estate agency — covering data modeling, automation, custom UI components, and enterprise security, all built from the ground up as a developer portfolio project.

## 🎥 Demo

[Loom walkthrough coming soon]

## 📸 Screenshots

[Screenshots coming soon]

## Overview

Apex Realty Group is a Salesforce CRM designed for a real estate agency managing property listings, showings, offers, agents, and commissions. I built this project to demonstrate end-to-end Salesforce development skills — not just isolated features, but a system where automation, custom UI, and security all work together the way they would in a real org.

Real estate was a deliberate choice. The business processes — listings moving through a sales pipeline, agents earning commissions, offers being submitted and accepted — map naturally onto Salesforce's standard tools: master-detail relationships, roll-up summaries, record types, and approval-style status transitions. It gave me a realistic environment to apply Apex, Flow, LWC, and the security model the way they'd actually be used on the job.

## ✨ Features

**Data Model**

- 5 custom objects (Property, Showing, Offer, Agent, Commission) with relationships, validation rules, and roll-up summaries
- 3 record types on Property (Residential, Commercial, Rental)

**Automation**

- 3 Apex triggers built with the trigger handler pattern, each with full test coverage
- Offer acceptance cascades automatically — updates the Property status, stamps the sale price, and withdraws competing offers
- Property sold → Commission record auto-generated for the assigned agent
- Scheduled Flow for daily showing follow-ups
- Screen Flow wizard for creating new listings
- Screen Flow for reviewing and accepting offers directly from a Property record

**Lightning Web Components**

- **Property Search** — dynamic SOQL search with live picklist values, available right on the home page
- **Agent Performance Dashboard** — real-time stats (active listings, total offers, commission YTD) calculated via Apex
- **Offer Comparison Tool** — side-by-side offer review with single-click accept, wired into the existing automation

**Security & Access**

- Custom role hierarchy (Executive → Regional Manager → Agent)
- 3 custom profiles with tailored object permissions
- Permission set for commission visibility
- Org-wide defaults and sharing rules for proper record-level access

**Reporting**

- 6 custom reports covering listings, offers, commissions, and showings
- Executive Dashboard with 6 components (bar, line, funnel, and donut charts)

## 🛠️ Tech Stack

- Apex (triggers, handler classes, controllers, test classes)
- Lightning Web Components (JavaScript, HTML, wire adapters)
- Flow Builder (scheduled and screen flows)
- SOQL (including dynamic SOQL and aggregate queries)
- Salesforce security model (roles, profiles, permission sets, sharing rules)
- Salesforce CLI + VS Code for local development

## 🏗️ Architecture Highlights

All triggers follow a thin trigger → handler class pattern, keeping logic testable and out of the trigger itself. The Offer and Property triggers work together to create a real business cascade: accepting an offer doesn't just update one record — it updates the property status, records the final sale price, withdraws other offers, and (when a property sells) generates a commission record for the agent automatically.

On the UI side, the three custom LWCs aren't standalone demos — they're integrated into the actual user flow. The Property Search component lives on the home page where agents would start their day, the Agent Dashboard sits on the Agent record page, and the Offer Comparison tool is where the trigger automation actually gets triggered from the UI.

## 📚 What I Learned

This project pushed me to think about Apex and automation the way a real org would need it — bulkified triggers, governor-limit-aware queries, and a handler pattern that keeps things maintainable. On the LWC side, working with `@wire`, imperative Apex calls, and reactive picklists gave me a much better feel for how the frontend and backend connect in Salesforce. It also reinforced how much the "admin" side — security, sharing, reports — shapes whether an org actually works for the people using it.

## 🚀 Future Enhancements

- **Weather Integration (Phase 5 — in progress)**: Apex callouts to a weather API via Named Credentials, with async Apex (Queueable/Batch) to enrich property listings with local weather data
- Additional automation around showing scheduling conflicts
- Expanded reporting with historical trend analysis

---

_All data and company information in this project is fictional._
