let startTime;
let elapsedTime = 0;
let timerInterval;
let isRunning = false;
let lapTimes = [];

const display = document.getElementById("display");
const startBtn = document.getElementById("start");
const pauseBtn = document.getElementById("pause");
const resetBtn = document.getElementById("reset");
const lapBtn = document.getElementById("lap");
const laps = document.getElementById("laps");
const themeToggle = document.getElementById("theme-toggle");

// Load from localStorage on page load
window.onload = () => {
  const savedTheme = localStorage.getItem("theme");
  if (savedTheme === "dark") {
    document.body.classList.add("dark");
    themeToggle.checked = true;
  }

  const savedLaps = localStorage.getItem("laps");
  if (savedLaps) {
    lapTimes = JSON.parse(savedLaps);
    lapTimes.forEach(addLapToUI);
  }
};

// Format time as HH:MM:SS.mmm
function timeToString(time) {
  const ms = time % 1000;
  const sec = Math.floor((time / 1000) % 60);
  const min = Math.floor((time / (1000 * 60)) % 60);
  const hr = Math.floor(time / (1000 * 60 * 60));
  return `${String(hr).padStart(2, '0')}:${String(min).padStart(2, '0')}:${String(sec).padStart(2, '0')}.${String(ms).padStart(3, '0')}`;
}

// Start timer
function startTimer() {
  if (isRunning) return;
  isRunning = true;
  startTime = Date.now() - elapsedTime;
  timerInterval = setInterval(() => {
    elapsedTime = Date.now() - startTime;
    display.textContent = timeToString(elapsedTime);
  }, 10);
  playBeep();
}

// Pause timer
function pauseTimer() {
  if (!isRunning) return;
  isRunning = false;
  clearInterval(timerInterval);
  playBeep();
}

// Reset everything
function resetTimer() {
  clearInterval(timerInterval);
  elapsedTime = 0;
  isRunning = false;
  display.textContent = "00:00:00.000";
  lapTimes = [];
  laps.innerHTML = "";
  localStorage.removeItem("laps");
  playBeep();
}

// Record lap
function recordLap() {
  if (!isRunning) return;
  const time = timeToString(elapsedTime);
  lapTimes.push(time);
  addLapToUI(time);
  localStorage.setItem("laps", JSON.stringify(lapTimes));
  playBeep();
}

// Add lap to list
function addLapToUI(time) {
  const lapItem = document.createElement("li");
  lapItem.textContent = time;
  laps.appendChild(lapItem);
}

// Export laps to CSV
function exportCSV() {
  if (lapTimes.length === 0) return;

  // 1. Create CSV content
  const csvContent = "Lap Time\n" + lapTimes.join("\n");

  // 2. Encode & create downloadable link
  const encodedUri = "data:text/csv;charset=utf-8," + encodeURIComponent(csvContent);
  const link = document.createElement("a");
  link.setAttribute("href", encodedUri);
  link.setAttribute("download", "lap_times.csv");
  document.body.appendChild(link);
  link.click();
  document.body.removeChild(link);

  // 3. Show CSV content on web page
  document.getElementById("csv-output").textContent = csvContent;
}

// Theme toggle
themeToggle.addEventListener("change", () => {
  document.body.classList.toggle("dark");
  localStorage.setItem("theme", document.body.classList.contains("dark") ? "dark" : "light");
});

// Beep sound
function playBeep() {
  const audio = new Audio("https://www.soundjay.com/buttons/sounds/beep-07.mp3");
  audio.play();
}

// Add export button
const exportBtn = document.createElement("button");
exportBtn.textContent = "Export CSV";
exportBtn.style.marginTop = "10px";
exportBtn.addEventListener("click", exportCSV);
document.querySelector(".container").appendChild(exportBtn);

// Button listeners
startBtn.addEventListener("click", startTimer);
pauseBtn.addEventListener("click", pauseTimer);
resetBtn.addEventListener("click", resetTimer);
lapBtn.addEventListener("click", recordLap);
