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
