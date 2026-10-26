IPL Match Analytics 2008-2019 - Data Analytics mini project (Excel + SQL + Tableau)

FILES
IPL_Analytics.xlsx   Excel workbook (Matches, Teams, Venues, Summary, Stats, README sheets; formulas + charts)
schema.sql           CREATE TABLE statements (teams, venues, matches)
queries.sql          26 SQL queries (+ Oracle-only topics as comments)
sql_results.txt      Output of all queries
data/                Clean CSVs. Use ipl_matches_flat.csv and ipl_team_matches.csv in Tableau
charts/              PNG charts used in the report
IPL_Analytics_Mini_Project_Report.docx / .pdf   Report (20 pages)

TO DO BEFORE SUBMITTING
1. Replace [Student Name], [UID], [Faculty Name], [Code] etc. in the report; add university logo.
2. Build the Tableau dashboard (Appendix B of the report) and paste screenshots in Section 3.3.
3. In Excel, add a real PivotTable on the Matches sheet (Insert > PivotTable; steps in the README sheet) and take a screenshot.
4. Confirm the dataset licence/source (Kaggle IPL matches; copy from GitHub srinathkr07/IPL-Data-Analysis).

Run SQL: sqlite3 or DB Browser for SQLite -> run schema.sql, import data/teams.csv, venues.csv, matches.csv, then queries.sql.
