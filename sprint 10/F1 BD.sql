select * from constructors;

select * from circuits
order by circuitRef;

ALTER TABLE circuits
ADD COLUMN type ENUM('street', 'racetrack', 'hybrid') NOT NULL DEFAULT 'racetrack';

UPDATE circuits
SET type = 'street'
WHERE circuitId IN (24, 73, 6, 15, 80, 29, 59, 66, 37, 42, 43, 62, 49, 67, 65, 33, 55, 53, 12);

UPDATE circuits
SET type = 'hybrid'
WHERE circuitId IN (77, 1, 79, 7, 71, 13);

ALTER TABLE circuits
ADD COLUMN length_mt INT;

INSERT INTO circuits (circuitId, length_mt) VALUES
(29, 3780), (64, 7618), (58, 4828), (1, 5303), (69, 5513), (47, 4025), 
(61, 8300), (3, 5412), (73, 6003), (59, 4807), (38, 3916), (66, 7280), 
(68, 5137), (4, 4657), (51, 8055), (42, 3901), (37, 3782), (41, 3886), 
(31, 4023), (53, 5543), (27, 4360), (16, 4563), (25, 4259), (56, 3920), 
(10, 4574), (11, 4381), (21, 4909), (19, 4192), (18, 4309), (5, 5340), 
(36, 5031), (45, 3850), (77, 6175), (26, 4423), (30, 4529), (44, 6201), 
(54, 13626), (43, 3167), (78, 5380), (8, 4422), (15, 5065), (79, 5410), 
(6, 3330), (62, 5440), (49, 3790), (14, 5793), (48, 3957), (76, 5245), 
(50, 3720), (20, 5148), (28, 3703), (67, 6316), (65, 25578), (33, 3720), 
(75, 4653), (70, 4318), (55, 8372), (34, 5842), (60, 5300), (32, 4304), 
(63, 6020), (2, 5543), (17, 5451), (9, 5901), (71, 5848), (13, 7004), 
(22, 5807), (52, 4260), (12, 5473), (80, 6201), (7, 4361), (46, 5430), 
(24, 5281), (35, 5615), (39, 4307), (57, 3200), (40, 4262)
AS new_data (circuitId, length_mt)
ON DUPLICATE KEY UPDATE length_mt = new_data.length_mt;

select * from results;

SELECT 
    COUNT(DISTINCT r.raceId) AS total_races,
    COUNT(CASE WHEN q.position = 1 AND rs.positionOrder = 1 THEN 1 END) AS pole_wins
FROM races r
LEFT JOIN qualifying q ON r.raceId = q.raceId
LEFT JOIN results rs ON r.raceId = rs.raceId AND q.driverId = rs.driverId
WHERE r.circuitId = 80;

select * from drivers
where surname = "Hamilton";

SELECT 
    d.forename,
    d.surname,
    COUNT(*) AS pole_positions
FROM qualifying q
JOIN drivers d ON q.driverId = d.driverId
WHERE q.position = 1
GROUP BY q.driverId
ORDER BY pole_positions DESC;

SELECT 
    d.forename,
    d.surname,
    COUNT(*) AS wins_from_pole
FROM results r
JOIN qualifying q 
    ON r.raceId = q.raceId AND r.driverId = q.driverId
JOIN drivers d 
    ON r.driverId = d.driverId
WHERE r.positionOrder = 1
  AND q.position = 1
GROUP BY r.driverId
ORDER BY wins_from_pole DESC;

SELECT 
    d.forename,
    d.surname,
    COUNT(*) AS wins
FROM results r
JOIN drivers d 
    ON r.driverId = d.driverId
WHERE r.positionOrder = 1
GROUP BY r.driverId
ORDER BY wins DESC;

SELECT 
    d.forename,
    d.surname,
    COUNT(*) AS wins
FROM results r
JOIN races ra 
    ON r.raceId = ra.raceId
JOIN drivers d 
    ON r.driverId = d.driverId
WHERE r.positionOrder = 1
  AND ra.year >= 2003
GROUP BY r.driverId
ORDER BY wins DESC;

SELECT 
    d.forename,
    d.surname,
    COUNT(*) AS wins
FROM results r
JOIN races ra 
    ON r.raceId = ra.raceId
JOIN drivers d 
    ON r.driverId = d.driverId
WHERE r.positionOrder = 1
  AND ra.year >= 2003
  AND r.driverId IN (
      SELECT DISTINCT r2.driverId
      FROM results r2
      JOIN races ra2 ON r2.raceId = ra2.raceId
      WHERE r2.positionOrder = 1
        AND ra2.year >= (
            SELECT MAX(year) - 2 FROM races
        )
  )
GROUP BY r.driverId
ORDER BY wins DESC;

SELECT 
    d.forename,
    d.surname,
    COUNT(*) AS wins
FROM results r
JOIN races ra 
    ON r.raceId = ra.raceId
JOIN drivers d 
    ON r.driverId = d.driverId
WHERE r.positionOrder = 1
  AND ra.year >= 2003
  AND r.driverId IN (
      SELECT DISTINCT r2.driverId
      FROM results r2
      JOIN races ra2 ON r2.raceId = ra2.raceId
      WHERE ra2.year >= (
          SELECT MAX(year) - 2 FROM races
      )
  )
GROUP BY r.driverId
ORDER BY wins DESC;