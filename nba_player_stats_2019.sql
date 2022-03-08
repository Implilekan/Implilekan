-- *Analyzing the 2019-2020 nba season player stats from tables: boxscore, coaches, games, player_info and salaries*

SELECT bs.playerName, Wt, teamName, salary, 
SUM(FG), SUM(3P), SUM(FT), SUM(TRB), SUM(AST), SUM(STL), SUM(BLK), SUM(PTS), Colleges,
RANK() OVER(ORDER BY SUM(PTS) DESC) AS Rank_N
FROM (SELECT * FROM boxscore WHERE game_id BETWEEN 29108 AND 30165) AS bs
LEFT JOIN player_info AS pi
ON bs.playerName = pi.playerName
LEFT JOIN salaries AS sa
ON pi.playerName = sa.playerName
WHERE sa.seasonStartYear = 2019
GROUP BY playerName
ORDER BY SUM(PTS) DESC;


-- *Further analysis*

SELECT bs.playerName, teamName, ga.game_id, FG, 3P, FT, TRB, AST, STL, BLK, PTS, 
(CASE WHEN homeTeam = teamName THEN awayTeam
WHEN awayTeam = teamName THEN homeTeam END) AS opponent
FROM (SELECT * FROM boxscore WHERE game_id BETWEEN 29108 AND 30165) AS bs
LEFT JOIN player_info AS pi
ON bs.playerName = pi.playerName
LEFT JOIN salaries AS sa
ON pi.playerName = sa.playerName
JOIN games AS ga
ON bs.game_id = ga.game_id
WHERE sa.seasonStartYear = 2019
ORDER BY playerName, opponent, game_id;