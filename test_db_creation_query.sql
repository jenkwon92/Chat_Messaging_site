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