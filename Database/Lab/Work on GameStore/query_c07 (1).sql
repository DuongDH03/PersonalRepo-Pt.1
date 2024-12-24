-- 10 câu đầu: Đinh Huy Dương 20215020

-- 1. In ra những người dùng đã gắn bó hệ thống được 2 năm: 
-- C1
SELECT *
FROM users
WHERE (SELECT EXTRACT(YEAR FROM AGE(CURRENT_DATE, create_time))) >= 2;
-- C2
SELECT *
FROM users
WHERE create_time <= CURRENT_DATE - INTERVAL '2 years';

-- 2. In ra những người dùng mua được từ 10 game trở lên
--C1
SELECT *
FROM users
WHERE (
    SELECT COUNT(*)
    FROM purchase
    WHERE purchase.user_id = users.user_id
) > 10;
--C2
WITH purchase_counts AS (
    SELECT user_id, COUNT(*) as game_count
    FROM purchase
    GROUP BY user_id
    HAVING COUNT(*) > 10
)
SELECT users.*
FROM users
JOIN purchase_counts
ON users.user_id = purchase_counts.user_id;

--C3
SELECT users.*
FROM users
JOIN (
    SELECT user_id, COUNT(*) as game_count
    FROM purchase
    GROUP BY user_id
    HAVING COUNT(*) > 10
) purchase_counts
ON users.user_id = purchase_counts.user_id;

--3. In ra những người dùng mua nhiều 5 game trở lên thuộc thể loại "RPG".
--C1
SELECT u.*
FROM users u
JOIN purchase p ON u.user_id = p.user_id
JOIN belongs_to b ON p.game_id = b.game_id
JOIN genres g ON b.genre_id = g.genre_id
WHERE g.genre_name = 'RPG'
GROUP BY u.user_id
HAVING COUNT(*) > 5;
--C2
SELECT u.*
FROM users u
JOIN (
    SELECT p.user_id, COUNT(*) as purchase_count
    FROM purchase p
    JOIN belong_to b ON p.game_id = b.game_id
    JOIN genres g ON b.genre_id = g.genre_id
    WHERE g.genre_name = 'RPG'
    GROUP BY p.user_id
    HAVING COUNT(*) > 5
) purchase_counts
ON u.user_id = purchase_counts.user_id;

--4. Danh sách các người dùng đã mua game nhưng bị ban
-- C1
SELECT DISTINCT users.*
FROM users
JOIN purchase ON users.user_id = purchase.user_id
WHERE users.status = false;
--C2
SELECT *
FROM users
WHERE status = false
AND EXISTS (
    SELECT 1
    FROM purchase
    WHERE purchase.user_id = users.user_id
);

--5. Các game có rating trên 8.0 và doanh thu thấp hơn 10000
SELECT g.name, gr.rating, gre.revenue
FROM games g
JOIN game_rate gr ON g.game_id = gr.game_id
JOIN game_revenue gre ON g.game_id = gre.game_id
WHERE gr.rating > 8.0 AND gre.revenue < 10000;

--6. Game được nhiều người mua nhất vào tháng 3/2023
--C1
SELECT g.name, COUNT(*) as purchase_count
FROM games g
JOIN purchase p ON g.game_id = p.game_id
WHERE date_part('year', p.time) = 2023 AND date_part('month', p.time) = 3
GROUP BY g.game_id, g.name
ORDER BY purchase_count DESC;
--C2
SELECT g.name, purchase_counts.purchase_count
FROM games g
JOIN (
    SELECT game_id, COUNT(*) as purchase_count
    FROM purchase
    WHERE date_part('year', time) = 2023 AND date_part('month', time) = 3
    GROUP BY game_id
) purchase_counts
ON g.game_id = purchase_counts.game_id
ORDER BY purchase_counts.purchase_count DESC;

--7. Game thuộc thể loại "Sport" có doanh thu cao nhất tính đến nay
--C1
SELECT g.name, gre.revenue
FROM games g
JOIN belongs_to b ON g.game_id = b.game_id
JOIN genres ge ON b.genre_id = ge.genre_id
JOIN game_revenue gre ON g.game_id = gre.game_id
WHERE ge.genre_name = 'Sport'
ORDER BY gre.revenue DESC
LIMIT 1;
--C2
WITH max_sport_revenue AS (
    SELECT MAX(revenue) as max_revenue
    FROM game_revenue gr
    JOIN games ga ON gr.game_id = ga.game_id
    JOIN belongs_to be ON ga.game_id = be.game_id
    JOIN genres gen ON be.genre_id = gen.genre_id
    WHERE gen.genre_name = 'Sport'
)
SELECT g.name, gre.revenue
FROM games g
JOIN belongto b ON g.game_id = b.game_id
JOIN genres ge ON b.genre_id = ge.genre_id
JOIN game_revenue gre ON g.game_id = gre.game_id
JOIN max_sport_revenue msr ON gre.revenue = msr.max_revenue
WHERE ge.genre_name = 'Sport';

--8. Game được phân vào 3 thể loại trở lên
--C1
WITH genre_counts AS (
    SELECT game_id, COUNT(*) as genre_count
    FROM belongs_to
    GROUP BY game_id
)
SELECT g.name
FROM games g
JOIN genre_counts b ON g.game_id = b.game_id
WHERE b.genre_count > 3;
--C2
SELECT g.name
FROM games g
JOIN belongs_to b ON g.game_id = b.game_id
GROUP BY g.game_id, g.name
HAVING COUNT(DISTINCT b.genre_id) > 3;

--9. Game được ưa thích nhất thuộc thể loại "Action" (không tính theo doanh thu mà tính theo lượt mua và wishlist)
--C1
WITH action_games AS (
    SELECT g.game_id, g.name
    FROM games g
    JOIN belongs_to b ON g.game_id = b.game_id
    JOIN genres ge ON b.genre_id = ge.genre_id
    WHERE ge.genre_name = 'Action'
),
popularity AS (
    SELECT game_id, COUNT(*) as popularity_count
    FROM (
        SELECT game_id FROM purchase
        UNION ALL
        SELECT game_id FROM wishlist
    ) p
    GROUP BY game_id
),
max_popularity AS (
    SELECT MAX(popularity_count) as max_popularity_count
    FROM popularity p
    JOIN action_games a ON p.game_id = a.game_id
)
SELECT a.name, p.popularity_count
FROM action_games a
JOIN popularity p ON a.game_id = p.game_id
JOIN max_popularity m ON p.popularity_count = m.max_popularity_count;
--C2
WITH action_games AS (
    SELECT g.game_id, g.name
    FROM games g
    JOIN belongs_to b ON g.game_id = b.game_id
    JOIN genres ge ON b.genre_id = ge.genre_id
    WHERE ge.genre_name = 'Action'
),
purchase_counts AS (
    SELECT game_id, COUNT(*) as purchase_count
    FROM purchase
    GROUP BY game_id
),
wishlist_counts AS (
    SELECT game_id, COUNT(*) as wishlist_count
    FROM wishlist
    GROUP BY game_id
),
popularity AS (
    SELECT a.game_id, COALESCE(p.purchase_count, 0) + COALESCE(w.wishlist_count, 0) as popularity_count
    FROM action_games a
    LEFT JOIN purchase_counts p ON a.game_id = p.game_id
    LEFT JOIN wishlist_counts w ON a.game_id = w.game_id
),
max_popularity AS (
    SELECT MAX(popularity_count) as max_popularity_count
    FROM popularity
)
SELECT a.name, p.popularity_count
FROM action_games a
JOIN popularity p ON a.game_id = p.game_id
JOIN max_popularity m ON p.popularity_count = m.max_popularity_count;

--10. Người dùng đã tiêu tiền nhiều nhất 
WITH spending AS (
    SELECT u.user_id, u.username, SUM(g.price) as total_spent
    FROM users u
    JOIN purchase p ON u.user_id = p.user_id
    JOIN games g ON p.game_id = g.game_id
    GROUP BY u.user_id, u.username
),
max_spending AS (
    SELECT MAX(total_spent) as max_spent
    FROM spending
)
SELECT s.username, s.total_spent
FROM spending s
JOIN max_spending m ON s.total_spent = m.max_spent;

-- 11 câu tiếp theo: Nguyễn Thanh Nhật Bảo 20210096

--1. 10 game mới được xuất bản gần đây nhất
SELECT *
FROM games
WHERE release_date < current_date
ORDER BY release_date DESC
LIMIT 10;

--2. Thể loại game được ưa thích nhất (phụ thuộc vào việc chứa nhiều bản game được tải nhất)
-- C1
WITH table_temp as (
    SELECT genre_id, genre_name, count(user_id) as downloaded
    FROM (genres left join belongs_to using (genre_id)) join purchase using (game_id)
    GROUP BY genre_id, genre_name
)
SELECT genre_id, genre_name  FROM table_temp WHERE downloaded >= ALL (SELECT downloaded FROM table_temp);
-- C2
SELECT g.genre_id, g.genre_name
FROM genres g
JOIN belongs_to b ON g.genre_id = b.genre_id
JOIN purchase p ON b.game_id = p.game_id
GROUP BY g.genre_id, g.genre_name
HAVING COUNT(p.user_id) = (
    SELECT MAX(downloaded)
    FROM (
        SELECT COUNT(p2.user_id) as downloaded
        FROM genres g2
        JOIN belongs_to b2 ON g2.genre_id = b2.genre_id
        JOIN purchase p2 ON b2.game_id = p2.game_id
        GROUP BY g2.genre_id, g2.genre_name
    ) t
);

--3. Loại Rating nào mà được nhiều người chơi đánh giá nhất cho "Celestial Odyssey"?
WITH table1 AS (
    SELECT user_id, scoring,
           CASE
                WHEN scoring < 2
                     THEN 'Bad'
                WHEN scoring >= 2
                    AND scoring < 4 THEN 'Average'
                WHEN scoring > 4 THEN 'Good'
           END type_rating
    FROM review JOIN (select game_id from games where name = 'Celestial Odyssey' ) as temp USING (game_id)
)
SELECT type_rating, count(user_id) number_rating
FROM table1
GROUP BY type_rating
HAVING count(user_id) >= ALL (select count(user_id) from table1 group by type_rating);

--4. Game được mong chờ nhất (chưa hoàn thiện/ nhiều người wishlist)
select  game_id, count(user_id)
from (select * from games where release_date > current_date) as temp join wishlist using (game_id)
group by game_id
order by count(user_id) DESC
limit 1;

--5. Game được nhiều người review nhất
-- C1
select *
from games
where game_id = (
    select game_id
    from review
    group by game_id
    having count(user_id) >= all (select count(user_id) from review group by game_id)
);
--C2
WITH max_ratings AS (
    SELECT MAX(rating_count) as max_rating_count
    FROM (
        SELECT game_id, COUNT(user_id) as rating_count
        FROM review
        GROUP BY game_id
    ) t
)
SELECT *
FROM games g
JOIN (
    SELECT game_id, COUNT(user_id) as rating_count
    FROM review
    GROUP BY game_id
) r ON g.game_id = r.game_id
JOIN max_ratings m ON r.rating_count = m.max_rating_count;

--6. Nhà phát triển có lượt mua cao nhất vào năm 2020  
-- C1
with table_temp1 as (
    select developer_id, count(user_id) as number_downloaded
     from (select game_id, user_id from purchase where time between '2020-01-01' and '2020-12-01' ) as temp1
          join
          (select game_id, developer_id from games ) as temp2
     using (game_id)
     group by developer_id
)
select * from table_temp1 where number_downloaded >= all (select number_downloaded from table_temp1);
-- C2
WITH purchase_counts AS (
    SELECT g.developer_id, COUNT(p.user_id) as purchase_count
    FROM purchase p
    JOIN games g ON p.game_id = g.game_id
    WHERE p.time BETWEEN '2020-01-01' AND '2020-12-01'
    GROUP BY g.developer_id
),
max_purchase AS (
    SELECT MAX(purchase_count) as max_purchase_count
    FROM purchase_counts
)
SELECT pc.developer_id, pc.purchase_count
FROM purchase_counts pc
JOIN max_purchase mp ON pc.purchase_count = mp.max_purchase_count;

--7. Nhà phát triển có doanh thu cao nhất (trong thời gian nào đó)
--C1
with table_temp1 as (
    select developer_id, sum(price) as total_revenue
     from (select game_id, user_id from purchase where time between '2020-01-01' and '2020-12-01' ) as temp1
          join
          (select game_id, developer_id, price from games ) as temp2
     using (game_id)
     group by developer_id
)
select * from table_temp1 where total_revenue >= all (select total_revenue from table_temp1);
--C2
WITH revenue AS (
    SELECT g.developer_id, SUM(g.price) as total_revenue
    FROM purchase p
    JOIN games g ON p.game_id = g.game_id
    WHERE p.time BETWEEN '2020-01-01' AND '2020-12-01'
    GROUP BY g.developer_id
),
max_revenue AS (
    SELECT MAX(total_revenue) as max_total_revenue
    FROM revenue
)
SELECT r.developer_id, r.total_revenue
FROM revenue r
JOIN max_revenue m ON r.total_revenue = m.max_total_revenue;

--8. In ra các nhà phát triển đã phát triển nhiều nhất 1 game thuộc thể loại "Visual Novel"
--C1
SELECT d.name
FROM game_dev d
LEFT JOIN (
    SELECT g.developer_id, COUNT(*) as game_count
    FROM games g
    JOIN belongs_to b ON g.game_id = b.game_id
    JOIN genres ge ON b.genre_id = ge.genre_id
    WHERE ge.genre_name = 'Visual Novel'
    GROUP BY g.developer_id
) v ON d.developer_id = v.developer_id
WHERE v.game_count IS NULL OR v.game_count <= 1;
--C2
WITH vn_games AS (
    SELECT g.developer_id, COUNT(*) as game_count
    FROM games g
    JOIN belongs_to b ON g.game_id = b.game_id
    JOIN genres ge ON b.genre_id = ge.genre_id
    WHERE ge.genre_name = 'Visual Novel'
    GROUP BY g.developer_id
)
SELECT d.name
FROM game_dev d
LEFT JOIN vn_games v ON d.developer_id = v.developer_id
WHERE v.game_count IS NULL OR v.game_count <= 1;

--9. Thể loại game chủ đạo của nhà phát triển "Nintendo" 
SELECT genre_id, genre_name, count(game_id)
FROM (SELECT * FROM game_dev WHERE name = 'Nintendo' ) AS temp
       JOIN games USING (developer_id)
       JOIN belongs_to USING (game_id)
       JOIN genres USING (genre_id)
GROUP BY genre_id, genre_name
ORDER BY count(game_id) DESC
LIMIT 1;

--10. Thể loại Game mang lại doanh thu lớn nhất cho Nintendo
-- C1
WITH table1 as(
SELECT genre_id, genre_name, count(game_id) AS number_of_games
FROM ((SELECT * FROM game_dev WHERE name = 'Nintendo' ) AS temp
       JOIN games USING (developer_id)
       JOIN belongs_to USING (game_id)
       JOIN genres USING (genre_id)) as table1
GROUP BY genre_id, genre_name)
SELECT genre_id, genre_name, number_of_games
FROM table1
WHERE number_of_games >= ALL  (SELECT number_of_games FROM table1);
--C2
SELECT genres.genre_id, genres.genre_name, COUNT(games.game_id) AS number_of_games
FROM game_dev
JOIN games ON game_dev.developer_id = games.developer_id
JOIN belongs_to ON games.game_id = belongs_to.game_id
JOIN genres ON belongs_to.genre_id = genres.genre_id
WHERE game_dev.name = 'Nintendo'
GROUP BY genres.genre_id, genres.genre_name
ORDER BY number_of_games DESC
LIMIT 1;

--11. Game chưa có đánh giá dù đã có người tải xuống
SELECT purchase.game_id,
       count(purchase.user_id) as downloaded,
       count(distinct review.user_id) as number_review
FROM purchase LEFT JOIN review on (purchase.game_id = review.game_id AND purchase.user_id = review.user_id)
GROUP BY purchase.game_id
HAVING count(distinct review.user_id) = 0;

--10 câu cuối: Nguyễn Văn Đăng 20215033

--1. In ra phiên bản hiện tại của "Hollow Knight: Silksong"
SELECT ver
FROM games
WHERE lower(name) = 'hollow knight: silksong';


--2*. In ra các giao dịch thanh toán vào tháng 1 năm 2021 với mức thanh toán dưới 10.00
--C1
SELECT *
FROM purchase join games using (game_id)
WHERE extract(month from "time") = 01 and extract (year from "time") = 2021 AND price < 10.00;

--C2
SELECT *
FROM purchase join games using (game_id)
WHERE "time" > '2020-12-31' AND "time" < '2021-02-01' AND price < 10.00;

--Cách 1 sử dụng extract để lấy giá trị tháng và năm từ cột time, bằng cách sử dụng AND để nhận được giá trị ngày tháng thuộc tháng 1 năm 2021. Cách làm này không thể sử dụng index để cải thiện hiệu năng truy vấn do có quá nhiều giá trị có tháng là 01 và năm là 2021 trong dữ liệu.
--Cách 2 thay vì sử dụng extract, ta dùng toán tử so sánh để lấy các giá trị thời gian lớn hơn 31/12/2020 và bé hơn 01/02/2021, từ đó có được thời gian mong muốn. Index có thể được sử dụng để cải thiện hiệu năng truy vấn trong trường hợp này. 

--3* Top 3 Nhà phát triển nào bị đánh giá tiêu cực nhất. (Rating trung bình của các tựa game do họ phát triển là thấp nhất)
SELECT game_dev.name, CAST(AVG(rating) as numeric(3,2)) as scoring
FROM game_dev join games using (developer_id) join game_rate using (game_id)
GROUP BY developer_id
ORDER BY scoring
LIMIT 3;

--4. Game có nhiều đánh giá dưới 1.5 nhất
SELECT name, count(user_id) Number_of_low
FROM games join review using (game_id)
WHERE scoring < 1.5
GROUP BY game_id
ORDER BY Number_of_low DESC
LIMIT 1;

--5. Ba người dùng khó tính nhất với các tựa game. (Rating đưa ra trung bình là thấp nhất)
SELECT username, CAST(AVG(scoring) as numeric(3,2)) grading 
FROM users join review using(user_id)
GROUP BY user_id, username
ORDER BY grading ASC
LIMIT 3;



--6* Trigger không cho người dùng review game nếu họ chưa sở hữu game hoặc nếu họ đang bị hạn chếvà đưa ra thông báo 
CREATE OR REPLACE FUNCTION review_invalid() RETURNS TRIGGER AS $$
DECLARE
	f_username varchar(50);
	f_gamename varchar(50);
BEGIN
	select into f_username username
	from users
	where user_id = NEW.user_id;
	select into f_gamename name
	from games
	where game_id = NEW.game_id;
	IF (NEW.user_id) in (select user_id from users where status = 'f') THEN
		RAISE NOTICE '% is being banned, thus unable to make reviews', f_username;
		RETURN NULL;
	END IF;
	IF (NEW.user_id, NEW.game_id) not in (select user_id, game_id from purchase) THEN 
		RAISE NOTICE '% has not owned %, thus unable to leave review.', f_username, f_gamename;
		RETURN NULL;
	ELSE IF (NEW.user_id, NEW.game_id) in (select user_id, game_id from review) THEN
		UPDATE review SET scoring = NEW.scoring where (user_id = NEW.user_id and game_id = NEW.game_id);
		RAISE NOTICE '% has changed their opinion about %', f_username, f_gamename;
		RETURN NULL;
		ELSE RETURN NEW;
		END IF;
	END IF;
END;
$$
LANGUAGE plpgsql;

CREATE TRIGGER not_available
BEFORE INSERT ON review
FOR EACH ROW
EXECUTE PROCEDURE review_invalid();

--Trigger được gọi trước khi insert vào bảng review  để đảm bảo các review luôn từ những người dùng đã chơi qua, hoặc ít nhất là đã sở hữu tựa game được review.

--7. Thống kê doanh thu mà các thể loại mang lại cho nhà phát triển "Nintendo"
SELECT game_dev.name, genre_name, SUM(revenue)
FROM game_revenue join games using (game_id) join game_dev using (developer_id) join belongs_to using (game_id) join genres using (genre_id)
WHERE lower(game_dev.name) = 'nintendo'
GROUP BY game_dev.name, genre_name;
 
--8. Thống kê số lượt game được mua và wishlist của các game được xuất bản vào năm 2020
WITH number_purchased AS
(SELECT name, game_id, count(user_id) as no_purchase
FROM games left join purchase using (game_id)
WHERE release_date >= '2020-01-01' AND release_date <= '2020-12-31'
GROUP BY name, game_id)
SELECT name, game_id, no_purchase + count(user_id) as popularity
FROM number_purchased left join wishlist using (game_id)
GROUP BY game_id, name, no_purchase;

--9. Thống kê những tựa game có rating trên 4.0 và có giá dưới 20.00 được tạo ra bởi "PopCaps"
SELECT games.*
FROM games join game_rate using (game_id)
WHERE rating > 4.0 and price < 20.00 and game_id in (
	SELECT game_id
	FROM games join game_dev using (developer_id)
	where lower(game_dev.name) = 'popcap' 
)
;

SELECT games.*
FROM games join game_rate using (game_id) join game_dev using (developer_id)
WHERE lower(game_dev.name) = 'popcap' and rating > 4.0 and price < 20.00;


--10. Những người dùng tiêu nhiều tiền để mua game nhất.
SELECT username, sum(price) as money_spent
FROM users join purchase using (user_id) join games using (game_id)
GROUP BY username
ORDER BY money_spent DESC
LIMIT 5;

--11*. Đưa ra những người dùng đã mua hai game thuộc dòng "Pro Evolution Soccer" trở lên
--C1
WITH a AS
(SELECT user_id
FROM games join purchase using (game_id)
WHERE name LIKE 'Pro Evolution Soccer %'
GROUP BY user_id
HAVING count(game_id) >= 2)
SELECT username
FROM users join a using (user_id)
;

--C2
SELECT username
FROM purchase join users using (user_id)
        join (
        SELECT game_id
        FROM games
        WHERE name LIKE 'Pro Evolution Soccer %'
) AS sub using (game_id)
GROUP BY username
HAVING count(game_id) >= 2;

--Hai cách trên có hiệu suất truy vấn tương tự nhau, tuy nhiên ở cách 1, sub query đã loại bỏ một số bản ghi chứa giá trị user_id không mua tối thiểu 2 game, từ đó giảm thời gian join. Tuy nhiên thời gian tìm ra kết quả của hai cách là tương tự. Việc dùng HAVING ngăn cản sử dụng index trong trường hợp này.




