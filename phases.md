Phases

# Phase 1 — Schema & Concept Design

Define world state schema. Map ERPNext modules to game elements. Define event types and command types. Output is a specification document, no code.
# Phase 2 — Data Pipeline

ERPNext webhook setup. N8n event routing and normalization. WebSocket push server. N8n command-handling workflows. Tested with a dummy client.

# Phase 3 — Godot Client Foundation

Base map scene. Placeholder buildings per module. WebSocket ingestion. State diff engine. RTS camera controls.

# Phase 4 — Command Layer

Context menus on buildings and units. Command → N8n → confirmation loop. Pending vs confirmed visual states. Error handling.

# Phase 5 — Module Buildout

Each ERPNext module built out iteratively: visuals, data fields, commands, animations. CRM fishing dock, Accounting vault, Projects construction site, Inventory warehouse, etc.

# Phase 6 — Gamification & Polish

KPI resource counters. Business milestone achievements. Alert events for overdue documents. Sound. Commander summary dashboard.


# Phase 1

Phase 1 deliverable then is:
A specification document covering:

World state schema
ERPNext module → game element mapping
Event type definitions
Command type definitions
Connection/config model

## Phase 1 specification documents.


Modules:


Selling

Lead
Opportunity
Quotation
Sales Order
Delivery Note
Sales Invoice
Payment Entry (inbound)
Customers

Buying

Supplier
Purchase Order
Purchase Invoice
Payment Entry (outbound)

Accounting

Bank Transaction
Journal Entry
Account (Chart of Accounts)
Payment Entry

HR

Employee
Attendance
Leave Application
Timesheet
Timesheet Detail (Task)

Projects

Project
Task

Stock

Item
Stock Entry
Warehouse
Bin (stock levels per item per warehouse)

