-- IPL Match Analytics: queries grouped by the Unit 2 syllabus topics.
-- Each block starts with "-- Qn | topic | question".

-- Q1 | SELECT statement | List all franchises with home city and status
SELECT team_name, home_city, status FROM teams ORDER BY team_name;

-- Q2 | Restrict and sort | Matches won by 70 or more runs, biggest first
SELECT match_id, season, win_by_runs, player_of_match FROM matches WHERE win_by_runs >= 70 ORDER BY win_by_runs DESC;

-- Q3 | Restrict (IN, LIKE, BETWEEN) | 2016 to 2019 matches at venues whose name contains 'Stadium' in Mumbai, Chennai or Kolkata
SELECT m.season, COUNT(*) AS matches, v.venue_name FROM matches m JOIN venues v ON v.venue_id = m.venue_id WHERE m.season BETWEEN 2016 AND 2019 AND v.city IN ('Mumbai','Chennai','Kolkata') AND v.venue_name LIKE '%Stadium%' GROUP BY m.season, v.venue_name ORDER BY m.season, matches DESC;

-- Q4 | Single-row functions | Player-of-the-match names in upper case with their length and initials
SELECT DISTINCT player_of_match AS name, UPPER(player_of_match) AS upper_name, LENGTH(player_of_match) AS name_length, SUBSTR(player_of_match,1,1) AS first_letter FROM matches WHERE player_of_match LIKE 'V%' ORDER BY name LIMIT 8;

-- Q5 | Conditional expression (CASE) | Classify the 2019 winning margins
SELECT match_id, win_by_runs, win_by_wickets, CASE WHEN win_by_runs >= 50 THEN 'Dominant (50+ runs)' WHEN win_by_runs > 0 THEN 'Close (runs)' WHEN win_by_wickets >= 7 THEN 'Dominant (7+ wkts)' WHEN win_by_wickets > 0 THEN 'Close (wickets)' ELSE 'No margin' END AS margin_type FROM matches WHERE season = 2019 ORDER BY match_date LIMIT 8;

-- Q6 | Group functions | Overall dataset summary
SELECT COUNT(*) AS matches, COUNT(winner_id) AS with_result, COUNT(DISTINCT season) AS seasons, SUM(dl_applied) AS dl_matches, MAX(win_by_runs) AS biggest_run_win, ROUND(AVG(CASE WHEN win_by_runs > 0 THEN win_by_runs END),1) AS avg_run_margin FROM matches;

-- Q7 | GROUP BY and HAVING | Seasons with more than 70 matches
SELECT season, COUNT(*) AS matches FROM matches GROUP BY season HAVING COUNT(*) > 70 ORDER BY season;

-- Q8 | Joins | Titles won (winner of the Final), by franchise
SELECT t.team_name, COUNT(*) AS titles FROM matches m JOIN teams t ON t.team_id = m.winner_id WHERE m.stage = 'Final' GROUP BY t.team_id ORDER BY titles DESC, t.team_name;

-- Q9 | Joins + GROUP BY | Matches won and win count per franchise
SELECT t.team_name, COUNT(*) AS wins FROM matches m JOIN teams t ON t.team_id = m.winner_id GROUP BY t.team_id ORDER BY wins DESC;

-- Q10 | Subquery + UNION ALL | Win percentage = wins / matches played (matches with a result)
SELECT t.team_name, p.played, COALESCE(w.wins,0) AS wins, ROUND(100.0*COALESCE(w.wins,0)/p.played,1) AS win_pct FROM teams t JOIN (SELECT team_id, COUNT(*) AS played FROM (SELECT team1_id AS team_id FROM matches WHERE winner_id IS NOT NULL UNION ALL SELECT team2_id FROM matches WHERE winner_id IS NOT NULL) GROUP BY team_id) p ON p.team_id = t.team_id LEFT JOIN (SELECT winner_id, COUNT(*) AS wins FROM matches GROUP BY winner_id) w ON w.winner_id = t.team_id WHERE p.played >= 50 ORDER BY win_pct DESC;

-- Q11 | Toss analysis | How often did the toss winner also win the match?
SELECT COUNT(*) AS matches_with_result, SUM(CASE WHEN toss_winner_id = winner_id THEN 1 ELSE 0 END) AS toss_winner_won, ROUND(100.0*SUM(CASE WHEN toss_winner_id = winner_id THEN 1 ELSE 0 END)/COUNT(*),1) AS pct FROM matches WHERE winner_id IS NOT NULL;

-- Q12 | Trend | Share of toss winners who chose to field, by season
SELECT season, COUNT(*) AS matches, SUM(CASE WHEN toss_decision = 'field' THEN 1 ELSE 0 END) AS chose_field, ROUND(100.0*SUM(CASE WHEN toss_decision = 'field' THEN 1 ELSE 0 END)/COUNT(*),1) AS field_pct FROM matches GROUP BY season ORDER BY season;

-- Q13 | Chasing vs defending | Wins by batting first versus chasing, by season (a run win = batting first side won)
SELECT season, SUM(CASE WHEN win_by_runs > 0 THEN 1 ELSE 0 END) AS won_batting_first, SUM(CASE WHEN win_by_wickets > 0 THEN 1 ELSE 0 END) AS won_chasing, ROUND(100.0*SUM(CASE WHEN win_by_wickets > 0 THEN 1 ELSE 0 END)/(SUM(CASE WHEN win_by_runs > 0 THEN 1 ELSE 0 END)+SUM(CASE WHEN win_by_wickets > 0 THEN 1 ELSE 0 END)),1) AS chase_win_pct FROM matches GROUP BY season ORDER BY season;

-- Q14 | Aggregation | Top 8 players by player-of-the-match awards
SELECT player_of_match, COUNT(*) AS awards FROM matches WHERE player_of_match <> 'Not awarded' GROUP BY player_of_match ORDER BY awards DESC, player_of_match LIMIT 8;

-- Q15 | Outer join | Franchises that never won the title
SELECT t.team_name, t.status FROM teams t LEFT JOIN matches m ON m.winner_id = t.team_id AND m.stage = 'Final' WHERE m.match_id IS NULL ORDER BY t.team_name;

-- Q16 | Self join | Pairs of franchises that share a home city
SELECT a.team_name AS team_1, b.team_name AS team_2, a.home_city FROM teams a JOIN teams b ON a.home_city = b.home_city AND a.team_id < b.team_id ORDER BY a.home_city;

-- Q17 | Subquery | Matches with a run margin above the average run margin
SELECT COUNT(*) AS above_average_run_wins FROM matches WHERE win_by_runs > (SELECT AVG(win_by_runs) FROM matches WHERE win_by_runs > 0);

-- Q18 | Correlated subquery | Biggest win by runs in each season
SELECT m.season, m.win_by_runs, t.team_name AS winner FROM matches m JOIN teams t ON t.team_id = m.winner_id WHERE m.win_by_runs = (SELECT MAX(m2.win_by_runs) FROM matches m2 WHERE m2.season = m.season) ORDER BY m.season;

-- Q19 | Set operators (INTERSECT / EXCEPT) | Franchises that won matches in 2008 and also in 2019 / only in 2008
SELECT (SELECT GROUP_CONCAT(t.team_name, ', ') FROM teams t WHERE t.team_id IN (SELECT winner_id FROM matches WHERE season = 2008 INTERSECT SELECT winner_id FROM matches WHERE season = 2019)) AS won_in_both, (SELECT GROUP_CONCAT(t.team_name, ', ') FROM teams t WHERE t.team_id IN (SELECT winner_id FROM matches WHERE season = 2008 EXCEPT SELECT winner_id FROM matches WHERE season = 2019)) AS only_in_2008;

-- Q20 | Set operator (UNION) | Cities that hosted matches in 2008 or 2019 (count)
SELECT COUNT(*) AS cities FROM (SELECT v.city FROM matches m JOIN venues v ON v.venue_id = m.venue_id WHERE m.season = 2008 UNION SELECT v.city FROM matches m JOIN venues v ON v.venue_id = m.venue_id WHERE m.season = 2019);

-- Q21 | DML | Insert, update and delete a test match (rolled back so the data stays unchanged)
-- (run by the runner inside a transaction)

-- Q22 | View | Create a reusable team record view and query it
CREATE VIEW v_team_record AS SELECT t.team_name, COUNT(*) AS wins, SUM(CASE WHEN m.stage = 'Final' THEN 1 ELSE 0 END) AS titles FROM matches m JOIN teams t ON t.team_id = m.winner_id GROUP BY t.team_id;
SELECT team_name, wins, titles FROM v_team_record WHERE wins >= 80 ORDER BY wins DESC;

-- Q23 | Window function | Team with the most wins in each season
SELECT season, team_name, wins FROM (SELECT m.season, t.team_name, COUNT(*) AS wins, RANK() OVER (PARTITION BY m.season ORDER BY COUNT(*) DESC) AS rk FROM matches m JOIN teams t ON t.team_id = m.winner_id GROUP BY m.season, t.team_id) WHERE rk = 1 ORDER BY season;

-- Q24 | Outliers (IQR rule) | Run-win margins above Q3 + 1.5 x IQR
WITH r AS (SELECT win_by_runs AS x, ROW_NUMBER() OVER (ORDER BY win_by_runs) AS rn, COUNT(*) OVER () AS n FROM matches WHERE win_by_runs > 0), q AS (SELECT (SELECT x FROM r WHERE rn = CAST(0.25*(n-1) AS INT)+1) AS q1, (SELECT x FROM r WHERE rn = CAST(0.75*(n-1) AS INT)+1) AS q3 FROM r LIMIT 1) SELECT q1, q3, q3 + 1.5*(q3-q1) AS upper_fence, (SELECT COUNT(*) FROM matches WHERE win_by_runs > q3 + 1.5*(q3-q1)) AS outlier_matches FROM q;

-- Q25 | Home advantage | Win percentage when the match city equals the team's home city
SELECT COUNT(*) AS home_matches, SUM(CASE WHEN m.winner_id = t.team_id THEN 1 ELSE 0 END) AS home_wins, ROUND(100.0*SUM(CASE WHEN m.winner_id = t.team_id THEN 1 ELSE 0 END)/COUNT(*),1) AS home_win_pct FROM matches m JOIN venues v ON v.venue_id = m.venue_id JOIN teams t ON t.home_city = v.city AND t.team_id IN (m.team1_id, m.team2_id) WHERE m.winner_id IS NOT NULL;

-- Q26 | Venue analysis | Busiest venues and how often the chasing side won there
SELECT v.venue_name, v.city, COUNT(*) AS matches, ROUND(100.0*SUM(CASE WHEN m.win_by_wickets > 0 THEN 1 ELSE 0 END)/(SUM(CASE WHEN m.win_by_wickets > 0 THEN 1 ELSE 0 END)+SUM(CASE WHEN m.win_by_runs > 0 THEN 1 ELSE 0 END)),1) AS chase_win_pct FROM matches m JOIN venues v ON v.venue_id = m.venue_id GROUP BY v.venue_id HAVING COUNT(*) >= 40 ORDER BY matches DESC;

-- Not run in SQLite (Oracle / MySQL syllabus topics: user access and data dictionary):
--   GRANT SELECT ON matches TO analyst_user;       REVOKE SELECT ON matches FROM analyst_user;
--   SELECT table_name FROM user_tables;            SELECT column_name, data_type FROM user_tab_columns WHERE table_name = 'MATCHES';
