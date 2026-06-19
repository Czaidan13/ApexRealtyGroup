# Apex Realty Group

A full Salesforce CRM implementation built for a fictional real estate agency — covering data modeling, automation, custom UI components, security, reporting, and external API integration, all built from the ground up as a developer portfolio project.

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

- **Property Search** — dynamic SOQL search with live picklist values, available on the app home page
- **Agent Performance Dashboard** — real-time stats (active listings, total offers, commission YTD) calculated via Apex aggregate queries
- **Offer Comparison Tool** — side-by-side offer review with single-row selection and single-click accept, wired into the existing trigger automation
- **Property Weather Widget** — displays daily forecast data (condition, low/high temperature range bar, humidity, wind, UV index) fetched from a live weather API

**Weather Integration**

- Named Credential + External Credential with Custom authentication protocol — API key never hardcoded or exposed in the codebase
- WeatherCalloutService handles HTTP callouts and JSON parsing from WeatherAPI.com
- WeatherQueueable fires asynchronously on Property creation to fetch initial weather data
- WeatherBatchApex refreshes weather data daily across all Active listings
- WeatherScheduler runs the batch automatically every morning at 8 AM
- Full test coverage with mock HTTP callouts via HttpCalloutMock

**Security & Access**

- Custom role hierarchy (Executive → Regional Manager → Agent)
- 3 custom profiles with tailored object permissions
- Permission set for commission visibility
- Org-wide defaults and sharing rules for proper record-level access

**Reporting**

- 6 custom reports covering listings, offers, commissions, and showings
- Executive Dashboard with 6 components (horizontal bar, line, funnel, and donut charts)

## 🛠️ Tech Stack

- Apex (triggers, handler classes, controllers, async Apex — Queueable, Batch, Scheduled)
- Lightning Web Components (JavaScript, HTML, wire adapters, schema imports)
- Flow Builder (scheduled and screen flows)
- SOQL (including dynamic SOQL and aggregate queries)
- REST API integration (WeatherAPI.com via Named Credentials and External Credentials)
- Salesforce security model (roles, profiles, permission sets, OWD, sharing rules)
- Salesforce CLI + VS Code for local development
- Git + GitHub for version control

## 🏗️ Architecture Highlights

All triggers follow a thin trigger → handler class pattern, keeping logic testable and out of the trigger itself. The Offer and Property triggers work together to create a real business cascade: accepting an offer doesn't just update one record — it updates the property status, records the final sale price, withdraws other offers, and when a property sells, generates a commission record for the agent automatically.

The weather integration follows a store-and-display pattern rather than making live API calls on page load. A Queueable job fetches weather data when a property is created, and a Scheduled Batch job refreshes all Active listings daily. The LWC reads from stored fields — keeping page loads fast and the org resilient to API downtime. Authentication is handled entirely through Named Credentials and External Credentials, keeping the API key out of code and out of version control entirely.

On the UI side, the four custom LWCs aren't standalone demos — they're integrated into the actual user flow. The Property Search component lives on the home page where agents start their day, the Agent Dashboard sits on the Agent record page, the Offer Comparison tool is where trigger automation gets initiated from the UI, and the Weather Widget enriches each property listing with live forecast data.

## 📚 What I Learned

Building the trigger automation taught me to think more carefully about how objects and records need to connect to each other. Watching an offer acceptance automatically cascade through the property status, sale price, and commission record made the value of well-designed automation click in a way that's hard to get from reading about it. That kind of flow between objects is what lets people actually work more efficiently in Salesforce — not just having the data, but having it move where it needs to go without anyone thinking about it.

LWC was by far the steepest learning curve of the project — significantly harder than the Apex side. Getting comfortable with how JavaScript, wire adapters, and schema imports all work together, and understanding how data actually flows from Salesforce into a component.

The weather integration was very satisfying to see come together. Setting up the Named Credential and External Credential authentication, building the async Apex architecture with Queueable and Batch jobs working in sync, and then seeing a clean organized widget displaying live forecast data on a property record made it all feel real. Realizing that all the backend pieces — the callout service, the scheduler, the batch — were properly working together was a good moment.

## 🚀 Future Enhancements

- **Multi-day forecast** — extend the weather widget to show a 3-day forecast using WeatherAPI's forecast endpoint
- **Showing weather** — surface forecast conditions on upcoming Showing records so agents and buyers can prepare
- **Additional automation** — showing scheduling conflict detection, automated follow-up sequences
- **Expanded reporting** — historical trend analysis, agent performance over time

---

_All data and company information in this project is fictional._
