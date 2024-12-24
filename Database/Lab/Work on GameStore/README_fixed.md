# BÁO CÁO CHO THỰC HÀNH CƠ SỞ DỮ LIỆU

1. [x] 10 game mới được thêm gần đây nhất
2. [x] Thể loại game được ưa thích nhất (chứa nhiều bản game được tải nhất)
3. [x] Game có đánh giá tranh cãi nhất (Luot tai nhieu ma rating thap)
4. [x] Rating nào mà được nhiều người chơi đánh giá nhất cho "Celestial Odyssey"?
5. [x] Game được mong chờ nhất (chưa hoàn thiện/ nhiều người wishlist)
6. [x] Game nào được nhiều người review nhất
7. [x] Nhà phát triển có doanh thu cao nhất (trong thời gian nào đó)
8. [x] In ra các nhà phát triển đã phát triển nhiều nhất 1 game thuộc thể loại "Visual Novel"
9. [x] Thể loại game chủ đạo của nhà phát triển "Nintendo" (Trong thể loại, thể loại nào có nhiều game được nhà phát triển này tạo ra?)
10. [x] Game chưa có đánh giá dù đã có người tải xuống

## 10 game mới được xuất bản gần đây nhất

```sql
SELECT *
FROM games
WHERE release_date < current_date
ORDER BY release_date DESC
LIMIT 10;

-- Phương án này có thể sử dụng được Index trên cột release_date để tăng hiệu năng 

```

## Thể loại game được ưa thích nhất (phụ thuộc vào việc chứa nhiều bản game được tải nhất)

```sql
-- THUYẾT TRÌNH NHÉ
-- c1
WITH table_temp as (
    SELECT genre_id, genre_name, count(user_id) as downloaded
    FROM (genres left join belongs_to using (genre_id)) join purchase using (game_id)
    GROUP BY genre_id, genre_name
)
SELECT genre_id, genre_name  FROM table_temp WHERE downloaded >= ALL (SELECT downloaded FROM table_temp);
-- Sử dụng được Index trên các thuộc tính của belongs_to 

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
-- Phương án này sử dụng điều kiện của nhóm HAVING và trong đó có một câu lệnh truy vấn con. Khi đó, chương trình sẽ phải chạy qua từng bản ghi trong nhóm, thực hiện câu truy vấn con này. Khiến cho phương án này không hiệu quả 
```

## Game có đánh giá tranh cãi nhất (Chênh lệnh giữa min max rating và average là lớn nhất)

```sql
WITH table_temp as (
SELECT purchase.game_id,
       count(purchase.user_id) as downloaded,
       count(distinct review.user_id) as number_review,
       avg(scoring) as rating
FROM purchase LEFT JOIN review on (purchase.game_id = review.game_id AND purchase.user_id = review.user_id)
GROUP BY purchase.game_id
order by downloaded DESC
LIMIT 5
)
select game_id FROM table_temp WHERE rating <= ALL (select rating from table_temp);
```

## Loại Rating nào mà được nhiều người chơi đánh giá nhất cho "Celestial Odyssey"?
```sql
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
-- Ta có thể sử dụng Index cho cột game_id hoặc scoring, tuy nhiên cột scoring có thể có các giá trị lặp nên chỉ cần game_id cũng có thể tăng hiệu năng

```

## Game được mong chờ nhất (chưa hoàn thiện/ nhiều người wishlist)

```sql
select  game_id, count(user_id)
from (select * from games where release_date > current_date) as temp join wishlist using (game_id)
group by game_id
order by count(user_id) DESC
limit 1;
```

## Game nào được nhiều người review nhất

```sql
-- C1
select *
from games
where game_id = (
    select game_id
    from review
    group by game_id
    having count(user_id) >= all (select count(user_id) from review group by game_id)
);
-- Sử dụng HAVING sẽ phải lọc điều kiện nhóm, mà nhóm cũng là một công đoạn khá tốn kém nên ta có phương án sử dụng mệnh đề con ở WITH như sau:

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
-- Lúc này mệnh đè con ở WIth sẽ lọc và tính ra được MAX của số lượng rating sử dụng để nối với bảng game, sẽ không phải nhóm và kiểm tra liên tục như phương án đầu

```

## Nhà phát triển có lượt mua cao nhất vào năm 2020  

```sql
-- THUYẾT TRÌNH NHÉ!
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
-- Phương án này sẽ khá tốt nhưng với điều kiện ở cuối >= ALL, ta sẽ không thể sử dụng được Index, thay vào đó, ta có thể dùng MAX từ một bảng phụ khác:

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

```

## Nhà phát triển có doanh thu cao nhất (trong thời gian nào đó)

```sql
with table_temp1 as (
    select developer_id, sum(price) as total_revenue
     from (select game_id, user_id from purchase where time between '2020-01-01' and '2020-12-01' ) as temp1
          join
          (select game_id, developer_id, price from games ) as temp2
     using (game_id)
     group by developer_id
)
select * from table_temp1 where total_revenue >= all (select total_revenue from table_temp1);

-- Tương tự như câu trên, để tránh sử dụng ALL, ta có thể thêm một bảng con trong WITH:
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
```

## In ra các nhà phát triển đã phát triển nhiều nhất 1 game thuộc thể loại "Visual Novel"

```sql
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
WHERE v.game_count =NULL OR v.game_count <= 1;

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
WHERE v.game_count =0 OR v.game_count <= 1;

-- Cả 2 cách đều phải sử dụng JOIN ngoài để có thể xem được xem mình đã có được bao nhiêu game chứa 0 hoặc 1 thể loại như đề bài. Điều kiện WHERE không thay đổi nhiều nên hiệu năng tương đương
```

## Thể loại game chủ đạo của nhà phát triển "Nintendo" (Trong thể loại, thể loại nào có nhiều game được nhà phát triển này tạo ra?)

```sql
SELECT genre_id, genre_name, count(game_id)
FROM (SELECT * FROM game_dev WHERE name = 'Nintendo' ) AS temp
       JOIN games USING (developer_id)
       JOIN belongs_to USING (game_id)
       JOIN genres USING (genre_id)
GROUP BY genre_id, genre_name
ORDER BY count(game_id) DESC
LIMIT 1;
```
## thể loại Game mang lại doanh thu lớn nhất cho Nintendo
```sql
-- THUYẾT TRÌNH NHÉ 
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
-- Không phải WITH nào cũng là tối ưu, trường hợp này truy vấn con có khả năng chậm hơn nối JOIN thông thường, và chưa kể ALL nghĩa là phải so sánh với tất cả bản ghi, kém hiệu quả hơn ORDER BY


```

## Game chưa có đánh giá dù đã có người tải xuống

```sql
SELECT purchase.game_id,
       count(purchase.user_id) as downloaded,
       count(distinct review.user_id) as number_review
FROM purchase LEFT JOIN review on (purchase.game_id = review.game_id AND purchase.user_id = review.user_id)
GROUP BY purchase.game_id
HAVING count(distinct review.user_id) = 0;
```
