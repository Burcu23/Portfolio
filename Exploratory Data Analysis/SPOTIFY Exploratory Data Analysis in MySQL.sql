create DATABASE spotify;
DROP TABLE IF EXISTS cleaned_dataset;
CREATE TABLE cleaned_dataset (
    artist VARCHAR(255),
    track VARCHAR(255),
    album VARCHAR(255),
    album_type VARCHAR(50),
    danceability FLOAT,
    energy FLOAT,
    loudness FLOAT,
    speechiness FLOAT,
    acousticness FLOAT,
    instrumentalness FLOAT,
    liveness FLOAT,
    valence FLOAT,
    tempo FLOAT,
    duration_min FLOAT,
    title VARCHAR(255),
    channel VARCHAR(255),
    views FLOAT,
    likes BIGINT,
    comments BIGINT,
    licensed BOOLEAN,
    official_video BOOLEAN,
    stream BIGINT,
    energy_liveness FLOAT,
    most_played_on VARCHAR(50)
);
use spotify



----------EDA----
 SELECT COUNT(*) FROM cleaned_dataset;

SELECT COUNT(DISTINCT artist ) FROM cleaned_dataset;

SELECT MAX( duration_min) FROM cleaned_dataset;

SELECT MIN( duration_min) FROM cleaned_dataset;

SELECT  channel from cleaned_dataset;

SELECT DISTINCT most_playedon FROM cleaned_dataset;
/*
----Data Anlaysis 
.
*/
--Question 1 --Retrieving the names of all tracks that have more than 1 billion streams

SELECT track from cleaned_dataset
WHERE stream > 1000000000;

--Question 2 --Listing all the albums along with their respective artists.
SELECT DISTINCT Album, Artist from cleaned_dataset
ORDER BY 1;

---Question 3--Getiing the total number of comments for tracks where licensed = True
SELECT  SUM(Comments) As total_comment FROM cleaned_dataset
WHERE Licensed = 'True';

--Question 4- Finding all tracks that belong to the album type single.  

SELECT * FROM cleaned_dataset
WHERE Album_type = 'single';

---Question 5-Counting the total number of tracks by each artist. 
SELECT Artist, COUNT(Track) AS count_of_track FROM cleaned_dataset
GROUP BY Artist
ORDER BY 2 desc;

---Question 6- Calculating the average danceabilitiy of tracks in each album
SELECT 
     Album,
     AVG(Danceability) AS avg_danceability 
FROM cleaned_dataset
GROUP BY 1;

-----Question 7- Finding the top 5 tracks with the highest energy values.

SELECT  Track, AVG(Energy) AS avg_energy  FROM cleaned_dataset
GROUP BY 1
ORDER BY 2 DESC
LIMIT 5;

---Question 8- List all tracks along with their views and likes where official_video = True

SELECT Track, SUM(Views) AS total_views, SUM(Likes) AS total_likes FROM cleaned_dataset
WHERE official_video = 'True'
GROUP BY 1
ORDER BY 2 DESC
LIMIT 5

----Question 9- For each album , calculate the total views of all associated tracks

SELECT  ALbum ,Track,SUM(Views ) AS total_views FROM cleaned_dataset
GROUP BY 1, 2
ORDER BY 3 DESC

--- Question 10- Retrieve the track names that have been streamed on Youtube more than Spotify

SELECT * FROM
(SELECT 
     Track, 
    COALESCE(SUM(CASE WHEN most_playedon = 'Youtube' THEN stream END ),0) AS streamed_on_youtube, 
	COALESCE(SUM(CASE WHEN most_playedon = 'Spotify' THEN stream END ),0) AS streamed_on_spotify
FROM cleaned_dataset
GROUP BY 1) AS sbq
WHERE   
streamed_on_youtube > streamed_on_spotify
 AND streamed_on_spotify <>0


---- Question 11 - Finding the top 3 most_viewed tracks for each artist using window functions
SELECT * FROM cleaned_dataset
WITH ranking_artist AS

(SELECT 
     Artist, 
     Track,
     SUM(Views) AS total_views, 
     DENSE_RANK() OVER(PARTITION BY Artist ORDER BY SUM(Views) DESC) as rank_view
FROM cleaned_dataset
GROUP BY 1, 2
ORDER BY 3 DESC)

SELECT * FROM ranking_artist
WHERE rank_view <= 3

-- Question 12-- Writing  a query to find tracks where the liveless score is above the average.
SELECT 
Artist,
Track, 
Liveness
FROM cleaned_dataset 
WHERE Liveness > (SELECT AVG(Liveness) AS avg_liveness FROM cleaned_dataset)


-- Question 13- Using a WITH clause to calculate the difference between the highest and lowest energy values for tracks in each album

WITH CTE AS
(SELECT 
	 Album,
	 MAX(Energy) AS highest_energy,
	 MIN(Energy) AS lowest_energy 
FROM cleaned_dataset
GROUP BY 1) 



SELECT 
      Album,
      highest_energy - lowest_energy  as energy_difference
FROM CTE
ORDER BY 2 DESC

----Question 14 Finding tracks where the energy-to-liveness ratio is greater than 1.2

select * from cleaned_dataset
WITH ratio AS
(SELECT
 Track ,
 ROUND((Energy/ Liveness)*100, 2) as eng_liv_ratio 
 from cleaned_dataset)
 
SELECT Track, eng_liv_ratio  From ratio
WHERE eng_liv_ratio < 1.2;

----Question 15 Calculating the cumulative sum of likes for tracks ordered by the number of views, using window functions.

SELECT
	 Track, 
     SUM(Likes) OVER(ORDER BY Views) AS cumulative_sum
     
FROM cleaned_dataset
     

       