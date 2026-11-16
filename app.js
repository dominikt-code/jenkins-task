const express = require("express");
const app = express();

const tasks = [{ id: 1, title: "Setup"}];

app.get("/health", (req, res) => res.json({status: "ok"}));
app.get("/tasks", (req, res) => res.json(tasks));

module.exports = app;