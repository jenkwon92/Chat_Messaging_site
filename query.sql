-- Submit a screenshot for the with user, the room they are in and the number of unread messages in
-- each room.
-- Submit your file:
-- 03_Number_of _Unread_Messages.jpg

SELECT user.user_id, room_user.room_id, COUNT(*) AS	'num_message_behind'
FROM user
JOIN room_user
JOIN 
ON user.user_id = room_user.user_id
GROUP BY user.user_id, room_user.room_id;


-- 각방의 마지막 메세지
SELECT room_user.user_id, room_user.room_id, room_user.last_read_message_id ,MAX(message.message_id) AS 'max_message'
FROM room_user 
JOIN message
ON room_user.room_user_id = message.room_user_id
GROUP BY room_user.user_id, room_user.room_id, room_user.last_read_message_id;

SELECT room_user.user_id, room_user.room_id,  COUNT(*) AS 'num_message_behind'
FROM room_user 
JOIN message
ON room_user.room_user_id = message.room_user_id
GROUP BY room_user.user_id, room_user.room_id
HAVING COUNT(*) = (
	SELECT COUNT(*)
    FROM room_user
    JOIN message ON room_user.room_user_id = message.room_user_id
    JOIN user ON room_user.user_id = user.user_id
	WHERE room_user.last_read_message_id < (
		SELECT MAX(message_id)
		FROM message
        )
);




