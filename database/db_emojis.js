const database = include("databaseConnection");

async function getEmojis() {
  let getEmojisSQL = `
		SELECT emoji_id, name, image FROM emoji;
	`;

  try {
    const results = await database.query(getEmojisSQL);
    console.log("Successfully found emojis");
    console.log(results[0]);
    return results[0];
  } catch (err) {
    console.log("Error trying to find emojis");
    console.log(err);
    return false;
  }
}

module.exports = {
  getEmojis,
};
