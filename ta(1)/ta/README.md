# TA Recruitment System

A Java Servlet/JSP web application for BUPT International School's Teaching Assistant recruitment process.

## Technology Stack

- **Backend**: Java Servlet (javax.servlet 4.0)
- **Frontend**: JSP + HTML + CSS (no frameworks)
- **Data Storage**: JSON files (no database)
- **Build Tool**: Maven
- **Server**: Apache Tomcat 9+

## Project Structure

```
ta-recruitment-jsp/
├── pom.xml
└── src/main/
    ├── java/com/ta/recruitment/
    │   ├── listener/
    │   │   └── AppContextListener.java   # Initializes DataStore on startup
    │   ├── model/
    │   │   ├── User.java
    │   │   ├── Job.java
    │   │   ├── Application.java
    │   │   └── DataStore.java            # Singleton data layer (JSON files)
    │   └── servlet/
    │       ├── LoginServlet.java         # /login
    │       ├── LogoutServlet.java        # /logout
    │       ├── TAServlet.java            # /ta/*
    │       ├── MOServlet.java            # /mo/*
    │       └── AdminServlet.java         # /admin/*
    └── webapp/
        ├── index.jsp                     # Redirects to /login
        ├── login.jsp
        ├── css/style.css
        └── WEB-INF/
            ├── web.xml
            └── jsp/
                ├── ta/
                │   ├── dashboard.jsp
                │   ├── job-list.jsp
                │   ├── job-detail.jsp
                │   ├── apply-job.jsp
                │   ├── application-status.jsp
                │   └── profile.jsp
                ├── mo/
                │   ├── dashboard.jsp
                │   ├── applicant-list.jsp
                │   ├── course-detail.jsp
                │   └── post-job.jsp
                └── admin/
                    ├── dashboard.jsp
                    ├── job-management.jsp
                    ├── job-detail.jsp
                    ├── application-management.jsp
                    └── workload-management.jsp
```

## Prerequisites

- **Java JDK 8+** (JDK 11 or 17 recommended)
- **Apache Maven 3.6+**
- **Apache Tomcat 9.x** (or use the embedded Maven plugin)

## How to Run

### Option 1: Using Maven Tomcat Plugin (Easiest)

```bash
cd ta-recruitment-jsp
mvn tomcat7:run
```

Then open: http://localhost:8080/ta-recruitment

### Option 2: Build WAR and Deploy to Tomcat

```bash
cd ta-recruitment-jsp
mvn clean package
```

Copy `target/ta-recruitment.war` to your Tomcat's `webapps/` directory, then start Tomcat.

Open: http://localhost:8080/ta-recruitment

### Option 3: Deploy to Tomcat via IDE

Import the project as a Maven project in IntelliJ IDEA or Eclipse, configure a Tomcat server, and run.

## Default Login Credentials

| Role  | Email                | Password |
|-------|----------------------|----------|
| Admin | admin@bupt.edu.cn    | admin123 |
| MO    | mo1@bupt.edu.cn      | mo123    |
| MO    | mo2@bupt.edu.cn      | mo123    |
| TA    | ta1@bupt.edu.cn      | ta123    |
| TA    | ta2@bupt.edu.cn      | ta123    |
| TA    | ta3@bupt.edu.cn      | ta123    |

## URL Routes

| URL                          | Description                    | Role  |
|------------------------------|--------------------------------|-------|
| `/login`                     | Login page                     | All   |
| `/logout`                    | Logout                         | All   |
| `/ta/jobs`                   | Browse available jobs          | TA    |
| `/ta/jobs/{id}`              | Job detail                     | TA    |
| `/ta/apply/{id}`             | Apply for a job                | TA    |
| `/ta/applications`           | View application status        | TA    |
| `/ta/profile`                | Edit profile                   | TA    |
| `/mo/applicants`             | View applicants by job         | MO    |
| `/mo/applicants/{jobId}`     | Applicants for specific job    | MO    |
| `/mo/courses/{jobId}`        | Course/job detail with actions | MO    |
| `/mo/post-job`               | Post a new job                 | MO    |
| `/admin`                     | Admin dashboard (users)        | Admin |
| `/admin/jobs`                | Manage all jobs                | Admin |
| `/admin/jobs/{id}`           | Job detail with applicants     | Admin |
| `/admin/applications`        | Manage all applications        | Admin |
| `/admin/workload`            | TA workload overview           | Admin |

## Data Storage

All data is stored as JSON files in `WEB-INF/data/`:
- `users.json` — user accounts
- `jobs.json` — job postings
- `applications.json` — TA applications

The files are created automatically with seed data on first run.

## Features

### TA (Teaching Assistant)
- Browse available job postings
- View job details and requirements
- Apply for jobs with a cover letter
- Track application status (pending/accepted/rejected)
- Update personal profile

### MO (Module Organiser)
- Post new TA job openings
- View applicants for each job
- Accept or reject applicants
- View course/job details

### Admin
- View and manage all users
- Activate/deactivate user accounts
- View all job postings and close jobs
- Manage all applications
- Monitor TA workload distribution
