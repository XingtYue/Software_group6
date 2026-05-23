# TA Recruitment System

A Java Servlet/JSP web application for BUPT International School's Teaching Assistant recruitment process. Supports three user roles — **Teaching Assistant (TA)**, **Module Organiser (MO)**, and **Administrator** — with AI-powered CV matching via the Google Gemini API.

---

## Technology Stack

| Layer | Technology |
|---|---|
| Backend | Java Servlet 4.0 (annotation-based, no XML config) |
| Frontend | JSP + HTML + CSS (vanilla, no JS frameworks) |
| Data Storage | JSON flat files (no database) |
| AI Integration | Google Gemini 2.5 Flash API |
| Document Parsing | Apache POI 4.1.2 (`.docx` extraction) |
| Build Tool | Apache Maven 3.6+ |
| Server | Apache Tomcat 9.x |
| Testing | JUnit 5 (Jupiter) |

---

## Project Structure

```
Software_group6/
├── pom.xml
└── src/main/
    ├── java/com/ta/recruitment/
    │   ├── listener/
    │   │   └── AppContextListener.java    # Initializes DataStore on startup
    │   ├── model/
    │   │   ├── User.java                  # User POJO (TA / MO / Admin)
    │   │   ├── Job.java                   # Job posting POJO
    │   │   ├── Application.java           # Application POJO + AI result fields
    │   │   └── DataStore.java             # Thread-safe singleton data layer
    │   ├── service/
    │   │   └── GeminiService.java         # Gemini 2.5 Flash AI analysis
    │   └── servlet/
    │       ├── AuthFilter.java            # Role-based access control filter
    │       ├── BaseServlet.java           # Shared CV serving & profile logic
    │       ├── LoginServlet.java          # /login
    │       ├── LogoutServlet.java         # /logout
    │       ├── RegisterServlet.java       # /register
    │       ├── TAServlet.java             # /ta/*
    │       ├── MOServlet.java             # /mo/*
    │       └── AdminServlet.java          # /admin/*
    └── webapp/
        ├── index.jsp                      # Redirects to /login
        ├── login.jsp
        ├── register.jsp
        ├── css/style.css
        ├── images/
        └── WEB-INF/
            ├── web.xml
            ├── data/
            │   ├── users.json
            │   ├── jobs.json
            │   └── applications.json
            ├── uploads/cv/                # Uploaded CV files (.pdf / .docx)
            └── jsp/
                ├── ta/
                │   ├── taheader.jsp
                │   ├── dashboard.jsp
                │   ├── job-list.jsp
                │   ├── job-detail.jsp
                │   ├── apply-job.jsp
                │   ├── application-status.jsp
                │   └── profile.jsp
                ├── mo/
                │   ├── moheader.jsp
                │   ├── dashboard.jsp
                │   ├── applicant-list.jsp
                │   ├── course-detail.jsp
                │   ├── post-job.jsp
                │   └── profile.jsp
                └── admin/
                    ├── adminheader.jsp
                    ├── dashboard.jsp
                    ├── profile.jsp
                    ├── job-management.jsp
                    ├── job-detail.jsp
                    ├── application-management.jsp
                    ├── workload-management.jsp
                    ├── edit-workload.jsp
                    ├── edit-user.jsp
                    └── manage-modules.jsp
```

---

## Prerequisites

- **Java JDK 11+** (JDK 17 recommended)
- **Apache Maven 3.6+**
- **Apache Tomcat 9.x** (or use the embedded Maven Tomcat plugin)
- **Gemini API Key** — required for AI CV matching (see below)

---

## Environment Setup

### Gemini API Key

The AI analysis feature requires a Google Gemini API key. Set it as an environment variable **before** starting Tomcat:

**Windows (PowerShell):**
```powershell
$env:GEMINI_API_KEY = "your-api-key-here"
```

**Linux / macOS:**
```bash
export GEMINI_API_KEY="your-api-key-here"
```

**IntelliJ IDEA:** Add `GEMINI_API_KEY=your-api-key-here` in the run configuration's Environment Variables field.

> Without this key the application runs normally; only the AI analysis button will return an error.

---

## How to Run

### Option 1: Maven Tomcat Plugin (Easiest)

```bash
mvn tomcat7:run
```

Open: **http://localhost:8080/ta-recruitment**

### Option 2: Build WAR and Deploy

```bash
mvn clean package
```

Copy `target/ta-recruitment.war` to your Tomcat `webapps/` directory, start Tomcat, then open **http://localhost:8080/ta-recruitment**.

### Option 3: IDE (IntelliJ IDEA / Eclipse)

Import as a Maven project, configure a local Tomcat 9 server in the run configuration, and run. Remember to set the `GEMINI_API_KEY` environment variable in the run configuration.

---

## Default Login Credentials

| Role  | Email                     | Password  |
|-------|---------------------------|-----------|
| Admin | admin@bupt.edu.cn         | admin123  |
| MO    | mo1@bupt.edu.cn           | mo123     |
| MO    | mo2@bupt.edu.cn           | mo123     |
| TA    | ta1@bupt.edu.cn           | ta123     |
| TA    | ta2@bupt.edu.cn           | ta123     |
| TA    | ta3@bupt.edu.cn           | ta123     |

New accounts can be created via the **Register** page (`/register`).

---

## URL Routes

### Public

| URL | Description |
|---|---|
| `/login` | Login page |
| `/logout` | Logout and clear session |
| `/register` | Create a new account (TA or MO) |

### TA Routes (`/ta/*`)

| URL | Method | Description |
|---|---|---|
| `/ta/dashboard` | GET | TA home dashboard |
| `/ta/jobs` | GET | Browse all active jobs (supports `?q=` search) |
| `/ta/jobs/{jobId}` | GET | Job detail page |
| `/ta/apply/{jobId}` | GET | Application form |
| `/ta/apply/{jobId}` | POST | Submit application (with optional CV upload) |
| `/ta/applications` | GET | My applications with status & filter tabs |
| `/ta/analyze-application` | POST | Trigger AI analysis for an application (JSON) |
| `/ta/cv/{filename}` | GET | Download / view a CV file |
| `/ta/profile` | GET | Edit profile page |
| `/ta/profile` | POST | Save profile changes (with optional CV upload) |

### MO Routes (`/mo/*`)

| URL | Method | Description |
|---|---|---|
| `/mo/dashboard` | GET | MO home dashboard |
| `/mo/applicants` | GET | Applicant list grouped by course |
| `/mo/courses/{jobId}` | GET | Course detail with applicants |
| `/mo/courses/{jobId}/action` | POST | Accept or reject an applicant |
| `/mo/analyze-application` | POST | Trigger AI analysis for an applicant (JSON) |
| `/mo/post-job` | GET | New job posting form |
| `/mo/post-job` | POST | Save new job posting |
| `/mo/cv/{filename}` | GET | Download / view a CV file |
| `/mo/profile` | GET | Edit profile page |
| `/mo/profile` | POST | Save profile & request new modules |

### Admin Routes (`/admin/*`)

| URL | Method | Description |
|---|---|---|
| `/admin` | GET | User management dashboard |
| `/admin/users/toggle` | POST | Activate or deactivate a user |
| `/admin/edit-user/{userId}` | GET | Edit user details form |
| `/admin/edit-user` | POST | Save user edits |
| `/admin/jobs` | GET | All job postings |
| `/admin/jobs/toggle` | POST | Open or close a job |
| `/admin/jobs/{jobId}` | GET | Job detail with all applicants |
| `/admin/applications` | GET | All applications (filterable by status) |
| `/admin/applications/action` | POST | Accept, reject, or restore an application |
| `/admin/workload` | GET | TA workload overview |
| `/admin/workload/{taId}` | GET | TA workload detail & manual override form |
| `/admin/workload/save` | POST | Save manual workload adjustment |
| `/admin/modules` | GET | Module approval queue |
| `/admin/modules/approve` | POST | Approve a pending module request |
| `/admin/modules/reject` | POST | Reject a pending module request |

---

## Data Storage

All data persists as JSON files in `WEB-INF/data/`. The `DataStore` singleton loads these into memory on startup and writes them back on every mutation.

| File | Contents |
|---|---|
| `users.json` | All user accounts (admin / MO / TA) with role, status, workload, and module assignments |
| `jobs.json` | Job postings with course info, hours, duration, openings, and requirements |
| `applications.json` | TA applications including status and all AI analysis results |

Uploaded CV files are stored in `WEB-INF/uploads/cv/` and named `{userId}_cv_{timestamp}.pdf` or `.docx`.

---

## Features

### TA (Teaching Assistant)

- **Browse & search jobs** — filter by keyword across job title and department
- **Apply with CV** — upload a PDF or Word (.docx) CV and write a cover letter
- **Track applications** — view all applications with status filter tabs (All / Pending / Accepted / Rejected)
- **AI match score** — request Gemini-powered CV analysis per application; see score, matched skills, missing skills, reasoning, and (when competition is high) an alternative job recommendation
- **MO contact on acceptance** — accepted applications display the Module Organiser's name and email directly on the card
- **"Accepted Today!" badge** — pulsing highlight for same-day acceptances
- **Workload sidebar** — real-time total committed hours (hours/week × weeks) colour-coded by threshold
- **Edit profile** — update name, phone, department, and upload a new CV

### MO (Module Organiser)

- **Post jobs** — create new TA positions specifying course, position type, hours/week, duration (week numbers), openings count, and requirements
- **Review applicants** — view all applications per job/course, accept or reject candidates
- **AI CV analysis** — Gemini analyses each applicant's CV against the job requirements; gives a 0–100 match score, matched/missing skills, and a reasoning summary; workload penalty applies when the TA's total committed hours exceed 80 h (score deduction + Chinese-language warning in reasoning)
- **Re-analyse** — force a fresh AI analysis at any time; cached results shown with a "Cached" badge
- **Request modules** — submit requests to be assigned to additional course modules; pending until admin approval
- **Edit profile** — update contact details

### Admin

- **User management** — view all users, activate/deactivate accounts, edit user details (name, email, password, department, phone, role, status)
- **Job management** — view all job postings across all MOs, open or close individual jobs
- **Application management** — full overview of all applications; accept, reject, or restore any application regardless of role
- **Workload management** — overview table showing total committed hours for every TA (auto-calculated as Σ hours/week × weeks for accepted positions); drill down to individual TA detail; override with a manual value when needed
- **Module approval** — approve or reject MO requests to manage specific course modules; approved modules appear on the MO's post-job form

### Authentication & Security

- **Role-based access control** — `AuthFilter` enforces strict role–path matching; TAs, MOs, and admins each can only access their own section
- **Session management** — 30-minute session timeout configured in `web.xml`
- **Registration** — new users can self-register as TA or MO; MO accounts require admin activation before use
- **Direct JSP access blocked** — `web.xml` security constraint prevents direct URL access to `WEB-INF/`

### AI Integration (Google Gemini 2.5 Flash)

- CV text extracted from uploaded PDF or Word file; job requirements compiled from job fields
- Local pre-computation of conditions (workload overload, competition ratio) before prompt construction — no raw numbers sent to the model
- **MO side**: applies workload penalty (score deduction) when TA total hours > 80; no alternative job recommendation
- **TA side**: no workload penalty; shows alternative job recommendation when competition is high (applicants > openings × 2)
- Handles Gemini 2.5 Flash's "thinking" response structure (skips `"thought": true` parts to extract the actual JSON response)
- Results persisted in `applications.json`; "Cached" badge shown when returning stored results

---

## Architecture Notes

### DataStore (Singleton)

`DataStore` is initialised once by `AppContextListener` and stored in `ServletContext`. All servlets retrieve it via `getServletContext().getAttribute("dataStore")`. It holds three `ArrayList` collections in memory and serialises them back to JSON on every write. Key methods:

- `updateApplicationStatus(appId, status)` — updates status **and** automatically recalculates the affected TA's total workload
- `recalcAndSaveWorkload(taId)` — sums `hoursPerWeek × parseDurationWeekCount(duration)` for all accepted applications and persists to `users.json`
- `getWorkloadData()` — returns a sorted list of all TAs with their workload for the admin overview

### Workload Calculation

Duration is stored as a comma-separated list of week numbers (e.g. `"5,6,7,13,14,15"` = 6 weeks). Total workload = Σ (hoursPerWeek × weekCount) across all accepted applications. The value is stored on the `User` object so any component can read it without recalculating.

### GeminiService

Sends a structured prompt to `gemini-2.5-flash` via `java.net.http.HttpClient` with a 60-second timeout. Prompt sections:

1. CV text and job requirements
2. Scoring rubric (Matched Skills, Missing Skills, Reasoning, Score)
3. Conditional workload warning (MO side only, when hours > 80)
4. Conditional alternative-job instruction (TA side only, when competition is high)

Response is parsed from the `candidates[0].content.parts[]` array, skipping any `"thought": true` entries.
