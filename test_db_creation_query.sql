CREATE TABLE chat_test.user LIKE chat_messaging.user;
INSERT INTO chat_test.user SELECT * FROM chat_messaging.user;
  
CREATE TABLE chat_test.room LIKE chat_messaging.room;
INSERT INTO chat_test.room SELECT * FROM chat_messaging.room;

CREATE TABLE chat_test.room_user LIKE chat_messaging.room_user;
INSERT INTO chat_test.room_user SELECT * FROM chat_messaging.room_user;

CREATE TABLE chat_test.message LIKE chat_messaging.message;
INSERT INTO chat_test.message SELECT * FROM chat_messaging.message;

CREATE TABLE chat_test.emoji LIKE chat_messaging.emoji;
INSERT INTO chat_test.emoji SELECT * FROM chat_messaging.emoji;

CREATE TABLE chat_test.emoji_reactions LIKE chat_messaging.emoji_reactions;
INSERT INTO chat_test.emoji_reactions SELECT * FROM chat_messaging.emoji_reactions;

SELECT room.name
FROM room
JOIN room_user ON room.room_id = room_user.room_id
JOIN user ON user.user_id = room_user.user_id
WHERE user.username = 'fluffybunny91';


SELECT room.name, message.
FROM room
JOIN room_user ON room.room_id = room_user.room_id
JOIN user ON user.user_id = room_user.user_id
WHERE user.username = 'fluffybunny91';


SELECT 
    room.name, 
    latest_message.sent_datetime as latest_message_time
FROM room
JOIN room_user ON room.room_id = room_user.room_id
JOIN user ON user.user_id = room_user.user_id
JOIN (SELECT message.*, room_user.room_id
    FROM message
    JOIN ( SELECT room_id,  MAX(message_id) as max_message_id
        FROM message
        JOIN room_user ON message.room_user_id = room_user.room_user_id
        GROUP BY room_id
	) subquery ON message.message_id = subquery.max_message_id
    JOIN 
        room_user ON message.room_user_id = room_user.room_user_id
) latest_message ON room.room_id = latest_message.room_id
WHERE user.username = 'fluffybunny91';


SELECT 
    room.name, 
    latest_message.sent_datetime as latest_message_time
FROM room
JOIN room_user ON room.room_id = room_user.room_id
JOIN user ON user.user_id = room_user.user_id
JOIN (SELECT message.*, room_user.room_id
    FROM message
    JOIN ( SELECT room_id,  MAX(message_id) as max_message_id
        FROM message
        JOIN room_user ON message.room_user_id = room_user.room_user_id
        GROUP BY room_id
	) subquery ON message.message_id = subquery.max_message_id
    JOIN 
        room_user ON message.room_user_id = room_user.room_user_id
) latest_message ON room.room_id = latest_message.room_id
WHERE user.username = 'fluffybunny91';


SELECT 
    room.name, 
    latest_message.sent_datetime as latest_message_time,
    message_count.num_messages_behind 
FROM room
LEFT JOIN room_user ON room.room_id = room_user.room_id
JOIN user ON user.user_id = room_user.user_id
JOIN (SELECT message.*, room_user.room_id
    FROM message
    JOIN ( SELECT room_id,  MAX(message_id) as max_message_id
        FROM message
        JOIN room_user ON message.room_user_id = room_user.room_user_id
        GROUP BY room_id
	) subquery ON message.message_id = subquery.max_message_id
    JOIN 
        room_user ON message.room_user_id = room_user.room_user_id
) latest_message ON room.room_id = latest_message.room_id
JOIN (
    SELECT room_user.room_id, COUNT(*) AS num_messages_behind 
    FROM room_user
    JOIN message ON room_user.room_user_id = message.room_user_id
    WHERE message.message_id > room_user.last_read_message_id
    GROUP BY room_user.room_id
) AS message_count ON room.room_id = message_count.room_id
WHERE user.username = 'iloveyou2';


SELECT 
    room.name, 
    COALESCE(latest_message.sent_datetime, 'No messages') as latest_message_time,
    COALESCE(message_count.num_messages_behind, 0) AS num_messages_behind
FROM room
LEFT JOIN room_user ON room.room_id = room_user.room_id AND room_user.user_id = (
    SELECT user_id FROM user WHERE username = 'iloveyou2'
)
LEFT JOIN user ON user.user_id = room_user.user_id
LEFT JOIN (
    SELECT message.*, room_user.room_id
    FROM message
    JOIN (
        SELECT room_id, MAX(message_id) as max_message_id
        FROM message
        JOIN room_user ON message.room_user_id = room_user.room_user_id
        GROUP BY room_id
    ) subquery ON message.message_id = subquery.max_message_id
    JOIN room_user ON message.room_user_id = room_user.room_user_id
) latest_message ON room.room_id = latest_message.room_id
LEFT JOIN (
    SELECT room_user.room_id, COUNT(*) AS num_messages_behind 
    FROM room_user
    JOIN message ON room_user.room_user_id = message.room_user_id
    WHERE message.message_id > COALESCE(room_user.last_read_message_id, 0)
    GROUP BY room_user.room_id
) AS message_count ON room.room_id = message_count.room_id
WHERE user.username = 'iloveyou2';

START TRANSACTION;
INSERT INTO room (name)
VALUES ('mello');

SET @last_room_id = LAST_INSERT_ID();

INSERT INTO room_user (user_id,room_id,last_read_message_id)
VALUES (1, @last_room_id, 0);

COMMIT;


START TRANSACTION;

    INSERT INTO room (name)
    VALUES ('test2');

    SET @last_room_id = LAST_INSERT_ID();

 INSERT INTO room_user (user_id,room_id,last_read_message_id)
VALUES (2, @last_room_id, 0),(3, @last_room_id, 0),(4, @last_room_id, 0),(5, @last_room_id, 0),(6, @last_room_id, 0);

 COMMIT;
ROLLBACK;


INSERT INTO room_user (user_id, room_id, last_read_message_id)
SELECT user_id, @last_room_id, 0
FROM user
WHERE username = 'yongeun';

SELECT Max(room_id) AS room_id FROM room;


SELECT message.sent_datetime,message.message_id, message.text, user.user_id, user.username, room.room_id, room.name
FROM message 
LEFT JOIN room_user ON message.room_user_id = room_user.room_user_id
JOIN user  ON user.user_id = room_user.user_id
JOIN room ON room.room_id = room_user.room_id
WHERE room.room_id = 1
ORDER BY message.sent_datetime asc;

SELECT user.username
FROM user
WHERE user.username NOT IN (
    SELECT user.username
    FROM user
    JOIN room_user ON user.user_id = room_user.user_id
    JOIN room ON room_user.room_id = room.room_id
    WHERE room.room_id = 1
);

SELECT message.sent_datetime,message.message_id, message.text, user.user_id, user.username, room.room_id, room.name, room_user.last_read_message_id
    FROM message 
    LEFT JOIN room_user ON message.room_user_id = room_user.room_user_id
    JOIN user  ON user.user_id = room_user.user_id
    JOIN room ON room.room_id = room_user.room_id
    WHERE room.room_id = 1
    ORDER BY message.sent_datetime ASC;
    
    
    
SELECT DISTINCT room.room_id, room.name
FROM room
JOIN room_user ON room.room_id = room_user.room_id
WHERE room_user.user_id != 2; 


SELECT DISTINCT room.room_id, room.name
FROM room
LEFT JOIN room_user ON room.room_id = room_user.room_id AND room_user.user_id = 2
WHERE room_user.user_id IS NULL;

SELECT room.room_id, room.name
FROM room
LEFT JOIN room_user ON room.room_id = room_user.room_id AND room_user.user_id = 2
WHERE room_user.user_id IS NULL
GROUP BY room.room_id, room.name;

SELECT emoji_id, name, image FROM emoji;

UPDATE room_user
JOIN (
    SELECT room_user_id
    FROM room_user
    WHERE user_id = 12 AND room_id = 1
) AS subquery
ON room_user.room_user_id = subquery.room_user_id
SET room_user.last_read_message_id = 43;


SELECT room_user_id 
FROM room_user
WHERE room_id = 1 and user_id = 1;


SELECT message.sent_datetime,message.message_id, message.text, 
      user.user_id, user.profile_img, user.username, room.room_id, 
      room.name,room_user.last_read_message_id
    FROM message 
    LEFT JOIN room_user ON message.room_user_id = room_user.room_user_id
    JOIN user  ON user.user_id = room_user.user_id
    JOIN room ON room.room_id = room_user.room_id
    WHERE room.room_id = 1
    ORDER BY message.sent_datetime ASC;
    
    		SELECT last_read_message_id
    FROM room_user
    WHERE user_id = 12 AND room_id = 1;
    
SELECT 
	room.room_id, 
    room.name, 
    user.username, 
    room_user.room_user_id,
	room_user.last_read_message_id,
    MAX(message.message_id) AS my_last_sent_message,
    COALESCE(max_message.max_message_id, 0) as max_message_id,
	COALESCE(latest_message.sent_datetime, 'No messages') as latest_message_time,
	COALESCE(message_count.num_messages_behind, 0) AS num_messages_behind
FROM room
LEFT JOIN room_user ON room.room_id = room_user.room_id
LEFT JOIN user ON room_user.user_id = user.user_id
LEFT JOIN message ON room_user.room_user_id = message.room_user_id
LEFT JOIN (
        SELECT room_user.room_id, room_user.user_id, room_user.room_user_id, message.message_id, message.sent_datetime, message.text
        FROM message
        JOIN (
            SELECT room_id, MAX(message_id) as max_message_id
            FROM message
            JOIN room_user ON message.room_user_id = room_user.room_user_id
            GROUP BY room_id
        ) subquery ON message.message_id = subquery.max_message_id
         JOIN room_user ON message.room_user_id = room_user.room_user_id
    ) latest_message ON room.room_id = latest_message.room_id
LEFT JOIN( 
		SELECT room_user.room_id, MAX(message_id) as max_message_id
		FROM message
		JOIN room_user ON message.room_user_id = room_user.room_user_id
		GROUP BY room_user.room_id
        )  max_message ON max_message.room_id = room.room_id
LEFT JOIN (
         SELECT room_user.room_id, COUNT(*) AS num_messages_behind 
        FROM room_user
        JOIN message ON room_user.room_user_id = message.room_user_id
        JOIN (
			 SELECT room_user.room_id, MAX(message_id) as max_message_id
			FROM message
			JOIN room_user ON message.room_user_id = room_user.room_user_id
			GROUP BY room_user.room_id
        )  max_message ON max_message.room_id = room_user.room_id
        WHERE max_message.max_message_id > COALESCE(room_user.last_read_message_id, 0) 
        GROUP BY room_user.room_id
    ) AS message_count ON room.room_id = message_count.room_id
WHERE user.user_id =1
GROUP BY 
	room.room_id, 
    room.name, 
    user.username,  
	room_user.room_user_id, 
    room_user.last_read_message_id, 
    max_message.max_message_id, 
    latest_message.sent_datetime;
    
    

 SELECT room_user.room_id, COUNT(*) AS num_messages_behind 
        FROM room_user
        JOIN message ON room_user.room_user_id = message.room_user_id
        JOIN (
			 SELECT room_user.room_id, MAX(message_id) as max_message_id
			FROM message
			JOIN room_user ON message.room_user_id = room_user.room_user_id
			GROUP BY room_user.room_id
        )  max_message ON max_message.room_id = room_user.room_id
        WHERE max_message.max_message_id > COALESCE(room_user.last_read_message_id, 0) 
        GROUP BY room_user.room_id
        
        
       	// SELECT 
    //     room.room_id,
    //     room.name, 
    //     user.username,
    //     COALESCE(latest_message.sent_datetime, 'No messages') as latest_message_time,
    //     COALESCE(message_count.num_messages_behind, 0) AS num_messages_behind
    // FROM room
    // LEFT JOIN room_user ON room.room_id = room_user.room_id AND room_user.user_id = (
    //     SELECT user_id FROM user WHERE username = :username
    // )
    // LEFT JOIN user ON user.user_id = room_user.user_id
    // LEFT JOIN (
    //     SELECT message.*, room_user.room_id, room_user.user_id
    //     FROM message
    //     JOIN (
    //         SELECT room_id, MAX(message_id) as max_message_id
    //         FROM message
    //         JOIN room_user ON message.room_user_id = room_user.room_user_id
    //         GROUP BY room_id
    //     ) subquery ON message.message_id = subquery.max_message_id
    //     JOIN room_user ON message.room_user_id = room_user.room_user_id
    // ) latest_message ON room.room_id = latest_message.room_id AND room_user.user_id = latest_message.user_id
    // LEFT JOIN (
    //     SELECT room_user.room_id, COUNT(*) AS num_messages_behind 
    //     FROM room_user
    //     JOIN message ON room_user.room_user_id = message.room_user_id
    //     WHERE message.message_id > COALESCE(room_user.last_read_message_id, 0) AND room_user.user_id=:user_id
    //     GROUP BY room_user.room_id
    // ) AS message_count ON room.room_id = message_count.room_id
    // WHERE user.username = :username;
    
    
    
     SELECT 
    room.room_id, 
      room.name, 
      user.username, 
      room_user.room_user_id,
      room_user.last_read_message_id,
      MAX(message.message_id) AS my_last_sent_message,
      COALESCE(max_message.max_message_id, 0) as max_message_id,
      COALESCE(latest_message.sent_datetime, 'No messages') as latest_message_time,
      COALESCE(message_count.num_messages_behind, 0) AS num_messages_behind
  FROM room
  LEFT JOIN room_user ON room.room_id = room_user.room_id
  LEFT JOIN user ON room_user.user_id = user.user_id
  LEFT JOIN message ON room_user.room_user_id = message.room_user_id
  LEFT JOIN (
    SELECT room_user.room_id, room_user.user_id, room_user.room_user_id, message.message_id AS last_message, message.sent_datetime, message.text
      FROM message
      JOIN (
        SELECT room_id, MAX(message_id) as max_message_id
        FROM message
        JOIN room_user ON message.room_user_id = room_user.room_user_id
        GROUP BY room_id
      ) subquery ON message.message_id = subquery.max_message_id
    JOIN room_user ON message.room_user_id = room_user.room_user_id
  ) latest_message ON room.room_id = latest_message.room_id
  LEFT JOIN( 
   -- 방의 가장 마지막 메세지
    SELECT room_user.room_id, MAX(message_id) as max_message_id
    FROM message
    JOIN room_user ON message.room_user_id = room_user.room_user_id
    GROUP BY room_user.room_id
  )  max_message ON max_message.room_id = room.room_id
  LEFT JOIN (
    SELECT room_user.room_id, COUNT(*) AS num_messages_behind 
    FROM room_user
    JOIN message ON room_user.room_user_id = message.room_user_id
    JOIN (
      SELECT room_user.room_id, MAX(message_id) as max_message_id
      FROM message
      JOIN room_user ON message.room_user_id = room_user.room_user_id
      GROUP BY room_user.room_id
    )  max_message ON max_message.room_id = room_user.room_id
    WHERE max_message.max_message_id > COALESCE(room_user.last_read_message_id, 0)
    GROUP BY room_user.room_id
  ) AS message_count ON room.room_id = message_count.room_id
  WHERE user.user_id =12
  GROUP BY 
    room.room_id, 
    room.name, 
    user.username,  
    room_user.room_user_id, 
    room_user.last_read_message_id, 
    max_message.max_message_id, 
    latest_message.sent_datetime;


 SELECT room_user.room_id, room_user.user_id, room_user.room_user_id, message.message_id, message.sent_datetime, message.text
      FROM message
      JOIN (
        SELECT room_id, MAX(message_id) as max_message_id
        FROM message
        JOIN room_user ON message.room_user_id = room_user.room_user_id
        GROUP BY room_id
      ) subquery ON message.message_id = subquery.max_message_id
    JOIN room_user ON message.room_user_id = room_user.room_user_id


  SELECT room_user.room_id, room_user.user_id, room_user.room_user_id, message.message_id, message.sent_datetime, message.text
      FROM message
      JOIN (
        SELECT room_id, MAX(message_id) as max_message_id
        FROM message
        JOIN room_user ON message.room_user_id = room_user.room_user_id
        GROUP BY room_id
      ) subquery ON message.message_id = subquery.max_message_id
    JOIN room_user ON message.room_user_id = room_user.room_user_id




SELECT user.user_id, room.room_id, message_count.num_messages_behind , message.message_id, message.text
FROM room
JOIN room_user ON room.room_id = room_user.room_id
JOIN message ON room_user.room_user_id = message.room_user_id
JOIN user ON room_user.user_id = user.user_id
JOIN (
    SELECT room_user.room_id, COUNT(*) AS num_messages_behind 
    FROM room_user
    JOIN message ON room_user.room_user_id = message.room_user_id
    WHERE message.message_id > room_user.last_read_message_id
    GROUP BY room_user.room_id
) AS message_count ON room.room_id = message_count.room_id
WHERE room.room_id IN (
    SELECT room_user.room_id 
    FROM room_user
    JOIN message ON room_user.room_user_id = message.room_user_id
    WHERE message.message_id > room_user.last_read_message_id
) 
ORDER BY room.room_id, user.user_id;


SELECT room_user.room_id, COUNT(*) AS num_messages_behind 
    FROM room_user
    JOIN message ON room_user.room_user_id = message.room_user_id
    WHERE message.message_id > room_user.last_read_message_id
    GROUP BY room_user.room_id;
    
    
    
    
    
    
    
  SELECT 
    room.room_id, 
      room.name, 
      user.username, 
      room_user.room_user_id,
      room_user.last_read_message_id,
      latest_message.last_message AS last_message_in_room,
      MAX(message.message_id) AS my_last_sent_message,
      COALESCE(latest_message.sent_datetime, 'No messages') as latest_message_time,
      COALESCE(message_count.num_messages_behind, 0) AS num_messages_behind
  FROM room
  LEFT JOIN room_user ON room.room_id = room_user.room_id
  LEFT JOIN user ON room_user.user_id = user.user_id
  LEFT JOIN message ON room_user.room_user_id = message.room_user_id
  LEFT JOIN (
    SELECT room_user.room_id, room_user.user_id, room_user.room_user_id, message.message_id AS last_message, message.sent_datetime
      FROM message
      JOIN (
        SELECT room_id, MAX(message_id) as max_message_id
        FROM message
        JOIN room_user ON message.room_user_id = room_user.room_user_id
        GROUP BY room_id
      ) subquery ON message.message_id = subquery.max_message_id
    JOIN room_user ON message.room_user_id = room_user.room_user_id
  ) latest_message ON room.room_id = latest_message.room_id
  LEFT JOIN (
    SELECT room_user.room_id, COUNT(*) AS num_messages_behind 
    FROM room_user
    JOIN message ON room_user.room_user_id = message.room_user_id
    JOIN (
      SELECT room_user.room_id, MAX(message_id) as max_message_id
      FROM message
      JOIN room_user ON message.room_user_id = room_user.room_user_id
      GROUP BY room_user.room_id
    )  max_message ON max_message.room_id = room_user.room_id
    WHERE max_message.max_message_id > COALESCE(room_user.last_read_message_id, 0)
    GROUP BY room_user.room_id
  ) AS message_count ON room.room_id = message_count.room_id
  WHERE user.user_id =12
  GROUP BY 
    room.room_id, 
    room.name, 
    user.username,  
    room_user.room_user_id, 
    latest_message.last_message,
    room_user.last_read_message_id, 
    latest_message.sent_datetime;







  SELECT 
    room.room_id, 
      room.name, 
      user.username, 
      room_user.room_user_id,
      room_user.last_read_message_id,
      latest_message.last_message AS last_message_in_room,
      MAX(message.message_id) AS my_last_sent_message,
      COALESCE(latest_message.sent_datetime, 'No messages') as latest_message_time,
       COALESCE(message_count.num_messages_behind, 0) AS num_messages_behind
  FROM room
  LEFT JOIN room_user ON room.room_id = room_user.room_id
  LEFT JOIN user ON room_user.user_id = user.user_id
  LEFT JOIN message ON room_user.room_user_id = message.room_user_id
  LEFT JOIN (
    SELECT room_user.room_id, room_user.user_id, room_user.room_user_id, message.message_id AS last_message, message.sent_datetime
      FROM message
      JOIN (
        SELECT room_id, MAX(message_id) as max_message_id
        FROM message
        JOIN room_user ON message.room_user_id = room_user.room_user_id
        GROUP BY room_id
      ) subquery ON message.message_id = subquery.max_message_id
    JOIN room_user ON message.room_user_id = room_user.room_user_id
  ) latest_message ON room.room_id = latest_message.room_id
  LEFT JOIN (
    SELECT room_user.room_id, COUNT(*) AS num_messages_behind 
    FROM room_user
    JOIN message ON room_user.room_user_id = message.room_user_id
    JOIN (
      SELECT room_user.room_id, MAX(message_id) as max_message_id
      FROM message
      JOIN room_user ON message.room_user_id = room_user.room_user_id
      GROUP BY room_user.room_id
    )  max_message ON max_message.room_id = room_user.room_id
    WHERE max_message.max_message_id > COALESCE(room_user.last_read_message_id, 0)
    GROUP BY room_user.room_id
  ) AS message_count ON room.room_id = message_count.room_id
  WHERE user.user_id =1
  GROUP BY 
    room.room_id, 
    room.name, 
    user.username,  
    room_user.room_user_id, 
    latest_message.last_message,
    room_user.last_read_message_id, 
    latest_message.sent_datetime;
    
SELECT room_user.room_id, COUNT(max_message.max_message_id > COALESCE(room_user.last_read_message_id, 0))
    FROM room_user
    JOIN message ON room_user.room_user_id = message.room_user_id
    JOIN (
      SELECT room_user.room_id, MAX(message_id) as max_message_id
      FROM message
      JOIN room_user ON message.room_user_id = room_user.room_user_id
      WHERE user_id = 1
      GROUP BY room_user.room_id
    )  max_message ON max_message.room_id = room_user.room_id
    WHERE max_message.max_message_id > COALESCE(room_user.last_read_message_id, 0)
    GROUP BY room_user.room_id


SELECT room_user.room_id, room_user.user_id, COUNT(*) AS num_messages_behind 
	FROM room_user
    JOIN message ON room_user.room_user_id = message.room_user_id
    JOIN(
		SELECT room_user.room_id, room_user.room_user_id, room_user.last_read_message_id
        FROM room_user
        WHERE room_user.room_user_id = (SELECT room_user_id FROM room_user WHERE user_id = 1 AND room_id = 1)
    ) last_read_message ON last_read_message.room_user_id = room_user.room_user_id
    JOIN (
      SELECT room_user.room_id, MAX(message_id) as max_message_id
      FROM message
      JOIN room_user ON message.room_user_id = room_user.room_user_id
      GROUP BY room_user.room_id
    )  max_message ON max_message.room_id = room_user.room_id
    WHERE max_message.max_message_id > COALESCE(last_read_message.last_read_message_id, 0) 
    GROUP BY room_user.room_id, room_user.user_id;
  
  
  -- 25
SELECT room_user.room_id, room_user.last_read_message_id
        FROM room_user
        WHERE room_user.room_user_id = (SELECT room_user_id FROM room_user WHERE user_id = 1 AND room_id = 1)
        
        -- 49 
        SELECT room_user.room_id, MAX(message_id) as max_message_id
      FROM message
      JOIN room_user ON message.room_user_id = room_user.room_user_id
      GROUP BY room_user.room_id
      
      -- 1 번방 10개 메세지
      SELECT room_user.room_id, room_user.user_id, message.message_id, message.text
      FROM room_user
      JOIN message ON room_user.room_user_id = message.room_user_id
      
      JOIN 
    (SELECT @row_number:=0) AS rn
      WHERE room_user.room_id =1;
      
      
    SET @row_number = 0;


      
      
      SELECT max(message.message_id)
      FROM room_user
      JOIN message ON room_user.room_user_id = message.room_user_id
      WHERE room_id =1;
      
  
 SELECT  room_user.room_user_id,, room_user.room_id,  room_user.user_id, count(*) AS behind
 FROM room_user
 JOIN(
	 SELECT room_user.room_id, MAX(message_id) as max_message_id
		  FROM message
		  JOIN room_user ON message.room_user_id = room_user.room_user_id
		  GROUP BY room_user.room_id
 ) AS last_message_per_room ON room_user.room_id = last_message_per_room.room_id
 JOIN(
	 SELECT room_user.room_id, room_user.user_id, message.message_id, message.text
      FROM room_user
      JOIN message ON room_user.room_user_id = message.room_user_id
 ) AS all_messages_in_room ON last_message_per_room.room_id = all_messages_in_room.room_id
 WHERE room_user.user_id = 1 AND all_messages_in_room.message_id < last_message_per_room.max_message_id 
 GROUP BY  room_user.room_id, room_user.user_id;
 
  
 
      
      
 SELECT room_user.room_id, count(message.message_id > 25)
      FROM room_user
      JOIN message ON room_user.room_user_id = message.room_user_id
      WHERE user_id = 1
      GROUP BY room_user.room_id
      
      
      
SELECT room_user.room_user_id, room_user.room_id, room_user.user_id, last_read_message.last_read_message_id ,COUNT(*) AS behind
FROM room_user
JOIN (
    SELECT room_user.room_id, MAX(message_id) AS max_message_id
    FROM message
    JOIN room_user ON room_user.room_user_id = message.room_user_id
    GROUP BY room_id
) AS last_message_per_room ON room_user.room_id = last_message_per_room.room_id
JOIN (
    SELECT room_user.room_id, room_user.user_id, MAX(message_id) AS last_read_message_id
    FROM room_user
    JOIN message ON room_user.room_user_id = message.room_user_id
    WHERE room_user.user_id = 1
    GROUP BY room_user.room_id, room_user.user_id
) AS last_read_message ON room_user.room_id = last_read_message.room_id

GROUP BY room_user.room_id, room_user.user_id, last_read_message.last_read_message_id;
      
  WHERE room_user.user_id = 1
AND last_read_message.last_read_message_id < last_message_per_room.max_message_id    
      
 SELECT 
    room.room_id, 
      room.name, 
      user.username, 
      room_user.room_user_id,
      room_user.last_read_message_id,
      MAX(message.message_id) AS my_last_sent_message,
      COALESCE(max_message.max_message_id, 0) AS max_message_id,
      COALESCE(latest_message.sent_datetime, 'No messages') AS latest_message_time,
      COALESCE(message_count.num_messages_behind, 0) AS num_messages_behind
  FROM room
  LEFT JOIN room_user ON room.room_id = room_user.room_id
  LEFT JOIN user ON room_user.user_id = user.user_id
  LEFT JOIN message ON room_user.room_user_id = message.room_user_id
  LEFT JOIN (
    SELECT room_user.room_id, room_user.user_id, room_user.room_user_id, message.message_id, message.sent_datetime, message.text
      FROM message
      JOIN (
        SELECT room_id, MAX(message_id) AS max_message_id
        FROM message
        JOIN room_user ON message.room_user_id = room_user.room_user_id
        GROUP BY room_id
      ) subquery ON message.message_id = subquery.max_message_id
    JOIN room_user ON message.room_user_id = room_user.room_user_id
  ) latest_message ON room.room_id = latest_message.room_id
  LEFT JOIN( 
    SELECT room_user.room_id, MAX(message_id) AS max_message_id
    FROM message
    JOIN room_user ON message.room_user_id = room_user.room_user_id
    GROUP BY room_user.room_id
  )  max_message ON max_message.room_id = room.room_id
  LEFT JOIN (
    SELECT room_user.room_id, room_user.user_id, COUNT(*) AS num_messages_behind 
    FROM room_user
    JOIN message ON room_user.room_user_id = message.room_user_id
    JOIN (
      SELECT room_user.room_id, MAX(message_id) as max_message_id
      FROM message
      JOIN room_user ON message.room_user_id = room_user.room_user_id
      GROUP BY room_user.room_id
    )  max_message ON max_message.room_id = room_user.room_id
    WHERE max_message.max_message_id > room_user.last_read_message_id AND room_user.room_user_id = 1
    GROUP BY room_user.room_id, room_user.user_id
  ) AS message_count ON room.room_id = message_count.room_id
  WHERE user.user_id =1
  GROUP BY 
    room.room_id, 
    room.name, 
    user.username,  
    room_user.room_user_id, 
    room_user.last_read_message_id, 
    max_message.max_message_id, 
    latest_message.sent_datetime;
    
SET @row_number = 0;    
select room_user.*, max(row_num) as max_rownum, (
	SELECT subquery.message_id
)
FROM(
	SELECT 
		room_user.room_id, 
		room_user.user_id, 
		message.message_id, 
		message.text,
		(@row_number := @row_number + 1) AS row_num
	FROM 
		room_user
	JOIN 
		message ON room_user.room_user_id = message.room_user_id
	WHERE 
		room_user.room_id = 1 
) subquery 
JOIN message ON subquery.message_id = message.message_id
JOIN room_user ON message.room_user_id = room_user.room_user_id
GROUP BY subquery.message_id;
 
 SET @row_number = 0;  
SELECT 
    room_id,
    user_id,
    message_id,
    text,
    row_num
FROM (
	SELECT (@row_number := @row_number + 1) AS row_num, A.* FROM (
    SELECT 
		message.message_id, 
		room_user.room_id,
		room_user.user_id, 
        room_user.last_read_message_id,
		message.text
	FROM 
		message 
	LEFT JOIN 
		room_user ON room_user.room_user_id = message.room_user_id
	WHERE 
		room_user.room_id = 1 
	ORDER BY message.message_id ASC
    ) A
) numbered_messages
    
    
    
SELECT 
    room.room_id, 
      room.name, 
      user.username, 
      room_user.room_user_id,
      room_user.last_read_message_id,
      MAX(message.message_id) AS my_last_sent_message,
      COALESCE(max_message.max_message_id, 0) AS max_message_id,
      COALESCE(latest_message.sent_datetime, 'No messages') AS latest_message_time
  FROM room
  LEFT JOIN room_user ON room.room_id = room_user.room_id
  LEFT JOIN user ON room_user.user_id = user.user_id
  LEFT JOIN message ON room_user.room_user_id = message.room_user_id
  LEFT JOIN (
    SELECT room_user.room_id, room_user.user_id, room_user.room_user_id, message.message_id, message.sent_datetime, message.text
      FROM message
      JOIN (
        SELECT room_id, MAX(message_id) AS max_message_id
        FROM message
        JOIN room_user ON message.room_user_id = room_user.room_user_id
        GROUP BY room_id
      ) subquery ON message.message_id = subquery.max_message_id
    JOIN room_user ON message.room_user_id = room_user.room_user_id
  ) latest_message ON room.room_id = latest_message.room_id
  LEFT JOIN( 
    SELECT room_user.room_id, MAX(message_id) AS max_message_id
    FROM message
    JOIN room_user ON message.room_user_id = room_user.room_user_id
    GROUP BY room_user.room_id
  )  max_message ON max_message.room_id = room.room_id
  LEFT JOIN (
   SELECT 
		room_user.room_id, 
		room_user.user_id, 
		message.message_id, 
		message.text, 
		(@row_number := @row_number + 1) AS row_num
	FROM 
		room_user
	JOIN 
		message ON room_user.room_user_id = message.room_user_id
	JOIN latest_message ON 	latest_message.max_message_id =	message.message_id, 
	WHERE  
		room_user.room_id = 1
  ) AS message_count ON room.room_id = message_count.room_id
  WHERE user.user_id =1
  GROUP BY 
    room.room_id, 
    room.name, 
    user.username,  
    room_user.room_user_id, 
    room_user.last_read_message_id, 
    max_message.max_message_id, 
    latest_message.sent_datetime;



SELECT 
    A.*
FROM (
    SELECT 
        (@row_number := @row_number + 1) AS row_num,
        message.message_id, 
        room_user.room_id,
        room_user.user_id, 
        room_user.last_read_message_id,
        message.text,
        IF(room_user.last_read_message_id = message.message_id, 'TRUE', 'FALSE') AS last_read
    FROM 
        message 
    LEFT JOIN 
        room_user ON room_user.room_user_id = message.room_user_id
    WHERE 
        room_user.room_id = 1 
    ORDER BY 
        message.message_id ASC
) A
CROSS JOIN (SELECT @row_number := 0) AS r
WHERE 
    A.row_num = (SELECT MAX(row_num) FROM (SELECT (@row_number := @row_number + 1) AS row_num FROM message LEFT JOIN room_user ON room_user.room_user_id = message.room_user_id WHERE room_user.room_id = 1) AS temp)
    OR A.last_read = 'TRUE';
    
SELECT message.sent_datetime,message.message_id, message.text, 
      user.user_id, user.profile_img, user.username, room.room_id, 
      room.name,room_user.last_read_message_id
    FROM message 
    LEFT JOIN room_user ON message.room_user_id = room_user.room_user_id
    JOIN user  ON user.user_id = room_user.user_id
    JOIN room ON room.room_id = room_user.room_id
    WHERE room.room_id = 4
    ORDER BY message.sent_datetime ASC;
    
SELECT emoji_id, message_id, count(emoji_id)
FROM emoji_reactions
WHERE message_id = 
GROUP BY message_id, emoji_id



SELECT 
    message.sent_datetime,
    message.message_id, 
    message.text, 
    user.user_id, 
    user.profile_img, 
    user.username, 
    room.room_id, 
    room.name,
    room_user.last_read_message_id,
    COALESCE(GROUP_CONCAT(emoji_reactions.emoji_id), null) AS emoji_ids,
    COALESCE(GROUP_CONCAT(emoji_reactions.image), null) AS emoji_img,
    COALESCE(GROUP_CONCAT(emoji_reactions.count_emoji), null) AS count_emoji
FROM 
    message 
LEFT JOIN 
    room_user ON message.room_user_id = room_user.room_user_id
JOIN 
    user ON user.user_id = room_user.user_id
JOIN 
    room ON room.room_id = room_user.room_id
LEFT JOIN 
    (SELECT emoji_reactions.message_id, emoji.emoji_id, emoji.image, COUNT(*) as count_emoji
     FROM emoji_reactions
     JOIN emoji ON emoji.emoji_id = emoji_reactions.emoji_id
     GROUP BY message_id, emoji_id
     )
     AS emoji_reactions ON message.message_id = emoji_reactions.message_id
WHERE 
    room.room_id = 4
GROUP BY
    message.sent_datetime,
    message.message_id, 
    message.text, 
    user.user_id, 
    user.profile_img, 
    user.username, 
    room.room_id, 
    room.name,
    room_user.last_read_message_id
ORDER BY 
    message.sent_datetime ASC;
    
    
    
SELECT message.sent_datetime,message.message_id, message.text, 
      user.user_id, user.profile_img, user.username, room.room_id, 
      room.name,room_user.last_read_message_id
    FROM message 
    LEFT JOIN room_user ON message.room_user_id = room_user.room_user_id
    JOIN user  ON user.user_id = room_user.user_id
    JOIN room ON room.room_id = room_user.room_id
    WHERE room.room_id = 4
    ORDER BY message.sent_datetime ASC;