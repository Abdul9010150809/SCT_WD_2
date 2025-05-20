#!/bin/bash

# Project folder
mkdir stopwatch-app
cd stopwatch-app || exit

# Create files
touch index.html style.css script.js

# index.html content
cat <<EOF > index.html
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
  <title>Stopwatch App</title>
  <link rel="stylesheet" href="style.css">
</head>
<body>
  <div class="container">
    <h1>⏱️ Stopwatch</h1>
    <div class="stopwatch">
      <div id="display">00:00:00.000</div>
      <div class="buttons">
        <button id="start">Start</button>
        <button id="pause">Pause</button>
        <button id="reset">Reset</button>
        <button id="lap">Lap</button>
      </div>
      <label class="theme-toggle">
        <input type="checkbox" id="theme-toggle" />
        Dark Mode
      </label>
      <ul id="laps"></ul>
    </div>
  </div>
  <script src="script.js"></script>
</body>
</html>
EOF

# style.css content
cat <<EOF > style.css
body {
  font-family: 'Segoe UI', sans-serif;
  background: #f0f2f5;
  display: flex;
  justify-content: center;
  align-items: center;
  height: 100vh;
}

body.dark {
  background-color: #121212;
  color: #f1f1f1;
}

body.dark .container {
  background-color: #1e1e1e;
}

.container {
  background: #ffffff;
  padding: 30px;
  border-radius: 20px;
  box-shadow: 0 5px 20px rgba(0, 0, 0, 0.1);
  text-align: center;
}

#display {
  font-size: 3rem;
  margin-bottom: 20px;
}

.buttons button {
  padding: 10px 20px;
  margin: 5px;
  font-size: 1rem;
  border: none;
  border-radius: 10px;
  background-color: #007bff;
  color: white;
  cursor: pointer;
}

.buttons button:hover {
  background-color: #0056b3;
}

#laps {
  margin-top: 20px;
  text-align: left;
  max-height: 150px;
  overflow-y: auto;
  list-style: decimal;
  padding-left: 20px;
}

.theme-toggle {
  margin-top: 15px;
  display: block;
  font-size: 1rem;
  cursor: pointer;
}

body, .container, button {
  transition: all 0.3s ease;
}
EOF

# script.js content
cat <<EOF > script.js
let startTime;
let elapsedTime = 0;
let timerInterval;
const display = document.getElementById("display");
const startBtn = document.getElementById("start");
const pauseBtn = document.getElementById("pause");
const resetBtn = document.getElementById("reset");
const lapBtn = document.getElementById("lap");
const laps = document.getElementById("laps");
const themeToggle = document.getElementById("theme-toggle");

let lapTimes = [];

window.onload = () => {
  if (localStorage.getItem("theme") === "dark") {
    document.body.classList.add("dark");
    themeToggle.checked = true;
  }
  if (localStorage.getItem("laps")) {
    lapTimes = JSON.parse(localStorage.getItem("laps"));
    lapTimes.forEach(time => addLapToUI(time));
  }
};

themeToggle.addEventListener("change", () => {
  document.body.classList.toggle("dark");
  localStorage.setItem("theme", document.body.classList.contains("dark") ? "dark" : "light");
});

function timeToString(time) {
  const ms = time % 1000;
  const sec = Math.floor((time / 1000) % 60);
  const min = Math.floor((time / (1000 * 60)) % 60);
  const hr = Math.floor(time / (1000 * 60 * 60));
  return \`\${String(hr).padStart(2, '0')}:\${String(min).padStart(2, '0')}:\${String(sec).padStart(2, '0')}.\${String(ms).padStart(3, '0')}\`;
}

function startTimer() {
  startTime = Date.now() - elapsedTime;
  timerInterval = setInterval(() => {
    elapsedTime = Date.now() - startTime;
    display.textContent = timeToString(elapsedTime);
  }, 10);
  playBeep();
}

function pauseTimer() {
  clearInterval(timerInterval);
  playBeep();
}

function resetTimer() {
  clearInterval(timerInterval);
  display.textContent = "00:00:00.000";
  elapsedTime = 0;
  lapTimes = [];
  laps.innerHTML = "";
  localStorage.removeItem("laps");
  playBeep();
}

function recordLap() {
  const time = timeToString(elapsedTime);
  lapTimes.push(time);
  addLapToUI(time);
  localStorage.setItem("laps", JSON.stringify(lapTimes));
  playBeep();
}

function addLapToUI(time) {
  const lapItem = document.createElement("li");
  lapItem.textContent = time;
  laps.appendChild(lapItem);
}

function exportCSV() {
  if (lapTimes.length === 0) return;
  const csvContent = "data:text/csv;charset=utf-8,Lap Time\\n" + lapTimes.map(t => \`\${t}\`).join("\\n");
  const encodedUri = encodeURI(csvContent);
  const link = document.createElement("a");
  link.setAttribute("href", encodedUri);
  link.setAttribute("download", "lap_times.csv");
  document.body.appendChild(link);
  link.click();
  document.body.removeChild(link);
}

function playBeep() {
  const audio = new Audio("https://www.soundjay.com/buttons/sounds/beep-07.mp3");
  audio.play();
}

const exportBtn = document.createElement("button");
exportBtn.textContent = "Export CSV";
exportBtn.style.marginTop = "10px";
exportBtn.addEventListener("click", exportCSV);
document.querySelector(".container").appendChild(exportBtn);

startBtn.addEventListener("click", startTimer);
pauseBtn.addEventListener("click", pauseTimer);
resetBtn.addEventListener("click", resetTimer);
lapBtn.addEventListener("click", recordLap);
EOF

echo "✅ Stopwatch project created in $(pwd)"

# Optional: open in VS Code
if command -v code &> /dev/null; then
  code .
fi

