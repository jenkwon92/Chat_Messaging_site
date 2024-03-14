const database = include("databaseConnection");

async function createChat(postData) {
  let users_ids = postData.users_ids;
  try {
    // Start a transaction
    await database.query(`START TRANSACTION;`);

    // Create the chat
    await database.query(`INSERT INTO room (name) VALUES (:name);`, {
      name: postData.name,
    });

    // Get the id of the chat that was just created
    let lastRoomIdResult = await database.query(
      `SELECT Max(room_id) AS room_id FROM room;`
    );

    // Add the user who created the chat to the room
    await database.query(
      `
      INSERT INTO room_user (user_id, room_id, last_read_message_id)
      SELECT user_id,:lastRoomId, 0
      FROM user
      WHERE username = :username;
    `,
      {
        lastRoomId: lastRoomIdResult[0][0].room_id,
        username: postData.username,
      }
    );

    // Add the other users to the room
    for (const userId of users_ids) {
      await database.query(
        `
        INSERT INTO room_user (user_id, room_id, last_read_message_id)
        VALUES (?, ?, 0)
      `,
        [userId, lastRoomIdResult[0][0].room_id]
      );
    }

    // Commit the transaction
    await database.query(`COMMIT;`);
    console.log("Successfully created chat");
    return true;
  } catch (err) {
    console.log("Error inserting user");
    console.log(err);
    return false;
  }
}

async function getChatsByUser(postData) {
  let getChatsByUserSQL = `
		SELECT room.name
        FROM room
        JOIN room_user ON room.room_id = room_user.room_id
        JOIN user ON user.user_id = room_user.user_id
        WHERE user.username = :username;
	`;

  let params = {
    username: postData.username,
  };

  try {
    const results = await database.query(getChatsByUserSQL, params);
    console.log("Successfully invoked chats by user");
    console.log(results[0]);
    return results[0];
  } catch (err) {
    console.log("Error invoking chats");
    console.log(err);
    return false;
  }
}

async function getChatsLastMessageByUser(postData) {
  let getChatsLastMessageByUserSQL = `
		SELECT 
        room.room_id,
        room.name, 
        COALESCE(latest_message.sent_datetime, 'No messages') as latest_message_time,
        COALESCE(message_count.num_messages_behind, 0) AS num_messages_behind
    FROM room
    LEFT JOIN room_user ON room.room_id = room_user.room_id AND room_user.user_id = (
        SELECT user_id FROM user WHERE username = :username
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
    WHERE user.username = :username;
	`;

  let params = {
    username: postData.username,
  };

  try {
    const results = await database.query(getChatsLastMessageByUserSQL, params);
    console.log("Successfully invoked chats by user");
    console.log(results[0]);
    return results[0];
  } catch (err) {
    console.log("Error invoking chats");
    console.log(err);
    return false;
  }
}

async function getChatsByRoom(postData) {
  let getChatsByRoomSQL = `
		SELECT message.sent_datetime,message.message_id, message.text, 
      user.user_id, user.profile_img, user.username, room.room_id, 
      room.name,room_user.last_read_message_id
    FROM message 
    LEFT JOIN room_user ON message.room_user_id = room_user.room_user_id
    JOIN user  ON user.user_id = room_user.user_id
    JOIN room ON room.room_id = room_user.room_id
    WHERE room.room_id = :room_id
    ORDER BY message.sent_datetime ASC;
	`;

  let params = {
    room_id: postData.room_id,
  };

  try {
    const results = await database.query(getChatsByRoomSQL, params);
    console.log("Successfully invoked chats by room");
    console.log(results[0]);
    return results[0];
  } catch (err) {
    console.log("Error invoking chats by room");
    console.log(err);
    return false;
  }
}

async function addUserToRoom(postData) {
  let users_ids = postData.users_ids;
  let room_id = postData.room_id;
  console.log("users_ids", users_ids);

  try {
    // Start a transaction
    await database.query(`START TRANSACTION;`);

    // Add the other users to the room
    for (const userId of users_ids) {
      await database.query(
        `
        INSERT INTO room_user (user_id, room_id, last_read_message_id)
        VALUES (?, ?, 0)
      `,
        [userId, postData.room_id]
      );
    }

    // Commit the transaction
    await database.query(`COMMIT;`);
    console.log("Successfully inviting people to the room");
    return true;
  } catch (err) {
    console.log("Error inviting people to the room");
    console.log(err);
    return false;
  }
}

async function sendMessage(postData) {
  let room_id = postData.room_id;
  let user_id = postData.user_id;
  let text = postData.text;

  try {
    // Start a transaction
    await database.query(`START TRANSACTION;`);

    // Create the chat
    let room_user_id = await database.query(
      `SELECT room_user_id
        FROM room_user
        WHERE user_id = :user_id and room_id = :room_id`,
      {
        room_id: room_id,
        user_id: user_id,
      }
    );

    console.log("room_user_id", room_user_id[0]);

    await database.query(
      `INSERT INTO message (room_user_id, text) VALUES (:room_user_id, :text)`,
      {
        room_user_id: room_user_id[0][0].room_user_id,
        text: text,
      }
    );

    // Commit the transaction
    await database.query(`COMMIT;`);
    console.log("Successfully created chat");
    return true;
  } catch (err) {
    console.log("Error creating chat");
    console.log(err);
    return false;
  }
}

module.exports = {
  createChat,
  getChatsByUser,
  getChatsLastMessageByUser,
  getChatsByRoom,
  addUserToRoom,
  sendMessage,
};
