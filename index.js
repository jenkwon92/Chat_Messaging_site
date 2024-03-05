require("./utils");

require("dotenv").config();
const express = require("express");

// Session management
const session = require("express-session");
const MongoStore = require("connect-mongo");
// Hash passwords using BCrypt
const bcrypt = require("bcrypt");
const saltRounds = 12;

const database = include("databaseConnection");
const db_utils = include("database/db_utils");
const success = db_utils.printMySQLVersion();

//reference of the express module
const app = express();

const expireTime = 24 * 60 * 60 * 1000; //expires after 1 day  (hours * minutes * seconds * millis)

/* secret information section */
const mongodb_user = process.env.MONGODB_USER;
const mongodb_password = process.env.MONGODB_PASSWORD;
const mongodb_session_secret = process.env.MONGODB_SESSION_SECRET;

const node_session_secret = process.env.NODE_SESSION_SECRET;
/* END secret section */

app.set("view engine", "ejs");

// parse application/json
app.use(express.urlencoded({ extended: false }));
const port = process.env.PORT || 3000;

var mongoStore = MongoStore.create({
  mongoUrl: `mongodb+srv://${mongodb_user}:${mongodb_password}@cluster0.3lizggb.mongodb.net/sessions`,
  crypto: {
    secret: mongodb_session_secret,
  },
});

app.use(
  session({
    secret: node_session_secret,
    store: mongoStore, //default is memory store
    saveUninitialized: false,
    resave: true,
  })
);

// get method route
// / : root path
app.get("/", (req, res) => {
  res.render("index");
});

// signup : signup path
app.get("/signup", (req, res) => {
  res.render("signup");
});

// signingUp
app.post("/signup", (req, res) => {
  const { username, password } = req.body;
  // Hash the password
  bcrypt.hash(password, saltRounds, (err, hash) => {
    if (err) {
      console.log(err);
      res.redirect("/signup");
    } else {
      // Store the username and password in the database
      // users.push({ username, password: hash });
      res.redirect("/login");
    }
  });
});

// Login
app.get("/login", (req, res) => {
  res.render("login");
});

// Logging in
app.post("/loggingin", (req, res) => {
  const { username, password } = req.body;
  // Check if the username and password are in the database
  // const user = users.find((user) => user.username === username);
  // if (user) {
  //   bcrypt.compare(password, user.password, (err, result) => {
  //     if (result) {
  //       req.session.username = username;
  //       res.redirect("/chats");
  //     } else {
  //       res.redirect("/login");
  //     }
  //   });
  // } else {
  //   res.redirect("/login");
  // }
});

// A page to show all of the chat groups that you are in
app.get("/chats", (req, res) => {
  res.render("chats");
});

// A list of the messages within that group
app.get("/chat_messages", (res, req) => {
  res.render("chat_messages");
});

// A page that you can give your group a name and
// select from a list of users to add to the group
app.get("/create_group", (res, req) => {
  res.render("create_group");
});

app.listen(port, () => {
  console.log(`Server is running on port ${port}`);
});
