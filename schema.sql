-- IPL Match Analytics (2008-2019): schema (DDL). Runs on SQLite; MySQL/Oracle notes are in comments.
DROP VIEW IF EXISTS v_team_record;
DROP TABLE IF EXISTS matches;
DROP TABLE IF EXISTS venues;
DROP TABLE IF EXISTS teams;
CREATE TABLE teams (
  team_id    TEXT PRIMARY KEY,
  team_name  TEXT NOT NULL UNIQUE,
  home_city  TEXT,
  status     TEXT CHECK (status IN ('Active','Defunct'))
);
CREATE TABLE venues (
  venue_id    TEXT PRIMARY KEY,
  venue_name  TEXT NOT NULL UNIQUE,
  city        TEXT
);
CREATE TABLE matches (
  match_id        INTEGER PRIMARY KEY,
  season          INTEGER NOT NULL,
  match_date      TEXT NOT NULL,               -- ISO date YYYY-MM-DD
  stage           TEXT,                        -- 'Final' marks the last match of a season
  team1_id        TEXT NOT NULL REFERENCES teams(team_id),
  team2_id        TEXT NOT NULL REFERENCES teams(team_id),
  toss_winner_id  TEXT NOT NULL REFERENCES teams(team_id),
  toss_decision   TEXT CHECK (toss_decision IN ('bat','field')),
  result          TEXT,                        -- normal / tie / no result
  dl_applied      INTEGER DEFAULT 0,           -- 1 = Duckworth-Lewis method used
  winner_id       TEXT REFERENCES teams(team_id),   -- NULL when there is no result
  win_by_runs     INTEGER DEFAULT 0,
  win_by_wickets  INTEGER DEFAULT 0,
  player_of_match TEXT,
  venue_id        TEXT NOT NULL REFERENCES venues(venue_id)
);
CREATE INDEX idx_matches_season ON matches(season);
