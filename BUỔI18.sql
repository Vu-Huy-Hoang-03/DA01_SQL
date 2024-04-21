/* C1: BoxPlot */
-- B2: min = (Q1-1.5*IQR) - max = (Q3+1.5*IQR)
WITH boxplot AS
(
SELECT	(Q1 - 1.5 * IQR) as min,
		(Q3 + 1.5 * IQR) as max
FROM (
-- B1: Q1 - Q1 - IQR
select	percentile_cont(0.25) WITHIN GROUP (ORDER BY users) as Q1,
		percentile_cont(0.75) WITHIN GROUP (ORDER BY users) as Q3,
		percentile_cont(0.75) WITHIN GROUP (ORDER BY users) 
		- percentile_cont(0.25) WITHIN GROUP (ORDER BY users) as IQR
from user_data
	) as table_c1
)
-- B3: < min or > max
SELECT * FROM user_data
WHERE	users < (SELECT min FROM boxplot) 
		or users > (SELECT max FROM boxplot)


/* C1: Z-Score */
-- B1: AVG - STDDEV
WITH z_score AS
(
SELECT 	data_date, users,
		(SELECT AVG(users) as average FROM user_data),
		(SELECT STDDEV(users) as standard_deviation FROM user_data)
FROM user_data
)
-- B2: Z-Score
SELECT 	data_date, users,
		(users-average)/standard_deviation as z_scores
FROM z_score
WHERE ABS((users-average)/standard_deviation)>2
